SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2011
-- Description:	Creates the member/measure batches for processing for the specified dataset and optional measure.
-- =============================================
CREATE PROCEDURE [Batch].[CreateDataSetBatches]
(
	@BatchSize int = NULL,
	@BeginInitSeedDate datetime = NULL,
	@CalculateMbrMonths bit = 1,
	@CalculateXml bit = 1,
	@DataRunID int = NULL OUTPUT,
	@DataSetID int,
	@DefaultBenefitID int = 1,
	@EndInitSeedDate datetime = NULL,
	@FileFormatID int = NULL,
	@IsLogged bit = 1,
	@IsReady bit = 1,
	@MeasureID int = NULL,
	@MeasureSetID int,
	@MbrMonthID int = 1,
	@ReturnFileFormatID int = NULL,
	@SeedDate datetime
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	SET @LogBeginTime = GETDATE();
	SET @LogObjectName = 'CreateDataSetBatches'
	SET @LogObjectSchema = 'Batch'
	
	--Added to determine @LogEntryXrefGuid value---------------------------
	SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
	-----------------------------------------------------------------------
		
	DECLARE @Result int;

	BEGIN TRY;
		IF @DataSetID IS NOT NULL AND 
			EXISTS (SELECT 1 FROM Batch.DataSets WHERE DataSetID = @DataSetID) AND 
			@MeasureSetID IS NOT NULL AND
			EXISTS (SELECT 1 FROM Measure.MeasureSets WHERE MeasureSetID = @MeasureSetID)
			
			BEGIN;
				
				IF @SeedDate IS NULL
					SELECT @SeedDate = DefaultSeedDate FROM Measure.MeasureSets WHERE MeasureSetID = @MeasureSetID
				
				IF @BeginInitSeedDate IS NULL
					SET @BeginInitSeedDate = DATEADD(dd, 1, DATEADD(yy, -1, @SeedDate))
					
				IF @EndInitSeedDate IS NULL
					SET @EndInitSeedDate = @SeedDate
			
			
				--1) Identify members, as well as "score" them for balanced batching...
							
				--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
				DECLARE @Ansi_Warnings bit;
				SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS OFF;
				
				IF OBJECT_ID('tempdb..#Members') IS NOT NULL
					DROP TABLE #Members;
					
				--1a) Identify members
				SELECT	CONVERT(int, 0) AS CountClaimCodes,
						CONVERT(int, 0) AS CountClaimLines,
						CONVERT(int, 0) AS CountEnrollment,
						CONVERT(int, 0) AS CountProviders,
						CONVERT(int, 0) AS CountTotal,
						CONVERT(bigint, DSMemberID) AS DSMemberID, --Convert used here to remove automatic identity column
						CONVERT(decimal(18,6), 0) AS Score,
						CONVERT(int, NULL) AS SortOrder,
						CONVERT(int, NULL) AS SortOrderAsc,
						CONVERT(int, NULL) AS SortOrderDesc
				INTO	#Members
				FROM	Member.Members 
				WHERE	(DataSetID = @DataSetID);
					
				CREATE UNIQUE CLUSTERED INDEX IX_#Members ON #Members (DSMemberID);
					
				--1b) Quantity number of records associated with each member
				UPDATE	M
				SET		CountClaimCodes = (SELECT COUNT(*) FROM Claim.ClaimCodes WHERE DataSetID = @DataSetID AND DSMemberID = M.DSMemberID)
				FROM	#Members AS M;

				UPDATE	M
				SET		CountClaimLines = (SELECT COUNT(*) FROM Claim.ClaimLines WHERE DataSetID = @DataSetID AND DSMemberID = M.DSMemberID)
				FROM	#Members AS M;

				UPDATE	M
				SET		CountEnrollment = (SELECT COUNT(*) FROM Member.Enrollment WHERE DataSetID = @DataSetID AND DSMemberID = M.DSMemberID)
				FROM	#Members AS M;
				
				UPDATE	M
				SET		CountProviders = (SELECT COUNT(DISTINCT DSProviderID) FROM Claim.ClaimLines WHERE DataSetID = @DataSetID AND DSMemberID = M.DSMemberID)
				FROM	#Members AS M;

				--1c) Add up total records and apply weighted scoring
				UPDATE	#Members 
				SET		CountTotal = CountClaimCodes + CountClaimLines + CountEnrollment + CountProviders,
						Score = (CountClaimCodes * 0.75) + (CountClaimLines * 1.00) + (CountEnrollment * 0.50) + (CountProviders * 0.25);

				--1d) Sort member both ascending and descending by score 
				IF OBJECT_ID('tempdb..#SortAsc') IS NOT NULL
					DROP TABLE #SortAsc;
				
				IF OBJECT_ID('tempdb..#SortDesc') IS NOT NULL
					DROP TABLE #SortDesc;
				 
				SELECT DSMemberID, IDENTITY(bigint, 1, 1) AS SortOrder INTO #SortAsc FROM #Members ORDER BY Score ASC, DSMemberID ASC;
				CREATE UNIQUE CLUSTERED INDEX IX_#SortAsc ON #SortAsc (DSMemberID);
				
				SELECT DSMemberID, IDENTITY(bigint, 1, 1) AS SortOrder INTO #SortDesc FROM #Members ORDER BY Score DESC, DSMemberID ASC;
				CREATE UNIQUE CLUSTERED INDEX IX_#SortDesc ON #SortDesc (DSMemberID);

				--1e) Determine overall sort order of members for batching
				UPDATE	M
				SET		SortOrder = CASE WHEN A.SortOrder < D.SortOrder THEN A.SortOrder ELSE D.SortOrder END,
						SortOrderAsc = A.SortOrder,
						SortOrderDesc = D.SortOrder
				FROM	#Members AS M
						INNER JOIN #SortAsc AS A
								ON M.DSMemberID = A.DSMemberID
						INNER JOIN #SortDesc AS D
								ON M.DSMemberID = D.DSMemberID;
				
				IF OBJECT_ID('tempdb..#SortAsc') IS NOT NULL
					DROP TABLE #SortAsc;
				
				IF OBJECT_ID('tempdb..#SortDesc') IS NOT NULL
					DROP TABLE #SortDesc;
				
				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS ON;
								
							
				--2) Create batches for the specified members...
				IF OBJECT_ID('tempdb..#BatchSource') IS NOT NULL
					DROP TABLE #BatchSource;

				SELECT	DSMemberID, IDENTITY(bigint, 1, 1) AS ID
				INTO	#BatchSource 
				FROM	#Members
				ORDER BY SortOrder;
				
				CREATE UNIQUE CLUSTERED INDEX IX_#BatchSource ON #BatchSource (ID);
				
				DECLARE @BatchGuid uniqueidentifier;
				DECLARE @BatchID int;
				DECLARE @CountBatches int;
				DECLARE @CountItems int;
				DECLARE @CountMeasures int;
				DECLARE @CountMembers int;
				DECLARE @CountProviders int;

				--2b) Determine the number of batches ("pages") needed due to the specified batch size
				--	  (The batching process is based on a fast, scalable, server-side paging method for the web)
				DECLARE @PageNumber int;
				DECLARE @PageSize int;
				DECLARE @PageTotal int;
				DECLARE @RowTotal int;
				
				IF ISNULL(@PageNumber, 0) < 1 
					SET @PageNumber = 1;
				
				SET @PageSize = @BatchSize;

				SELECT	@CountMembers = COUNT(DISTINCT DSMemberID),
						@PageTotal = CEILING(CAST(MAX(ID) AS decimal(18,6)) / 
											CAST(@PageSize AS decimal(18,6))),
						@RowTotal = MAX(ID)
				FROM	#BatchSource;

				BEGIN TRY;				
					--2c) Create the parent data run for the batches	
					DECLARE @DataRunGuid uniqueidentifier;
				
					EXEC @Result = Batch.CreateDataRun @BatchSize = @BatchSize, 
														@BeginInitSeedDate = @BeginInitSeedDate OUTPUT,
														@CalculateMbrMonths = @CalculateMbrMonths, 
														@CalculateXml = @CalculateXml,
														@DataRunGuid = @DataRunGuid OUTPUT,
														@DataRunID = @DataRunID OUTPUT, 
														@DataSetID = @DataSetID, 
														@DefaultBenefitID = @DefaultBenefitID,
														@EndInitSeedDate = @EndInitSeedDate OUTPUT, 
														@FileFormatID = @FileFormatID,
														@IsLogged = @IsLogged, 
														@MeasureSetID = @MeasureSetID, 
														@MbrMonthID = @MbrMonthID, 
														@ReturnFileFormatID = @ReturnFileFormatID,
														@SeedDate = @SeedDate OUTPUT;
					

					SET @LogDescr = 'Batching of RUN-' + UPPER(CAST(@DataRunGuid AS varchar(36))) + ' started.'
					
					EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
														@BeginTime = @LogBeginTime,
														@CountRecords = -1,
														@DataRunID = @DataRunID,
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogEndTime, 
														@EntryXrefGuid = @LogEntryXrefGuid,
														@IsSuccess = 1,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;


					UPDATE	BI
					SET		IsResult = 0
					FROM	Batch.BatchItems AS BI
							INNER JOIN Batch.[Batches] AS B
									ON BI.BatchID = B.BatchID
					WHERE	(B.DataSetID = @DataSetID) AND
							((@MeasureID IS NULL) OR (MeasureID = @MeasureID)) AND
							(IsResult = 1)
					OPTION (RECOMPILE);
					
					DECLARE @BatchBeginTime datetime;
					DECLARE @BatchEndTime datetime;

					DECLARE @BatchStatusA int; --Creating
					DECLARE @BatchStatusB int; --Created
					SET @BatchStatusA = Batch.ConvertBatchStatusIDFromAbbrev('A');
					SET @BatchStatusB = Batch.ConvertBatchStatusIDFromAbbrev('B');

					--2d) Create the batches (batchs = pages)
					WHILE @PageNumber <= @PageTotal AND ISNULL(@Result, 0) = 0
						BEGIN;
							BEGIN TRANSACTION TBatchCreation;
						
							SET @BatchBeginTime = GETDATE();
						
							--2d.1) Create the batch entry
							SET @BatchGuid = NEWID();
							
							INSERT INTO Batch.[Batches]
									(BatchGuid, BatchStatusID, DataRunID, DataSetID, SourceGuid)
							VALUES
									(@BatchGuid, @BatchStatusA, @DataRunID, @DataSetID, @BatchGuid);
							
							SET @BatchID = SCOPE_IDENTITY();			
						
							--2d.2) Assign measures associated with the batch
							INSERT INTO Batch.BatchMeasures 
							        (BatchID,
							         MeasureID)
							SELECT	@BatchID,
									MeasureID
							FROM	Measure.Measures
							WHERE	(MeasureSetID = @MeasureSetID) AND
									((@MeasureID IS NULL) OR (MeasureID = @MeasureID));
						
							SET @CountMeasures = @@ROWCOUNT;
						
							--2d.3) Assign members associated with the batch (based on server-side paging)
							WITH 
							Step1 AS
							(	
								SELECT TOP (@PageNumber * @PageSize)
										ID, ID AS RowID
								FROM	#BatchSource 
							),
							Step2 AS
							(
								SELECT TOP (@PageSize)
										*
								FROM	step1
								WHERE	(RowID > (@PageNumber - 1) * @PageSize)
								ORDER BY RowID 
							
							),
							Step3 AS
							(
								SELECT	@RowTotal AS TotalRows
							),
							CurrentBatch AS
							(
								SELECT
										S.*, t.RowID, 
										t.RowID - ((@PageNumber - 1) * @PageSize) AS ItemID, 
										@PageSize AS PageSize,
										@PageNumber as PageNumber,
										c.TotalRows, 
										@PageTotal AS TotalPages
								FROM	#BatchSource AS S
										INNER JOIN Step2 AS t
												ON S.ID = t.ID 
										CROSS JOIN Step3 AS c

							)
							INSERT INTO Batch.BatchMembers
							        (BatchID,
							        DSMemberID)
							SELECT	@BatchID,
									DSMemberID
							FROM	CurrentBatch
							ORDER BY DSMemberID;
							
							SET @CountMembers = @@ROWCOUNT;
							
							--2d.4) Create batch item entries
							INSERT INTO Batch.BatchItems 
									(BatchID, DSMemberID, IsResult, MeasureID)
							SELECT	@BatchID,
									BMBR.DSMemberID,
									1 AS IsResult,
									BM.MeasureID
							FROM	Batch.BatchMembers AS BMBR
									INNER JOIN Batch.BatchMeasures AS BM
											ON BMBR.BatchID = BM.BatchID AND
												BMBR.BatchID = @BatchID AND
												BM.BatchID = @BatchID
							ORDER BY BMBR.DSMemberID, BM.MeasureID;
							
							SET @CountItems = @@ROWCOUNT;
							
							--2d.5) Create batch provider entries
							INSERT INTO Batch.BatchProviders
									(BatchID,
									DSProviderID)
							SELECT DISTINCT
									BBM.BatchID,
									CCL.DSProviderID
							FROM	Batch.BatchMembers AS BBM
									INNER JOIN Claim.ClaimLines AS CCL
											ON BBM.DSMemberID = CCL.DSMemberID
							WHERE	(BBM.BatchID = @BatchID) AND
									(CCL.DSProviderID IS NOT NULL);
							
							SET @CountProviders = @@ROWCOUNT;
							
							--3) Summarize batch creation...						
							--3a) Determine total records counts of claim codes, claim lines, enrollment, and providers
							IF OBJECT_ID('tempdb..#RecordCounts') IS NOT NULL
								DROP TABLE #RecordCounts;
							
							SELECT	BB.BatchID,
									SUM(M.CountClaimCodes) AS CountClaimCodes,
									SUM(M.CountClaimLines) AS CountClaimLines,
									SUM(M.CountEnrollment) AS CountEnrollment,
									SUM(M.CountProviders) AS CountProviders
							INTO	#RecordCounts
							FROM	Batch.[Batches] AS BB
									INNER JOIN Batch.BatchMembers AS BBM
											ON BB.BatchID = BBM.BatchID
									INNER JOIN #Members AS M
											ON BBM.DSMemberID = M.DSMemberID
							WHERE	(BB.BatchID = @BatchID) AND
									(BB.DataRunID = @DataRunID)
							GROUP BY BB.BatchID;

							CREATE UNIQUE CLUSTERED INDEX IX_#RecordCounts ON #RecordCounts (BatchID);

							--3c) Apply record counts to batch summary
							UPDATE	B
							SET		CountClaimCodes = RC.CountClaimCodes,
									CountClaimLines = RC.CountClaimLines,
									CountEnrollment = RC.CountEnrollment,
									CountItems = @CountItems,
									CountMeasures = @CountMeasures,
									CountMembers = @CountMembers,
									CountProviders = @CountProviders
							FROM	Batch.[Batches] AS B
									INNER JOIN #RecordCounts AS RC
											ON B.BatchID = RC.BatchID
							WHERE	(B.BatchID = @BatchID);
							
							SET @BatchEndTime = GETDATE();
							
							SET @LogDescr = ' - The creation of BATCH ' + CAST(@BatchID AS varchar) + ' succeeded.'
							EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
																@BeginTime = @BatchBeginTime,
																@CountRecords = @CountItems,
																@DataRunID = @DataRunID,
																@DataSetID = @DataSetID,
																@Descr = @LogDescr,
																@EndTime = @BatchEndTime,
																@EntryXrefGuid = '943F0E2C-4511-427E-95C1-7190056CAECF',
																@ExecObjectName = @LogObjectName,
																@ExecObjectSchema = @LogObjectSchema,
																@IsSuccess = 1,
																@SrcObjectName = @LogObjectName,
																@SrcObjectSchema = @LogObjectSchema,
																@StepNbr = @PageNumber,
																@StepTot = @PageTotal;

							SET @PageNumber = @PageNumber + 1;
							
							COMMIT TRANSACTION TBatchCreation;
						END;
					
					BEGIN TRANSACTION TBatchPrepFinalize;
						
					UPDATE	Batch.DataRuns 
					SET		CountBatches = (SELECT COUNT(*) FROM Batch.[Batches] WHERE (DataRunID = @DataRunID))
					WHERE	DataRunID = @DataRunID;
										
					UPDATE	Batch.[Batches]
					SET		BatchStatusID = @BatchStatusB
					WHERE	DataRunID = @DataRunID;
					
					IF @IsReady = 1
					UPDATE	Batch.DataRuns
					SET		IsReady = 1
					WHERE	DataRunID = @DataRunID;
					
					COMMIT TRANSACTION TBatchPrepFinalize;
					
					SET @LogDescr = 'Batching of RUN-' + UPPER(CAST(@DataRunGuid AS varchar(36))) + ' completed successfully.';
					SET @LogEndTime = GETDATE();
					
					EXEC @Result = Log.RecordEntry	
														@BeginTime = @LogBeginTime,
														@CountRecords = @CountItems,
														@DataRunID = @DataRunID,
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogEndTime, 
														@EntryXrefGuid = @LogEntryXrefGuid,
														@IsSuccess = 1,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;
					
					RETURN 0;
				END TRY
				BEGIN CATCH;
					IF @@TRANCOUNT > 0
						ROLLBACK;
						
					DECLARE @ErrorLine int;
					DECLARE @ErrorLogID int;
					DECLARE @ErrorMessage nvarchar(max);
					DECLARE @ErrorNumber int;
					DECLARE @ErrorSeverity int;
					DECLARE @ErrorSource nvarchar(512);
					DECLARE @ErrorState int;
					
					DECLARE @ErrorResult int;
					
					SELECT	@ErrorLine = ERROR_LINE(),
							@ErrorMessage = ERROR_MESSAGE(),
							@ErrorNumber = ERROR_NUMBER(),
							@ErrorSeverity = ERROR_SEVERITY(),
							@ErrorSource = ERROR_PROCEDURE(),
							@ErrorState = ERROR_STATE();
							
					EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
															@Message = @ErrorMessage,
															@ErrorNumber = @ErrorNumber,
															@ErrorType = 'Q',
															@ErrLogID = @ErrorLogID OUTPUT,
															@Severity = @ErrorSeverity,
															@Source = @ErrorSource,
															@State = @ErrorState,
															@PerformRollback = 0;
					
					
					SET @LogEndTime = GETDATE();
					
					IF @DataRunGuid IS NOT NULL AND @DataRunID IS NOT NULL
						SET @LogDescr = 'Batching of RUN-' + UPPER(CAST(@DataRunGuid AS varchar(36))) + ' failed!';
					ELSE
						SET @LogDescr = 'Batching failed!';
					
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @LogBeginTime,
															@CountRecords = @RowTotal,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @LogBeginTime,
															@EntryXrefGuid = @LogEntryXrefGuid,
															@ErrLogID = @ErrorLogID,
															@IsSuccess = 0,
															@SrcObjectName = @LogObjectName,
															@SrcObjectSchema = @LogObjectSchema;
																
					SET @ErrorMessage = REPLACE(@LogDescr, '!', ': ') + @ErrorMessage + ' (Error: ' + CAST(@ErrorNumber AS nvarchar) + ')';
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
					
				END CATCH;
			END;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END;
GO
GRANT EXECUTE ON  [Batch].[CreateDataSetBatches] TO [Processor]
GO
