SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Updates event data from matched transfers. (v3)
-- =============================================
CREATE PROCEDURE [Batch].[IdentifyEventTransfers]
(
	@BatchID int
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
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'IdentifyEventTransfers'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Identifying event transfers failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords bigint;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@CalculateXml = DR.CalculateXml,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);
			
			---------------------------------------------------------------------------
			
			DECLARE @ClaimTypeP smallint;
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			SELECT	VK.EventID
			INTO	#PharmacyEvents
			FROM	Proxy.EventKey AS VK
					INNER JOIN Measure.EventTransfers AS MVT
							ON MVT.FromEventID = VK.EventID OR	
								MVT.ToEventID = VK.EventID
			GROUP BY VK.EventID
			HAVING (COUNT(DISTINCT VK.ClaimTypeID) = 1) AND 
					(MAX(VK.ClaimTypeID) = @ClaimTypeP) AND 
					(MIN(VK.ClaimTypeID) = @ClaimTypeP);

			CREATE UNIQUE CLUSTERED INDEX IX_#PharmacyEvents ON #PharmacyEvents (EventID);

			---------------------------------------------------------------------------

			DECLARE @CountResults bigint;

			CREATE TABLE #Transfers
			(
				DSMemberID bigint NOT NULL,
				EventCritID int NULL, --Added as part of pharmacy "transfers"
				EventXferID int NOT NULL,
				EventXferInfo xml NULL,
				FromBeginDate datetime NOT NULL,
				FromDSClaimLineID bigint NOT NULL,
				FromEndDate datetime NOT NULL,
				FromEventBaseID bigint NOT NULL,
				FromEventID int NOT NULL,
				RowID bigint NOT NULL IDENTITY(1, 1),
				ToBeginDate datetime NOT NULL,
				ToDSClaimLineID bigint NOT NULL,
				ToEndDate datetime NOT NULL,
				ToEventBaseID bigint NOT NULL,
				ToEventID int NOT NULL,
				XferID bigint NULL
			);
			
			CREATE TABLE #TransferOverrideDates
			(
				BeginDate datetime NOT NULL,
				DSMemberID bigint NOT NULL,
				EndDate datetime NOT NULL,
				EventCritID int NULL,
				EventID int NOT NULL,
				EventXferInfo xml NULL,
				XferID bigint NULL
			);

			SELECT	MVT.*,
					CASE WHEN PV1.EventID IS NOT NULL AND PV2.EventID IS NOT NULL THEN 1 ELSE 0 END AS IsPharmacyOnly
			INTO	#Measure_EventTransfers
			FROM	Measure.EventTransfers AS MVT
					LEFT OUTER JOIN #PharmacyEvents AS PV1
							ON MVT.FromEventID = PV1.EventID
					LEFT OUTER JOIN #PharmacyEvents AS PV2
							ON MVT.ToEventID = PV2.EventID;

			CREATE UNIQUE CLUSTERED INDEX IX_#Measure_EventTransfers ON #Measure_EventTransfers (FromEventID, EventXferID);

			DECLARE @i int;

			WHILE 1 = 1

				BEGIN
					INSERT INTO #Transfers
							(DSMemberID,
							EventCritID, --Added as part of pharmacy "transfers"
							EventXferID,
							EventXferInfo,
							FromBeginDate,
							FromDSClaimLineID,
							FromEndDate,
							FromEventBaseID,
							FromEventID,
							ToBeginDate,
							ToDSClaimLineID,
							ToEndDate,
							ToEventBaseID,
							ToEventID,
							XferID)
					SELECT	TV.DSMemberID,
							CONVERT(int, CASE WHEN MVT.MatchOnEventCritID = 1 THEN TV.EventCritID ELSE NULL END) AS EventCritID, --Added as part of pharmacy "transfers"
							MVT.EventXferID, 
							CASE WHEN @CalculateXml = 1 
								 THEN
										(
											SELECT	ISNULL(t.EventInfo, NULL), 
													ISNULL(TV.EventInfo, NULL), 
													CASE WHEN t.EventXferInfo.exist('/transfer[1]/event[1]') = 1 THEN t.EventXferInfo.query('/transfers[1]') END, 
													CASE WHEN TV.EventXferInfo.exist('/transfer[1]/event[1]') = 1 THEN TV.EventXferInfo.query('/transfers[1]') END 
											FOR XML PATH('transfers'), TYPE
										)
								 END AS EventXferInfo,
							TV.BeginDate AS FromBeginDate,
							COALESCE(TV.XferID, TV.DSClaimLineID, TV.DSClaimID) AS FromDSClaimLineID,
							CASE WHEN MVT.IsPharmacyOnly = 1 THEN TV.EndOrigDate ELSE TV.EndDate END AS FromEndDate,
							ISNULL(TV.XferID, TV.EventBaseID) AS FromEventBaseID,
							MVT.FromEventID,
							t.BeginDate AS ToBeginDate,
							COALESCE(t.DSClaimLineID, t.DSClaimID) AS ToDSClaimLineID,
							CASE WHEN MVT.IsPharmacyOnly = 1 THEN t.EndOrigDate ELSE t.EndDate END AS ToEndDate,
							t.EventBaseID AS ToEventBaseID,
							MVT.ToEventID,
							ISNULL(TV.XferID, TV.EventBaseID) AS XferID
					FROM	Internal.[Events] AS TV WITH(INDEX(IX_Internal_Events))
							INNER JOIN #Measure_EventTransfers AS MVT WITH(INDEX(1))
									ON TV.EventID = MVT.FromEventID AND
										(
											(TV.EndDate IS NOT NULL) OR
											(
												(MVT.IsPharmacyOnly = 1) AND
												(TV.EndOrigDate IS NOT NULL)
											)
										)
							INNER JOIN Internal.[Events] AS t WITH(INDEX(IX_Internal_Events))
									ON MVT.ToEventID = t.EventID AND
										TV.EventBaseID <> t.EventBaseID AND
										TV.DSMemberID = t.DSMemberID AND
										TV.SpId = t.SpId AND
										(MVT.MatchOnEventCritID = 0 OR TV.EventCritID = t.EventCritID) AND --Added as part of pharmacy "transfers"
										(
											(MVT.AllowSupplemental = 1) OR 
											(TV.IsSupplemental = 0 AND t.IsSupplemental = 0)
										) AND
										(
											(
												MVT.IsPharmacyOnly = 0 AND
												t.BeginDate BETWEEN DATEADD(mm, MVT.BeginMonths, DATEADD(dd, MVT.BeginDays, TV.EndDate)) AND 
																	DATEADD(mm, MVT.EndMonths, DATEADD(dd, MVT.EndDays, TV.EndDate)) AND
												TV.EndDate < t.EndDate
											) OR
											(
												MVT.IsPharmacyOnly = 1 AND
												t.EndDate IS NULL AND
												TV.EndDate IS NULL AND
												t.BeginDate BETWEEN DATEADD(mm, MVT.BeginMonths, DATEADD(dd, MVT.BeginDays, TV.EndOrigDate)) AND 
																	DATEADD(mm, MVT.EndMonths, DATEADD(dd, MVT.EndDays, TV.EndOrigDate)) AND
												TV.EndOrigDate < t.EndOrigDate
											)
										)
					WHERE	(TV.SpId = @@SPID) AND
							(t.SpId = @@SPID) AND
							(TV.BatchID = @BatchID) AND
							(t.BatchID = @BatchID)
					OPTION (FORCE ORDER);

					IF OBJECT_ID('tempdb..#DateRanges') IS NOT NULL
						DROP TABLE #DateRanges;
						
					--DECLARE @MaxDate datetime;
					--DECLARE @MinDate datetime;
					
					--SELECT @MaxDate = MAX(ToEndDate), @MinDate = MIN(FromBeginDate) FROM #Transfers;

					SELECT	X.DSMemberID,
							C.D AS EvalDate,
							X.EventCritID,
							X.FromEventID AS EventID,
							CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(X.EventXferInfo, 1) END AS EventXferInfo,
							CONVERT(int, NULL) AS RangeID,
							MAX(XferID) AS XferID
					INTO	#DateRanges
					FROM	#Transfers AS X
							INNER JOIN dbo.Calendar AS C
									ON C.D BETWEEN X.FromBeginDate AND X.ToEndDate
					GROUP BY X.DSMemberID, X.EventCritID, X.FromEventID, C.D;
					
					--Clustered index required for "Quirky Update".  (Do No Remove)
					CREATE UNIQUE CLUSTERED INDEX IX_#DateRanges ON #DateRanges (DSMemberID, EventID, EventCritID, EvalDate);
					
					DECLARE @LastDSMemberID bigint;
					DECLARE @LastEvalDate datetime;
					DECLARE @LastEventCritID int;
					DECLARE @LastEventID int;
					DECLARE @RangeID int;
					
					UPDATE	#DateRanges
					SET		@RangeID = CASE WHEN DSMemberID <> ISNULL(@LastDSMemberID, -1) OR 
												 EventID <> ISNULL(@LastEventID, -1) OR 
												 (EventCritID IS NOT NULL AND ISNULL(EventCritID, -1) <> ISNULL(@LastEventCritID, -1)) 
											THEN 1
											WHEN ABS(DATEDIFF(day, ISNULL(@LastEvalDate, CONVERT(datetime, '1/1/1753')), EvalDate)) > 1  THEN ISNULL(@RangeID, 0) + 1 
											ELSE ISNULL(@RangeID, 1) END,
							RangeID = @RangeID,
							@LastDSMemberID = DSMemberID,
							@LastEvalDate = EvalDate,
							@LastEventCritID = EventCritID,
							@LastEventID = EventID
					OPTION (MAXDOP 1); --Required for "Quirky Update";															
									
					--IF @i IS NULL
					--	SELECT * FROM #DateRanges ORDER BY DSMemberID, EventID, EvalDate;
									
					INSERT INTO #TransferOverrideDates
								(BeginDate,
								DSMemberID,
								EndDate,
								EventCritID,
								EventID,
								EventXferInfo,
								XferID)
					SELECT		MIN(EvalDate) AS BeginDate,
								DSMemberID,
								MAX(EvalDate) AS EndDate,
								EventCritID,
								EventID,
								CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(EventXferInfo, 1) END AS EventXferInfo,
								MAX(XferID) AS XferID		
					FROM		#DateRanges
					GROUP BY	DSMemberID, EventCritID, EventID, RangeID;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#TransferOverrideDates ON #TransferOverrideDates (DSMemberID ASC, EventID ASC, BeginDate ASC, EventCritID ASC);
					
					UPDATE	PV
					SET		BeginDate = X.BeginDate,
							EndDate = CASE WHEN PH.EventID IS NULL THEN X.EndDate ELSE PV.EndDate END,
							EndOrigDate = CASE WHEN PH.EventID IS NOT NULL THEN X.EndDate ELSE PV.EndOrigDate END,
							EventXferInfo = X.EventXferInfo,
							IsXfer = 1,
							XferID = X.XferID
					FROM	Internal.[Events] AS PV WITH(INDEX(IX_Internal_Events))
							LEFT OUTER JOIN #PharmacyEvents AS PH WITH(INDEX(1))
									ON PH.EventID = PV.EventID
							INNER JOIN #TransferOverrideDates AS X WITH(INDEX(1))
									ON PV.DSMemberID = X.DSMemberID AND
										(X.EventCritID IS NULL OR PV.EventCritID = X.EventCritID) AND
										PV.EventID = X.EventID AND
										PV.BatchID = @BatchID AND
										PV.DataRunID = @DataRunID AND
										PV.DataSetID = @DataSetID AND
										PV.BeginDate BETWEEN X.BeginDate AND X.EndDate AND
										(
											(
												PH.EventID IS NULL AND
												PV.EndDate BETWEEN X.BeginDate AND X.EndDate
											) OR
											(
												PH.EventID IS NOT NULL AND
												PV.EndOrigDate BETWEEN X.BeginDate AND X.EndDate
											)
										)
					WHERE	(PV.SpId = @@SPID) AND
							(PV.BatchID = @BatchID)
					OPTION (FORCE ORDER);
									
					SET @CountResults = ISNULL(@CountResults, 0) + @@ROWCOUNT;
					SET @CountRecords = ISNULL(@CountRecords, 0) + @CountResults;
					
					SET @i = ISNULL(@i, 0) + 1;
					
					IF @CountResults <= 0 OR 
						@i > 48 --Prevents infinite loop
						BREAK;
					ELSE
						BEGIN
							SET @CountResults = 0;		
							
							DROP INDEX IX_#TransferOverrideDates ON #TransferOverrideDates
							TRUNCATE TABLE #TransferOverrideDates;
							TRUNCATE TABLE #Transfers;
						END 
				END;
						
			SET @LogDescr = ' - Identifying event transfers for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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

			--COMMIT TRANSACTION T1;

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
			SET @LogDescr = 'Identifying event transfers for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!';
			
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
GRANT VIEW DEFINITION ON  [Batch].[IdentifyEventTransfers] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEventTransfers] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[IdentifyEventTransfers] TO [Processor]
GO
