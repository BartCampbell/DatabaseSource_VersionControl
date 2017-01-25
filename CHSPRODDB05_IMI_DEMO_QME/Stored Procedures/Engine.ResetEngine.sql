SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/26/2013
-- Description:	Purges all engine data, while also rebuilding indexes and recalculating statistics.
-- =============================================
CREATE PROCEDURE [Engine].[ResetEngine]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		BEGIN TRANSACTION TResetEngine;
		
		TRUNCATE TABLE Cloud.[Batches];
		TRUNCATE TABLE Cloud.BatchFiles;
		TRUNCATE TABLE Cloud.BatchFileObjects;
	
		TRUNCATE TABLE Batch.BatchData;
		TRUNCATE TABLE Batch.BatchItems;
		TRUNCATE TABLE Batch.BatchMeasures;
		TRUNCATE TABLE Batch.BatchMembers;
		TRUNCATE TABLE Batch.BatchProviders;
		TRUNCATE TABLE Batch.[BatchData];
		TRUNCATE TABLE Batch.[Batches];
		TRUNCATE TABLE Batch.[DataRuns];
		TRUNCATE TABLE Batch.DataSetProcedures;
		TRUNCATE TABLE Batch.DataSets;
		TRUNCATE TABLE Batch.DataSetSources;
		TRUNCATE TABLE Batch.SystematicSamples;

		TRUNCATE TABLE Member.Members;
		TRUNCATE TABLE Member.MemberAttributes;
		TRUNCATE TABLE Member.Enrollment;
		TRUNCATE TABLE Member.EnrollmentBenefits;
		TRUNCATE TABLE Provider.Providers;
		TRUNCATE TABLE Provider.ProviderSpecialties;
		TRUNCATE TABLE Claim.ClaimAttributes;
		TRUNCATE TABLE Claim.ClaimLines;
		TRUNCATE TABLE Claim.ClaimCodes;
		TRUNCATE TABLE Claim.Claims;

		TRUNCATE TABLE Internal.[ClaimAttributes];
		TRUNCATE TABLE Internal.[ClaimCodes];
		TRUNCATE TABLE Internal.[ClaimLines];
		TRUNCATE TABLE Internal.[Claims];
		TRUNCATE TABLE Internal.[ClaimSource];
		TRUNCATE TABLE Internal.[Enrollment];
		TRUNCATE TABLE Internal.[EnrollmentBenefits];
		TRUNCATE TABLE Internal.[EnrollmentKey];
		TRUNCATE TABLE Internal.[Entities];
		TRUNCATE TABLE Internal.[EntityBase];
		TRUNCATE TABLE Internal.[EntityEligible];
		TRUNCATE TABLE Internal.[EntityEnrollment];
		TRUNCATE TABLE Internal.[EntityKey];
		TRUNCATE TABLE Internal.[EventBase];
		TRUNCATE TABLE Internal.[EventKey];
		TRUNCATE TABLE Internal.[Events];
		TRUNCATE TABLE Internal.[MemberAttributes];
		TRUNCATE TABLE Internal.[Members];
		TRUNCATE TABLE Internal.[Providers];
		TRUNCATE TABLE Internal.[ProviderSpecialties];
		TRUNCATE TABLE [Log].BatchStatuses;
		TRUNCATE TABLE [Log].[Entities];
		TRUNCATE TABLE [Log].[EntityBase];
		TRUNCATE TABLE [Log].[EntityEligible];
		TRUNCATE TABLE [Log].[EntityEnrollment];
		TRUNCATE TABLE [Log].[EventBase];
		TRUNCATE TABLE [Log].[Events];
		TRUNCATE TABLE [Log].[PCR_ClinicalConditions];
		TRUNCATE TABLE [Log].ProcessEntries;
		TRUNCATE TABLE [Log].ProcessErrors;
		TRUNCATE TABLE [Log].ReportUsage;
		TRUNCATE TABLE [Log].RRU_Services;
		TRUNCATE TABLE Result.ClaimCodeSummary;
		TRUNCATE TABLE Result.ClaimLineSummary;
		TRUNCATE TABLE Result.DataSetMeasureProviderKey;
		TRUNCATE TABLE Result.DataSetMedicalGroupKey;
		TRUNCATE TABLE Result.DataSetMemberKey;
		TRUNCATE TABLE Result.DataSetMemberProviderKey;
		TRUNCATE TABLE Result.DataSetMetricAgeBandKey;
		TRUNCATE TABLE Result.DataSetMetricKey;
		TRUNCATE TABLE Result.DataSetPopulationKey;
		TRUNCATE TABLE Result.DataSetProviderKey;
		TRUNCATE TABLE Result.DataSetReviewerKey;
		TRUNCATE TABLE Result.DataSetRunKey;
		TRUNCATE TABLE Result.MeasureAgeBandSummary;
		TRUNCATE TABLE Result.MeasureDetail;
		TRUNCATE TABLE Result.MeasureDetail_AMR;
		TRUNCATE TABLE Result.MeasureDetail_EDU;
		TRUNCATE TABLE Result.MeasureDetail_FPC;
		TRUNCATE TABLE Result.MeasureDetail_HPC;
		TRUNCATE TABLE Result.MeasureDetail_IHU;
		TRUNCATE TABLE Result.MeasureDetail_PCR;
		TRUNCATE TABLE Result.MeasureDetail_RRU;
		TRUNCATE TABLE Result.MeasureEventDetail;
		TRUNCATE TABLE Result.MeasureProviderSummary;
		TRUNCATE TABLE Result.MeasureSummary;
		TRUNCATE TABLE Result.MemberMonthDetail;
		TRUNCATE TABLE Result.MemberMonthSummary;
		TRUNCATE TABLE Result.MetricMonthSummary;
		TRUNCATE TABLE Result.RiskHCCDetail;
		TRUNCATE TABLE Result.SystematicSamples;
				
		COMMIT TRANSACTION TResetEngine;
								
		EXEC dbo.RebuildIndexes;
		EXEC dbo.RefreshStatistics;		
		
		UPDATE TOP (1) Engine.Settings SET LastResetDate = GETDATE() WHERE EngineID = 1; 
								
		RETURN 0;
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
											@PerformRollback = 1,
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
GRANT EXECUTE ON  [Engine].[ResetEngine] TO [Processor]
GO
GRANT EXECUTE ON  [Engine].[ResetEngine] TO [Submitter]
GO
