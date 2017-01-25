SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/30/2011
-- Description:	Processess the contents of an XML string based on the specified file format.
-- =============================================
CREATE PROCEDURE [Cloud].[ProcessBatchFileXml]
(
	@BatchGuid uniqueidentifier = NULL,
	@BeginSeedDate datetime = NULL,
	@Data xml,
	@EndSeedDate datetime = NULL,
	@FileFormatGuid uniqueidentifier,
	@MeasureSetGuid uniqueidentifier,
	@OwnerGuid uniqueidentifier,
	@PrintSql int = 0,
	@ReturnData xml = NULL OUTPUT,
	@ReturnFileFormatGuid uniqueidentifier = NULL,
	@SeedDate datetime = NULL,
	@UserName nvarchar(128) = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ProcessBatchFileXML'; 
		SET @LogObjectSchema = 'Cloud'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			DECLARE @CountRecords int;
			
			--Added 8/29/2013 to capture XML file header attributes-----------------------------------------------------------
			DECLARE @CalculateMbrMonths bit;
			DECLARE @DefaultBenefitGuid uniqueidentifier;
			DECLARE @MbrMonthGuid uniqueidentifier;
			
			IF @Data IS NOT NULL AND 
				@Data.exist('/file') = 1
			WITH FileHeader AS
			(
				SELECT	[file].value('@batch', 'uniqueidentifier') AS BatchGuid,
						dbo.ConvertDateFromYYYYMMDD([file].value('@beginseeddate', 'varchar(8)')) AS BeginInitSeedDate,
						dbo.ConvertBitFromYN([file].value('@calculatemembermonths', 'char(1)')) AS CalculateMbrMonths,
						[file].value('@defaultbenefit', 'uniqueidentifier') AS DefaultBenefitGuid,
						dbo.ConvertDateFromYYYYMMDD([file].value('@endseeddate', 'varchar(8)')) AS EndInitSeedDate,
						[file].value('@format', 'uniqueidentifier') AS FileFormatGuid,
						[file].value('@measureset', 'uniqueidentifier') AS MeasureSetGuid,
						[file].value('@membermonthconfig', 'uniqueidentifier') AS MbrMonthGuid,
						[file].value('@owner', 'uniqueidentifier') AS OwnerGuid,
						[file].value('@returnformat', 'uniqueidentifier') AS ReturnFileFormatGuid,
						dbo.ConvertDateFromYYYYMMDD([file].value('@seeddate', 'varchar(8)')) AS SeedDate
				FROM	@Data.nodes('/file') AS f([file])
			)
			SELECT TOP 1
					@BatchGuid = ISNULL(@BatchGuid, FH.BatchGuid),
					@BeginSeedDate = ISNULL(@BeginSeedDate, FH.BeginInitSeedDate),
					@CalculateMbrMonths = ISNULL(@CalculateMbrMonths, FH.CalculateMbrMonths),
					@DefaultBenefitGuid = ISNULL(@DefaultBenefitGuid, FH.DefaultBenefitGuid),
					@EndSeedDate = ISNULL(@EndSeedDate, FH.EndInitSeedDate),
					@FileFormatGuid = ISNULL(@FileFormatGuid, FH.FileFormatGuid),
					@MeasureSetGuid = ISNULL(@MeasureSetGuid, FH.MeasureSetGuid),
					@MbrMonthGuid = ISNULL(@MbrMonthGuid, FH.MbrMonthGuid),
					@OwnerGuid = ISNULL(@OwnerGuid, FH.OwnerGuid),
					@ReturnFileFormatGuid = ISNULL(@ReturnFileFormatGuid, FH.ReturnFileFormatGuid),
					@SeedDate = COALESCE(@SeedDate, FH.SeedDate, FH.EndInitSeedDate)
			FROM	FileHeader AS FH;
			
			DECLARE @DefaultBenefitID smallint;
			DECLARE @MbrMonthID smallint;
			
			SELECT @DefaultBenefitID = PB.BenefitID FROM Product.Benefits AS PB WHERE (PB.BenefitGuid = @DefaultBenefitGuid);
			SELECT @MbrMonthID = MMM.MbrMonthID FROM Measure.MemberMonths AS MMM WHERE (MMM.MbrMonthGuid = @MbrMonthGuid);
			-------------------------------------------------------------------------------------------------------------------
			
			DECLARE @BatchID int;
			DECLARE @DataRunID int;
			DECLARE @DataSetID int;
			DECLARE @FileFormatID int;
			DECLARE @MeasureSetID int;
			DECLARE @OwnerID int;
			DECLARE @ReturnFileFormatID int;
			
			SELECT @FileFormatID = FileFormatID FROM Cloud.FileFormats WHERE (FileFormatGuid = @FileFormatGuid);
			SELECT @MeasureSetID = MeasureSetID FROM Measure.MeasureSets WHERE (MeasureSetGuid = @MeasureSetGuid);
			SELECT @OwnerID = OwnerID FROM Batch.DataOwners WHERE (OwnerGuid = @OwnerGuid);
			SELECT @ReturnFileFormatID = FileFormatID FROM Cloud.FileFormats WHERE (FileFormatGuid = @ReturnFileFormatGuid);
			
			DECLARE @FileFormatTypeID int;
			SELECT @FileFormatTypeID = FileFormatTypeID FROM Cloud.FileFormatTypes WHERE FileFormatTypeGuid = '11A61BE1-FF41-4CD4-8757-1ED603786C5F';
		
			
			IF @FileFormatID IS NOT NULL AND EXISTS(SELECT TOP 1 1 FROM Cloud.FileFormats WHERE FileFormatID = @FileFormatID AND FileFormatTypeID = @FileFormatTypeID)
				BEGIN
					IF @OwnerID IS NOT NULL
						BEGIN
							IF @Data IS NULL	
								RAISERROR('Processing XML for BATCH failed.  The data could not be compiled into XML.', 16, 1);
						
							IF @BatchGuid IS NULL
								SET @BatchGuid = NEWID();
						
							BEGIN TRANSACTION TBatch;
							
							DECLARE @RealBatchGuid uniqueidentifier;
							DECLARE @RealDataRunGuid uniqueidentifier;
							DECLARE @RealDataSetGuid uniqueidentifier;
							
							SET @RealBatchGuid = NEWID();
							SET @RealDataRunGuid = NEWID();
							SET @RealDataSetGuid = NEWID();
							
							--Create new data set...
							EXEC @Result = Batch.CreateDataSet @DataSetGuid = @RealDataSetGuid, 
																@DataSetID = @DataSetID OUTPUT,
																@OwnerID = @OwnerID,
																@SourceGuid = @BatchGuid;
							PRINT @DataSetID
							--Disable processes that are not compatible with "N Servers"...
							IF @Result = 0
								UPDATE	BDSP
								SET		IsEnabled = 0
								FROM	Batch.DataSetProcedures AS BDSP
								WHERE	BDSP.ProcID IN (
															SELECT	ProcID
															FROM	Batch.[Procedures] AS BP
															WHERE	ProcGuid IN ('D5982A23-6ED3-470B-829D-A1DBC6601B1D',
																				'22073A37-7F5E-4D7D-96C9-E344FA32D498')
														);
							
							--Create new data run...
							IF @Result = 0 	
								EXEC @Result = Batch.CreateDataRun @BatchSize = 2147483647,
																	@BeginInitSeedDate = @BeginSeedDate,
																	@CalculateMbrMonths = @CalculateMbrMonths,
																	@DataRunGuid = @RealDataRunGuid,
																	@DataRunID = @DataRunID OUTPUT, 
																	@DataSetID = @DataSetID,
																	@DefaultBenefitID = @DefaultBenefitID,
																	@EndInitSeedDate = @EndSeedDate,
																	@FileFormatID = @FileFormatID,
																	@MeasureSetID = @MeasureSetID,
																	@MbrMonthID = @MbrMonthID,
																	@ReturnFileFormatID = @ReturnFileFormatID,
																	@SeedDate = @SeedDate,
																	@SourceGuid = @BatchGuid;
							
							--Create the dummy batch...							
							IF @Result = 0
								INSERT INTO Batch.[Batches]
										(BatchGuid,
										BatchStatusID,
										DataRunID,
										DataSetID,
										SourceGuid)
								VALUES  (@RealBatchGuid,
										Batch.ConvertBatchStatusIDFromAbbrev('B'),
										@DataRunID,
										@DataSetID,
										@BatchGuid)
										
							SELECT @BatchID = SCOPE_IDENTITY();
							
							IF @BatchID IS NOT NULL AND @FileFormatID IS NOT NULL AND
								EXISTS (SELECT TOP 1 1 FROM Engine.Settings WHERE SaveBatchData = 1)                          
								INSERT INTO Batch.BatchData
								        (BatchID,
										CreatedBy,
										CreatedDate,
										Data,
										FileFormatID)
								VALUES  (@BatchID,
										ISNULL(@UserName, SUSER_NAME()),
										GETDATE(),
										@Data,
										@FileFormatID);
										
							SET @LogDescr = 'Processing XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' initialized.'; 
							
							EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
																@BeginTime = @LogBeginTime,
																@CountRecords = @CountRecords,
																@DataRunID = @DataRunID,
																@DataSetID = @DataSetID,
																@Descr = @LogDescr,
																@EndTime = NULL, 
																@EntryXrefGuid = @LogEntryXrefGuid, 
																@IsSuccess = 1,
																@SrcObjectName = @LogObjectName,
																@SrcObjectSchema = @LogObjectSchema;
										
							--IF OBJECT_ID('Temp.ShowMeWhatTheCrapIsGoingOn') IS NOT NULL
							--	DROP TABLE Temp.ShowMeWhatTheCrapIsGoingOn;
							
							--SELECT @BatchGuid AS BatchGuid,
							--		@BatchID AS BatchID,
							--		@BeginSeedDate AS BeginSeedDate,
							--		@Data AS Data,
							--		@DataRunID AS DataRunID,
							--		@DataSetID AS DataSetID,
							--		@EndSeedDate AS EndSeedDate,
							--		@FileFormatGuid AS FileFormatGuid,
							--		@FileFormatID AS FileFormatID,
							--		@MeasureSetGuid AS MeasureSetGuid,
							--		@MeasureSetID AS MeasureSetID,
							--		@OwnerGuid AS OwnerGuid,
							--		@OwnerID AS OwnerID,
							--		@PrintSql AS PrintSql,
							--		@Result AS Result,
							--		@ReturnData AS ReturnData,
							--		@ReturnFileFormatGuid AS ReturnFileFormatGuid,
							--		@ReturnFileFormatID AS ReturnFileFormatID,
							--		@UserName AS UserName
							--INTO Temp.ShowMeWhatTheCrapIsGoingOn
							--FROM dbo.Tally
							--WHERE N = 1;
							
							IF @BatchID IS NOT NULL AND @Result = 0
								BEGIN;
									COMMIT TRANSACTION TBatch;
									
									--1) Insert batch data from XML
									EXEC @Result = Cloud.ApplyBatchFileXML @BatchID = @BatchID, 
																				@Data = @Data, 
																				@FileFormatID = @FileFormatID,
																				@InsertRecords = 1, 
																				@PrintSql = @PrintSql;
									
									--2) Identify batch members
									IF @Result = 0
										EXEC @Result = Cloud.IdentifyBatchMembers @BatchID = @BatchID;
									
									--3) Clean-up missing data values
									IF @Result = 0
										EXEC @Result = Cloud.CleanUpMissingValues @BatchID = @BatchID, @CleanUpType = 'Processor';
										
									--4) Process results
									IF @Result = 0
										EXEC @Result = Batch.RunDataSetProcedures @DataRunID = @DataRunID;
									
									--5) Generate return file, if applicable
									IF @ReturnFileFormatID IS NOT NULL AND @Result = 0
										BEGIN
											EXEC @Result = Cloud.GetBatchFileXML @BatchID = @BatchID, 
																					@Data = @ReturnData OUTPUT, 
																					@FileFormatID = @ReturnFileFormatID, 
																					@IncludeBatchInXmlHeader = 0,
																					@PrintSql = @PrintSql,
																					@ReturnFileFormatID = NULL;
																					
											IF @BatchID IS NOT NULL AND @ReturnFileFormatID IS NOT NULL
												INSERT INTO Batch.BatchData
														(BatchID,
														CreatedBy,
														CreatedDate,
														Data,
														FileFormatID)
												VALUES  (@BatchID,
														ISNULL(@UserName, SUSER_NAME()),
														GETDATE(),
														@ReturnData,
														@ReturnFileFormatID);
											
										END;
										
									--6) Perform clean-up
									IF @Result = 0
										BEGIN;
											EXEC @Result = Batch.PurgeInternalTables @BatchID = @BatchID;
											EXEC @Result = Batch.PurgeLogTables @BatchID = @BatchID;
											EXEC @Result = Batch.PurgeResultTables @BatchID = 0;
										END;
								END;
							ELSE
								RAISERROR('Processing XML for BATCH failed.  The new batch failed to initialize.', 16, 1);
						END;
					ELSE
						RAISERROR('Processing XML for BATCH failed.  The specified owner is invalid.', 16, 1);
				END;
			ELSE
				RAISERROR('Processing XML for BATCH failed.  The specified file format is invalid.', 16, 1);
			
			--------------------------------------------------------------------------

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
			IF @Data IS NULL	
				RAISERROR('Processing XML for BATCH failed.  The data could not be compiled into XML.', 16, 1);
			
			SET @LogDescr = 'Processing XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
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
			SET @LogDescr = 'Processing XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
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
END







GO
GRANT EXECUTE ON  [Cloud].[ProcessBatchFileXml] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ProcessBatchFileXml] TO [Submitter]
GO
