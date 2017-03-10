SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/20/2011
-- Description:	Summarizes the results from measures by the default age band.
--				(Requires member months to be populated in order to return rows.)
-- =============================================
CREATE PROCEDURE [Result].[SummarizeMeasureByAgeBand]
(
	@DataRunID int,
	@BatchID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @AgeBandID int;
	DECLARE @BenefitID smallint;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SummarizeMeasureByAgeBand'; 
		SET @LogObjectSchema = 'Result'; 
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					@AgeBandID = MMS.DefaultAgeBandID,
					@BenefitID = DR.DefaultBenefitID,
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Measure.MeasureSets AS MMS
							ON DR.MeasureSetID = MMS.MeasureSetID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;
			
			--Summarize the metric portion...
			SELECT	MABS.AgeBandID,
					MABS.AgeBandSegID,
					ISNULL(MX.BenefitID, @BenefitID) AS BenefitID,
					COUNT(DISTINCT CAST(RMD.DSMemberID AS varchar) + '_' + CONVERT(varchar, RMD.KeyDate, 112)) AS CountEvents,
					COUNT(DISTINCT RMD.DSMemberID) AS CountMembers,
					COUNT(DISTINCT RMD.ResultRowID) AS CountRecords,
					RMD.DataRunID,
					RMD.DataSetID,
					SUM(RMD.[Days]) AS [Days],
					SUM(CAST(RMD.IsDenominator AS bigint)) AS IsDenominator,
					SUM(CAST(RMD.IsExclusion AS bigint)) AS IsExclusion,
					SUM(CAST(RMD.IsIndicator AS bigint)) AS IsIndicator,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 THEN CASE RMD.IsNumerator WHEN 1 THEN 0 WHEN 0 THEN 1 END WHEN IsExclusion = 1 THEN 0 END)) AS IsNegative,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 THEN RMD.IsNumerator ELSE 0 END)) AS IsNumerator,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND RMD.IsNumerator = 1 THEN RMD.IsNumeratorAdmin ELSE 0 END)) AS IsNumeratorAdmin,
					SUM(CONVERT(bigint, CASE WHEN IsDenominator = 1 AND RMD.IsNumerator = 1 AND RMD.IsNumeratorAdmin = 0 THEN RMD.IsNumeratorMedRcd ELSE 0 END)) AS IsNumeratorMedRcd,
					RMD.MeasureID,
					RMD.MeasureXrefID,
					RMD.MetricID,
					RMD.MetricXrefID,
					RMD.PopulationID,
					RMD.ProductLineID,
					SUM(RMD.Qty) AS Qty,
					RMD.ResultTypeID,
					AVG(RMD.[Weight]) AS [Weight]
			INTO	#MetricTotals
			FROM	Result.MeasureDetail_Classic AS RMD
					INNER JOIN Measure.Metrics AS MX
							ON RMD.MeasureID = MX.MeasureID AND
								RMD.MetricID = MX.MetricID		
					INNER JOIN Measure.AgeBandSegments AS MABS
							ON RMD.Gender = ISNULL(MABS.Gender, RMD.Gender) AND
								RMD.ProductLineID = ISNULL(MABS.ProductLineID, RMD.ProductLineID) AND
								RMD.AgeMonths BETWEEN ISNULL(MABS.FromAgeTotMonths, RMD.AgeMonths) AND ISNULL(MABS.ToAgeTotMonths, RMD.AgeMonths) AND
								MABS.AgeBandID = @AgeBandID
			WHERE	(RMD.DataRunID = @DataRunID)
			GROUP BY MABS.AgeBandID,
					MABS.AgeBandSegID,
					ISNULL(MX.BenefitID, @BenefitID),
					RMD.DataRunID,
					RMD.DataSetID,
					RMD.MeasureID,
					RMD.MeasureXrefID,
					RMD.MetricID,
					RMD.MetricXrefID,
					RMD.PopulationID,
					RMD.ProductLineID,
					RMD.ResultTypeID;

			--Summarize the member month portion...
			SELECT DISTINCT
					BenefitID, MeasureID, ResultTypeID
			INTO	#MeasureBenefits
			FROM	#MetricTotals;

			CREATE UNIQUE CLUSTERED INDEX IX_#MeasureBenefits ON #MeasureBenefits (MeasureID, ResultTypeID, BenefitID);
			
			SELECT DISTINCT	
					ISNULL(MX.BenefitID, t.BenefitID) AS BenefitID, 
					t.MeasureID, 
					t.MeasureXrefID,
					t.MetricID, 
					t.MetricXrefID,
					t.ResultTypeID
			INTO	#MetricBenefits
			FROM	#MetricTotals AS t
					INNER JOIN Measure.Metrics AS MX
							ON t.MeasureID = MX.MeasureID AND
								MX.IsShown = 1;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricBenefits ON #MetricBenefits (MetricID, ResultTypeID, BenefitID);
			
			SELECT	MABS.AgeBandID,
					MABS.AgeBandSegID,
					RMMD.BenefitID,
					COUNT(DISTINCT RMMD.DSMemberID) AS CountMembers,
					SUM(RMMD.CountMonths) AS CountMonths,
					COUNT(DISTINCT RMMD.ResultRowID) AS CountRecords,
					RMMD.DataRunID,
					RMMD.DataSetID,
					MIN(MABS.Gender) AS Gender,
					t.MeasureID,
					t.MeasureXrefID,
					t.MetricID,
					t.MetricXrefID,
					RMMD.PopulationID,
					RMMD.ProductLineID,
					t.ResultTypeID
			INTO	#MonthTotals
			FROM	#MetricBenefits AS t
					INNER JOIN Result.MemberMonthDetail_Classic AS RMMD	
							ON t.BenefitID = RMMD.BenefitID
					INNER JOIN Measure.AgeBandSegments AS MABS
							ON RMMD.Gender = ISNULL(MABS.Gender, RMMD.Gender) AND
								RMMD.ProductLineID = ISNULL(MABS.ProductLineID, RMMD.ProductLineID) AND
								RMMD.AgeMonths BETWEEN ISNULL(MABS.FromAgeTotMonths, RMMD.AgeMonths) AND ISNULL(MABS.ToAgeTotMonths, RMMD.AgeMonths) AND
								MABS.AgeBandID = @AgeBandID
			WHERE	(RMMD.DataRunID = @DataRunID)
			GROUP BY MABS.AgeBandID,
					MABS.AgeBandSegID,
					RMMD.BenefitID,
					RMMD.DataRunID,
					RMMD.DataSetID,
					t.MeasureID,
					t.MeasureXrefID,
					t.MetricID,
					t.MetricXrefID,
					RMMD.PopulationID,
					RMMD.ProductLineID,
					t.ResultTypeID;
					
			--Purges existing summary data, if any, and copies new summary data...
			DELETE FROM Result.MeasureAgeBandSummary WHERE ((DataRunID = @DataRunID));

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureAgeBandSummary)
				TRUNCATE TABLE Result.MeasureAgeBandSummary;

			--Insert new summary data by coming the metric and member month portions...
			INSERT INTO Result.MeasureAgeBandSummary
					(AgeBandID,
					AgeBandSegID,
					BenefitID,
					CountEvents,
					CountMembers,
					CountMonths,
					CountRecords,
					DataRunID,
					DataSetID,
					[Days],
					Gender,
					IsDenominator,
					IsExclusion,
					IsIndicator,
					IsNegative,
					IsNumerator,
					IsNumeratorAdmin,
					IsNumeratorMedRcd,
					MeasureID,
					MeasureXrefID,
					MetricID,
					MetricXrefID,
					PopulationID,
					ProductLineID,
					Qty,
					ResultTypeID,
					[Weight])
			SELECT	NT.AgeBandID,
					NT.AgeBandSegID,
					NT.BenefitID,
					ISNULL(XT.CountEvents, 0) AS CountEvents,
					ISNULL(NT.CountMembers, 0) AS CountMembers, 
					ISNULL(NT.CountMonths, 0) AS CountMonths,
					ISNULL(XT.CountRecords, 0) AS CountRecords,
					NT.DataRunID,
					NT.DataSetID,
					ISNULL(XT.[Days], 0) AS [Days],
					NT.Gender,
					ISNULL(XT.IsDenominator, 0) AS IsDenominator,		
					ISNULL(XT.IsExclusion, 0) AS IsExclusion,
					ISNULL(XT.IsIndicator, 0) AS IsIndicator,
					ISNULL(XT.IsNegative, 0) AS IsNegative,
					ISNULL(XT.IsNumerator, 0) AS IsNumerator,
					ISNULL(XT.IsNumeratorAdmin, 0) AS IsNumeratorAdmin,
					ISNULL(XT.IsNumeratorMedRcd, 0) AS IsNumeratorMedRcd,
					NT.MeasureID,
					NT.MeasureXrefID,
					NT.MetricID,
					NT.MetricXrefID,
					NT.PopulationID,
					NT.ProductLineID,
					ISNULL(XT.Qty, 0) AS Qty,		
					NT.ResultTypeID,
					ISNULL(xt.[Weight], 0) AS [Weight]
			FROM	#MonthTotals AS NT
					LEFT OUTER JOIN #MetricTotals AS XT
							ON NT.AgeBandID = XT.AgeBandID AND
								NT.AgeBandSegID = XT.AgeBandSegID AND
								NT.BenefitID = XT.BenefitID AND
								NT.DataRunID = XT.DataRunID AND
								NT.DataSetID = XT.DataSetID AND
								NT.MeasureID = XT.MeasureID AND
								NT.MetricID = XT.MetricID AND
								NT.PopulationID = XT.PopulationID AND
								NT.ProductLineID = XT.ProductLineID AND
								NT.ResultTypeID = XT.ResultTypeID
			ORDER BY [DataRunID] ASC,
					[ProductLineID] ASC,
					[PopulationID] ASC,
					[ResultTypeID] ASC,
					[MeasureID] ASC,
					[MetricID] ASC,
					[AgeBandID] ASC,
					[AgeBandSegID] ASC;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Summarizing measures by age band completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = [Log].RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
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
			SET @LogDescr = 'Summarizing measures by age band failed!';
			
			EXEC @Result = [Log].RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
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
GRANT VIEW DEFINITION ON  [Result].[SummarizeMeasureByAgeBand] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMeasureByAgeBand] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMeasureByAgeBand] TO [Processor]
GO
