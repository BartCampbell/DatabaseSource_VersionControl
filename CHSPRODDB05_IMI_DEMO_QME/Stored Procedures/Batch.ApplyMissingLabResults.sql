SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/20/2014
-- Description:	Applies lab results to events missing results, from the same kind of event within the lag window for lab claims.
-- =============================================
CREATE PROCEDURE [Batch].[ApplyMissingLabResults]
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
		SET @LogObjectName = 'ApplyMissingLabResults'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Applying missing lab results failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
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
			
			--Retrieve Claim Types...
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			--Retrieve Event Types...
			DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C';
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L';
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D';
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P';

			--Retrieve Value Types...
			DECLARE @ValueTypeD tinyint;
			SELECT @ValueTypeD = ValueTypeID FROM Measure.EventCriteriaValueTypes WHERE Abbrev = 'D';

			--Retrieve the number of lag days permitted for labs by this data owner...			
			DECLARE @LabLagDays smallint;
			DECLARE @LabLagMonths smallint;

			SELECT	@LabLagDays = O.LabLagDays,
					@LabLagMonths = O.LabLagMonths 
			FROM	Batch.DataOwners AS O
					INNER JOIN Batch.DataSets AS DS
							ON O.OwnerID = DS.OwnerID AND
								DS.DataSetID = @DataSetID;

			-------------------------------------------------------------------

			IF @LabLagDays > 0 OR @LabLagMonths > 0
				BEGIN;
					DECLARE @Ansi_Warnings bit;
					SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

					IF @Ansi_Warnings = 1
						SET ANSI_WARNINGS OFF;
				
					WITH ValidLabEventCriteria AS --Identify lab event criteria with a decimal value value type
					(
						SELECT	DefaultValue, EventCritID
						FROM	Measure.EventCriteria AS MVC
						WHERE	(MVC.ClaimTypeID = @ClaimTypeL) AND
								(MVC.ValueTypeID = @ValueTypeD) AND
								(MVC.MeasureSetID = @MeasureSetID)
					),
					ValidLabEventsBase AS --Identify events with only a single lab criteria (from previous step) as its only option
					(
						SELECT DISTINCT
								MAX(t.DefaultValue) AS DefaultValue, 
								MAX(MVO.EventCritID) AS EventCritID,
								MVO.EventID
						FROM	Measure.EventOptions AS MVO
								INNER JOIN Measure.[Events] AS MV
										ON MVO.EventID = MV.EventID
								LEFT OUTER JOIN ValidLabEventCriteria AS t
										ON MVO.EventCritID = t.EventCritID
						WHERE	(MV.IsEnabled = 1) AND
								(MV.MeasureSetID = @MeasureSetID)
						GROUP BY MVO.EventID
						HAVING (COUNT(DISTINCT MVO.EventCritID) = 1) AND
								(MIN(MVO.EventCritID) = MAX(MVO.EventCritID)) AND
								(MAX(MVO.EventCritID) IN (SELECT EventCritID FROM ValidLabEventCriteria))
					)
					SELECT	*
					INTO	#ValidLabEvents
					FROM	ValidLabEventsBase;

					CREATE UNIQUE CLUSTERED INDEX IX_#ValidLabEvents ON #ValidLabEvents (EventID);

					SELECT	PV.DSEventID,
							PV.DSMemberID,
							DATEADD(dd, @LabLagDays * -1, DATEADD(mm, @LabLagMonths * -1, ISNULL(PV.EndDate, PV.BeginDate))) AS EvalBeginDate,
							DATEADD(dd, -1, ISNULL(PV.EndDate, PV.BeginDate)) AS EvalEndDate,
							VLV.EventCritID,
							VLV.EventID,
							PV.IsSupplemental,
							PV.Value
					INTO	#EventsToEvaluate
					FROM	Proxy.Events AS PV
							INNER JOIN #ValidLabEvents AS VLV
									ON PV.EventID = VLV.EventID AND
										PV.EventCritID = VLV.EventCritID AND
										PV.Value = VLV.DefaultValue;

					CREATE UNIQUE CLUSTERED INDEX IX_#EventsToEvaluate ON #EventsToEvaluate (DSEventID);
					CREATE NONCLUSTERED INDEX IX_#EventsToEvaluate2 ON #EventsToEvaluate (DSMemberID, EventID, EvalBeginDate, EvalEndDate, Value);

					SELECT	t.DSEventID,
							(SELECT PV.EventInfo AS [values] FOR XML PATH(''), TYPE) AS EventValueInfo,
							PV.IsSupplemental,
							PV.Value
					INTO	#NewValues
					FROM	#EventsToEvaluate AS t
							CROSS APPLY (
											SELECT TOP 1 
													* 
											FROM	Proxy.Events AS tPV
											WHERE	tPV.DSMemberID = t.DSMemberID AND
													tPV.EventID = t.EventID AND
													(
														((tPV.BeginDate BETWEEN t.EvalBeginDate AND t.EvalEndDate) AND (tPV.EndDate IS NULL)) OR
														(tPV.EndDate BETWEEN t.EvalBeginDate AND t.EvalEndDate)
													) AND
													tPV.DSEventID <> t.DSEventID AND
													tPV.Value <> t.Value
											ORDER BY ISNULL(tPV.EndDate, tPV.BeginDate) DESC, tPV.Value
										) AS PV

					CREATE UNIQUE CLUSTERED INDEX IX_#NewValues ON #NewValues (DSEventID);

					UPDATE	PV
					SET		EventValueInfo = t.EventValueInfo, 
							IsSupplemental = ISNULL(NULLIF(PV.IsSupplemental, 0), t.IsSupplemental), --If current value is not supplemental, then use the supplemental setting from the new value
							Value = t.Value
					FROM	Proxy.Events AS PV
							INNER JOIN #NewValues AS t
									ON PV.DSEventID = t.DSEventID;

					SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
					IF @Ansi_Warnings = 1
						SET ANSI_WARNINGS ON;			
				END;
						
			SET @LogDescr = ' - Applying missing lab results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Applying missing lab results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!';
			
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
GRANT EXECUTE ON  [Batch].[ApplyMissingLabResults] TO [Processor]
GO
