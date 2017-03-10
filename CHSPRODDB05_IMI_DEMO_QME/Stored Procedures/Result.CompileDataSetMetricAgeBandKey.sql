SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/20/2011
-- Description:	Compiles the measure/metric by age band reference key values for the specified Data Run.
-- =============================================
CREATE PROCEDURE [Result].[CompileDataSetMetricAgeBandKey]
(
	@DataRunID int
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

	DECLARE @AgeBandID int;
	DECLARE @BatchID int;
	DECLARE @BenefitID smallint;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileDataSetMetricAgeBandKey'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
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
			
			DECLARE @MaxAgeMonths int;
			DECLARE @MinAgeMonths int;
			
			SELECT	@MaxAgeMonths = MAX(Age) * 12,
					@MinAgeMonths = MIN(Age) * 12
			FROM	Result.MemberMonthDetail AS RMMD
			WHERE	(DataRunID = @DataRunID)
		
			
			DELETE FROM Result.DataSetMetricAgeBandKey WHERE ((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));

			IF NOT EXISTS(SELECT TOP 1 1 FROM Result.DataSetMetricAgeBandKey)
				TRUNCATE TABLE Result.DataSetMetricAgeBandKey;

			WITH Populations AS
			(
				SELECT	MNP.PopulationID, MNPPL.ProductLineID 
				FROM	Member.EnrollmentPopulations AS MNP
						INNER JOIN Member.EnrollmentPopulationProductLines AS MNPPL
								ON MNP.PopulationID = MNPPL.PopulationID
				WHERE	(MNP.OwnerID = @OwnerID) AND
						((MNP.DataSetID IS NULL) OR (MNP.DataSetID = @DataSetID))		
			)
			INSERT INTO Result.DataSetMetricAgeBandKey
					(AgeBandSegDescr, AgeBandSegID, BenefitDescr,
					BenefitID, DataRunID, DataSetID, Gender, MeasureAbbrev, MeasureID, MeasureXrefID,
					MetricDescr, MetricID, MetricXrefID, PopulationID, ProductLineID)		
			SELECT DISTINCT
					MABS.Descr AS AgeBandSegDescr, 
					MABS.AgeBandSegID, 
	 				PB.Descr AS BenefitDescr, 
	 				ISNULL(MX.BenefitID, @BenefitID) AS BenefitID,
					@DataRunID AS DataRunID, 
					@DataSetID AS DataSetID,
					MABS.Gender,
					MM.Abbrev AS MeasureAbbrev,
					MM.MeasureID,
					MM.MeasureXrefID,
					MX.Descr AS MetricDescr,
					MX.MetricID,
					MX.MetricXrefID,
					t.PopulationID,
					MMPL.ProductLineID
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
					INNER JOIN Measure.MeasureProductLines AS MMPL
							ON MM.MeasureID = MMPL.MeasureID AND
								MX.MeasureID = MMPL.MeasureID
					INNER JOIN Populations AS t
							ON MMPL.ProductLineID = t.ProductLineID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON MABS.AgeBandID = @AgeBandID AND
								((MMPL.ProductLineID = MABS.ProductLineID) OR (MABS.ProductLineID IS NULL)) AND
								(
									((MABS.FromAgeTotMonths >= @MinAgeMonths) AND (MABS.ToAgeTotMonths <= @MaxAgeMonths)) OR
									((MABS.FromAgeTotMonths IS NULL) AND (MABS.ToAgeTotMonths >= @MinAgeMonths)) OR
									((MABS.ToAgeTotMonths IS NULL) AND (MABS.FromAgeTotMonths <= @MaxAgeMonths)) 
								)
					LEFT OUTER JOIN Product.Benefits AS PB
							ON (((MX.BenefitID = PB.BenefitID) AND (MX.BenefitID IS NOT NULL)) OR
								((PB.BenefitID = @BenefitID) AND (MX.BenefitID IS NULL)))
			WHERE	(MX.IsShown = 1) AND
					((MX.AgeBandID IS NULL) OR (MABS.AgeBandSegID IS NOT NULL))
			ORDER BY MetricID, ProductLineID, PopulationID, AgeBandSegID, Gender
				
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = 'Compiling of metric by age band key values completed successfully.'; 
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
			SET @LogDescr = 'Compiling of metric by age band key values failed!';
			
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
GRANT VIEW DEFINITION ON  [Result].[CompileDataSetMetricAgeBandKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetMetricAgeBandKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetMetricAgeBandKey] TO [Processor]
GO
