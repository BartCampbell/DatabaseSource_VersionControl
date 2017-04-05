SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/8/2017
-- Description:	Calculates the detailed results of the DAE measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[DAE_CalculateMeasureDetail]
(
	@BatchID int = NULL,
	@CountRecords bigint = NULL OUTPUT
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
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'DAE_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
		
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 0
				SET ANSI_WARNINGS ON;

			DECLARE @DAE_A_EventID int;
			DECLARE @DAE_A_MinQty smallint;
			DECLARE @DAE_MeasureID int;
			DECLARE @DAE2_EntityID int;
			DECLARE @DAE2_MetricID int;

			--1) Identity the various Entity/Event/Measure/Metric IDs for DAE2...
			SELECT	@DAE_A_EventID = MEC.DateComparerInfo,
					@DAE_A_MinQty = MEC.QtyMin,
					@DAE_MeasureID = MM.MeasureID,
					@DAE2_EntityID = ME.EntityID,
					@DAE2_MetricID = MX.MetricID
			FROM	Measure.Measures AS MM
					INNER JOIN Measure.Metrics AS MX
							ON MX.MeasureID = MM.MeasureID AND
								MM.IsEnabled = 1
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.Entities AS ME
							ON ME.EntityID = METMM.EntityID AND
								ME.IsEnabled = 1
					INNER JOIN Measure.MappingTypes AS MMT
							ON MMT.MapTypeID = METMM.MapTypeID
					CROSS APPLY (
									SELECT TOP 1
											tMEC.*
									FROM	Measure.EntityCriteria AS tMEC
											INNER JOIN Measure.DateComparers AS tMDC
													ON tMDC.DateComparerID = tMEC.DateComparerID AND
														tMDC.IsSeed = 1 --Seed Date-specific
											INNER JOIN Measure.DateComparerTypes AS tMDCT
													ON tMDCT.DateCompTypeID = tMDC.DateCompTypeID AND
														tMDCT.Abbrev = 'V' --Event-specific
									WHERE	tMEC.EntityID = ME.EntityID AND
											tMEC.IsEnabled = 1 AND
											tMEC.IsForIndex = 1 AND
											tMEC.QtyMax < tMEC.QtyMin
									ORDER BY tMEC.OptionNbr, tMEC.EntityCritID
								) AS MEC
			WHERE	MX.Abbrev = 'DAE2' AND --Two or More
					MM.Abbrev = 'DAE' AND
					MMT.Descr = 'Numerator' AND
					MM.MeasureSetID = @MeasureSetID AND
					ME.MeasureSetID = @MeasureSetID;
				
			IF @DAE_A_EventID IS NOT NULL AND @DAE_MeasureID IS NOT NULL AND
				@DAE2_EntityID IS NOT NULL AND @DAE2_MetricID IS NOT NULL
				BEGIN;
				
					--2a) If IDs are found, identify the members associated with DAE2...
					SELECT	RMD.DSMemberID,
							RMD.ResultRowID
					INTO	#DAE2_Members
					FROM	Result.MeasureDetail AS RMD
					WHERE	RMD.IsDenominator = 1 AND
							RMD.IsNumerator = 0 AND
							RMD.BatchID = @BatchID AND
							RMD.DataRunID = @DataRunID AND
							RMD.DataSetID = @DataSetID AND
							RMD.MeasureID = @DAE_MeasureID AND
							RMD.MetricID = @DAE2_MetricID AND
							RMD.ResultTypeID = 1;

					CREATE UNIQUE CLUSTERED INDEX IX_#DAE2_Members ON #DAE2_Members (DSMemberID);

					--2b) If IDs are found, identify the events associated with DAE2 from the member list...
					SELECT	LV.*, DM.ResultRowID
					INTO	#DAE2_Events
					FROM	Proxy.[Events] AS LV
							INNER JOIN #DAE2_Members AS DM
									ON DM.DSMemberID = LV.DSMemberID
					WHERE	LV.BatchID = @BatchID AND
							LV.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate AND
							LV.DataRunID = @DataRunID AND
							LV.DataSetID = @DataSetID AND
							LV.EventID = @DAE_A_EventID;

					CREATE UNIQUE CLUSTERED INDEX IX_#DAE2_Events ON #DAE2_Events (DSMemberID, DSEventID);

					--2c) Determine members with the minimum quantity requirement of events by Drug ID (Event ID)...
					WITH DAE2_ResultsBase AS
					(
						SELECT	COUNT(DISTINCT DAE2.BeginDate) AS CountEvents,
								COUNT(DISTINCT CASE WHEN DAE2.IsSupplemental = 0 THEN DAE2.BeginDate END) AS CountNoSupplemental,
								MIN(DAE2.DataSourceID) AS DataSourceID,
								ISNULL(MIN(CASE WHEN DAE2.IsSupplemental = 0 THEN DAE2.DataSourceID END), MIN(DAE2.DataSourceID)) AS DataSourceIDNoSupplemental,
								MIN(DAE2.DSEventID) AS DSEventID,
								DAE2.DSMemberID,
								DAE2.EventCritID, --Drug ID
								DAE2.ResultRowID,
								ROW_NUMBER() OVER (
													PARTITION BY DAE2.DSMemberID, DAE2.ResultRowID 
													ORDER BY COUNT(DISTINCT CASE WHEN DAE2.IsSupplemental = 0 THEN DAE2.BeginDate END) DESC,
															COUNT(DISTINCT DAE2.BeginDate) DESC, 
															DAE2.EventCritID
									) AS RowID
						FROM	#DAE2_Events AS DAE2
						GROUP BY DAE2.DSMemberID, 
								DAE2.EventCritID, --Drug ID
								DAE2.ResultRowID
						HAVING	(COUNT(DISTINCT DAE2.BeginDate) >= @DAE_A_MinQty)
					)
					SELECT	*
					INTO	#DAE2_Results
					FROM	DAE2_ResultsBase AS t
					WHERE	t.RowID = 1;

					CREATE UNIQUE CLUSTERED INDEX IX_#DAE2_Results ON #DAE2_Results (ResultRowID);

					IF @Ansi_Warnings = 0
						SET ANSI_WARNINGS OFF;
			
					--3) Apply DAE-A Numerator 2 results to MeasureDetail...
					UPDATE	RMD
					SET		RMD.IsNumerator = 1,
							RMD.IsSupplementalNumerator = CASE WHEN DAE2.CountNoSupplemental >= @DAE_A_MinQty THEN 0 ELSE 1 END,
							RMD.SourceNumerator = DAE2.DSEventID,
							RMD.SourceNumeratorSrc = CASE WHEN DAE2.CountNoSupplemental >= @DAE_A_MinQty THEN DAE2.DataSourceIDNoSupplemental ELSE DAE2.DataSourceID END
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #DAE2_Results AS DAE2
									ON DAE2.DSMemberID = RMD.DSMemberID AND
										DAE2.ResultRowID = RMD.ResultRowID
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.DataRunID = @DataRunID) AND
							(RMD.DataSetID = @DataSetID) AND
							(RMD.IsDenominator = 1 ) AND
							(RMD.IsNumerator = 0) AND
							(RMD.MeasureID = @DAE_MeasureID) AND
							(RMD.MetricID = @DAE2_MetricID) AND
							(RMD.ResultTypeID = 1);

							SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END;
			ELSE
				SET @CountRecords = ISNULL(@CountRecords, 0);
			
			
			SET @LogDescr = ' - Calculating DAE measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating DAE measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
		DECLARE @ErrMessage nvarchar(MAX);
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
