SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/3/2012
-- Description:	Merges two overlapping "mergeable" events (IsMerged = 1) by EventID, member and date.
-- =============================================
CREATE PROCEDURE [Batch].[MergeEvents]
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
		SET @LogObjectName = 'MergeEvents'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Merging events failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
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
			
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C';
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L';
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D';
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P';

			-------------------------------------------------------------------

			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			--IF @Ansi_Warnings = 1
			--	SET ANSI_WARNINGS OFF;
				
			IF OBJECT_ID('tempdb..#MergeBase') IS NOT NULL
				DROP TABLE #MergeBase;

			SELECT	PV.BeginDate,
					PV.ClaimTypeID,
					PV.[Days],
					PV.DSEventID,
					PV.DSMemberID,
					PV.EndDate, 
					PV.EndOrigDate,
					PV.EventCritID,
					PV.EventID,
					PV.EventInfo,
					CONVERT(bit, 0) AS IsMerged,
					CASE WHEN @CalculateXml = 1 THEN CONVERT(xml, '<merges></merges>') END AS MergeInfo,
					ISNULL(PV.EndDate, PV.EndOrigDate) AS MergeDate
			INTO	#MergeBase
			FROM	Proxy.[Events] AS PV
					INNER JOIN Measure.[Events] AS MV
							ON PV.EventID = MV.EventID AND
								MV.IsMerged = 1 AND
								MV.MeasureSetID = @MeasureSetID
					INNER JOIN Measure.EventCriteria AS MVC
							ON PV.EventCritID = MVC.EventCritID AND
								MVC.AllowMerge = 1 AND
								MVC.MeasureSetID = @MeasureSetID
			--To merge, both events must last longer than a single day, otherwise pointless
			WHERE	PV.BeginDate < COALESCE(PV.EndDate, PV.EndOrigDate, PV.BeginDate);

			CREATE UNIQUE CLUSTERED INDEX IX_#MergeBase ON #MergeBase (DSEventID);	
			CREATE UNIQUE NONCLUSTERED INDEX IX_#MergeBase2 ON #MergeBase (DSMemberID, EventID, MergeDate, BeginDate, DSEventID)  
															INCLUDE (ClaimTypeID, [Days], EndDate, EndOrigDate, EventCritID);

			DECLARE @i tinyint;

			WHILE 1 = 1
				BEGIN
					IF OBJECT_ID('tempdb..#Merge') IS NOT NULL
						DROP TABLE #Merge;
				
					SELECT	F.BeginDate,
							F.DSEventID,
							F.[Days] + T.[Days] AS [Days],
							T.EndDate,
							CASE 
								WHEN F.ClaimTypeID = @ClaimTypeP AND
									 F.[Days] IS NOT NULL AND
									 T.ClaimTypeID = @ClaimTypeP AND
									 T.[Days] IS NOT NULL
								THEN DATEADD(dd, F.[Days] + T.[Days] - 1, F.BeginDate) 
								ELSE T.EndOrigDate
								END AS EndOrigDate,
							CASE WHEN @CalculateXml = 1 
								 THEN
										CASE WHEN F.MergeInfo.exist('/merges[1]/event[1]') = 0
										THEN (SELECT ISNULL(F.EventInfo, NULL), ISNULL(T.EventInfo, NULL) FOR XML PATH(''), TYPE)
										ELSE ISNULL(T.EventInfo, NULL)
										END  
								 END AS MergeInfoInsert,
							T.DSEventID AS RemoveID,
							ROW_NUMBER() OVER (PARTITION BY F.DSMemberID, F.EventID
												ORDER BY F.BeginDate, F.DSEventID) AS RowID
					INTO	#Merge
					FROM	#MergeBase AS F
							INNER JOIN #MergeBase AS T
									ON F.DSEventID <> T.DSEventID AND
										F.DSMemberID = T.DSMemberID AND
										F.EventID = T.EventID AND
										(
											F.EventCritID = T.EventCritID OR
											(F.EventCritID IS NULL AND T.EventCritID IS NULL)		
										) AND
										(F.MergeDate BETWEEN T.BeginDate AND T.MergeDate OR
										T.BeginDate BETWEEN F.BeginDate AND F.MergeDate OR                                      
										T.MergeDate BETWEEN F.BeginDate AND F.MergeDate) 
					WHERE	(F.BeginDate < T.BeginDate);
					
					DELETE FROM #Merge WHERE RowID > 1;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#Merge ON #Merge (DSEventID);
					
					IF NOT EXISTS (SELECT TOP 1 1 FROM #Merge) OR @i >= 48
						BREAK;
					
					IF @CalculateXml = 1
						UPDATE	MB
						SET		[Days] = M.[Days],
								EndDate = M.EndDate,
								EndOrigDate  = M.EndOrigDate,
								IsMerged = 1,
								MergeDate = ISNULL(M.EndDate, M.EndOrigDate),
								MergeInfo.modify('insert sql:column("M.MergeInfoInsert") as first into (/merges[1])') 
						FROM	#MergeBase AS MB
								INNER JOIN #Merge AS M
										ON MB.DSEventID = M.DSEventID;
					ELSE
						UPDATE	MB
						SET		[Days] = M.[Days],
								EndDate = M.EndDate,
								EndOrigDate  = M.EndOrigDate,
								IsMerged = 1,
								MergeDate = ISNULL(M.EndDate, M.EndOrigDate) 
						FROM	#MergeBase AS MB
								INNER JOIN #Merge AS M
										ON MB.DSEventID = M.DSEventID;
					
					DELETE FROM #MergeBase WHERE DSEventID IN (SELECT RemoveID FROM #Merge);
					
					ALTER INDEX ALL ON #MergeBase REBUILD;
					
					SET @i = ISNULL(@i, 0) + 1
				END;
				
			DELETE FROM #MergeBase WHERE IsMerged = 0;
			
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;			
				
			UPDATE	PV
			SET		[Days] = MB.[Days],
					EndDate = MB.EndDate,
					EndOrigDate  = MB.EndOrigDate,
					EventMergeInfo = CASE WHEN @CalculateXml = 1 THEN MB.MergeInfo END
			FROM	Proxy.[Events] AS PV
					INNER JOIN #MergeBase AS MB
							ON PV.DSEventID = MB.DSEventID;

			SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = ' - Merging events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Merging events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!';
			
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
GRANT VIEW DEFINITION ON  [Batch].[MergeEvents] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[MergeEvents] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[MergeEvents] TO [Processor]
GO
