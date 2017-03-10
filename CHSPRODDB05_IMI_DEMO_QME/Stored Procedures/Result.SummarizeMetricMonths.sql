SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/5/2011
-- Description:	Summarizes the member month data into matching metrics and age bands.
-- =============================================
CREATE PROCEDURE [Result].[SummarizeMetricMonths]
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
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SummarizeMetricMonths'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					--@DataRunID = B.DataRunID,
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
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;
				
						
			DELETE FROM Result.MetricMonthSummary WHERE (DataRunID = @DataRunID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MetricMonthSummary)
				TRUNCATE TABLE Result.MetricMonthSummary;

			INSERT INTO Result.MetricMonthSummary
					(AgeBandID,
					AgeBandSegID,
					BenefitID,
					CountMembers,
					CountMonths,
					DataRunID,
					DataSetID,
					EnrollGroupID,
					MeasureID,
					MeasureXrefID,
					MetricID,
					MetricXrefID,
					PayerID, 
					PopulationID,
					ProductLineID)
			SELECT	MABS.AgeBandID, 
					MABS.AgeBandSegID,
					RMMS.BenefitID, 
					SUM(CountMembers) AS CountMembers,
					SUM(CountMonths) AS CountMonths,
					RMMS.DataRunID,
					RMMS.DataSetID,
					RMMS.EnrollGroupID,
					MM.MeasureID,
					MM.MeasureXrefID,
					MX.MetricID,
					MX.MetricXrefID,
					RMMS.PayerID,
					RMMS.PopulationID,
					RMMS.ProductLineID
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID
					INNER JOIN Measure.MeasureProductLines AS MMPL
							ON MX.MeasureID = MMPL.MeasureID
					INNER JOIN Result.MemberMonthSummary AS RMMS
							ON MX.BenefitID = RMMS.BenefitID AND
								MMPL.ProductLineID = RMMS.ProductLineID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON MX.AgeBandID = MABS.AgeBandID AND
								((MABS.ProductLineID IS NULL) OR (RMMS.ProductLineID = MABS.ProductLineID)) AND
								((MABS.Gender IS NULL) OR (RMMS.Gender = MABS.Gender)) AND
								((RMMS.Age * 12) BETWEEN ISNULL(MABS.FromAgeTotMonths, (RMMS.Age * 12)) AND ISNULL(MABS.ToAgeTotMonths, (RMMS.Age * 12)))
			WHERE	(RMMS.DataRunID = @DataRunID) AND
					((MX.AgeBandID IS NULL) OR (MABS.AgeBandSegID IS NOT NULL))
			GROUP BY MABS.AgeBandID, 
					MABS.AgeBandSegID,
					RMMS.BenefitID,
					RMMS.DataRunID,
					RMMS.DataSetID,
					RMMS.EnrollGroupID,
					MM.MeasureID,
					MM.MeasureXrefID,
					MX.MetricID,
					MX.MetricXrefID,
					RMMS.PayerID,
					RMMS.PopulationID,
					RMMS.ProductLineID
			ORDER BY MX.MetricID, RMMS.PopulationID, RMMS.ProductLineID, MABS.AgeBandSegID, RMMS.PayerID, RMMS.EnrollGroupID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Summarizing member month-based metric analysis completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Summarizing member month-based metric analysis failed!';
			
			EXEC @Result = Log.RecordEntry		@BeginTime = @LogBeginTime,
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
GRANT VIEW DEFINITION ON  [Result].[SummarizeMetricMonths] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMetricMonths] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeMetricMonths] TO [Processor]
GO
