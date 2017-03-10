SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/28/2013
-- Description:	Returns the list of data runs.
-- =============================================
CREATE PROCEDURE [Cloud].[GetDataRuns]
(
	@DataRunGuid uniqueidentifier = NULL,
	@DataRunID int = NULL,
	@DataRunSourceGuid uniqueidentifier = NULL,
	@DataSetGuid uniqueidentifier = NULL,
	@DataSetID int = NULL,
	@DataSetSourceGuid uniqueidentifier = NULL,
	@IsSubmitted bit = NULL,
	@OwnerGuid uniqueidentifier = NULL,
	@OwnerID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	BDR.[BatchSize],
				BDR.BeginInitSeedDate,
				BDR.BeginTime,
				BDR.CalculateMbrMonths,
				BDR.CountBatches,
				BDR.CreatedBy,
				BDR.CreatedDate,
				BDR.CreatedSpId,
				BDR.DataRunGuid,
				BDR.DataRunID,
				BDR.SourceGuid AS DataRunSourceGuid,
				BDS.DataSetGuid,
				BDR.DataSetID,
				BDS.SourceGuid AS DataSetSourceGuid,
				PB.BenefitGuid AS DefaultBenefitGuid,
				BDR.DefaultBenefitID,
				BDR.EndInitSeedDate,
				BDR.EndTime,
				CFF1.FileFormatGuid,
				BDR.FileFormatID,
				BDR.IsLogged,
				BDR.LastErrLogID,
				BDR.LastErrLogTime,
				BDR.LastProgLogID,
				BDR.LastProgLogTime,
				MMS.MeasureSetGuid,
				BDR.MeasureSetID,
				MMM.MbrMonthGuid,
				BDR.MbrMonthID,
				BDO.OwnerGuid,
				BDS.OwnerID,
				CFF2.FileFormatGuid AS ReturnFileFormatGuid,
				BDR.ReturnFileFormatID,
				BDR.SeedDate,
				BDR.SourceGuid
		FROM	Batch.DataRuns AS BDR WITH (NOLOCK)
				INNER JOIN Batch.DataSets AS BDS WITH (NOLOCK)
						ON BDR.DataSetID = BDS.DataSetID
				INNER JOIN Batch.DataOwners AS BDO WITH (NOLOCK)
						ON BDS.OwnerID = BDO.OwnerID
				LEFT OUTER JOIN Product.Benefits AS PB WITH (NOLOCK)
						ON BDR.DefaultBenefitID = PB.BenefitID
				LEFT OUTER JOIN Measure.MeasureSets AS MMS WITH (NOLOCK)
						ON BDR.MeasureSetID = MMS.MeasureSetID
				LEFT OUTER JOIN Measure.MemberMonths AS MMM WITH (NOLOCK)
						ON BDR.MbrMonthID = MMM.MbrMonthID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF1 WITH (NOLOCK)
						ON BDR.FileFormatID = CFF1.FileFormatID
				LEFT OUTER JOIN Cloud.FileFormats AS CFF2 WITH (NOLOCK)
						ON BDR.FileFormatID = CFF2.FileFormatID
				CROSS APPLY (SELECT TOP 1 t.DataSetID FROM Member.Members AS t WHERE t.DataSetID = BDS.DataSetID) AS MM
		WHERE	((@DataRunGuid IS NULL) OR (BDR.DataRunGuid = @DataRunGuid)) AND
				((@DataRunID IS NULL) OR (BDR.DataRunID = @DataRunID)) AND
				((@DataRunSourceGuid IS NULL) OR (BDR.SourceGuid = @DataRunSourceGuid)) AND
				((@DataSetGuid IS NULL) OR (BDS.DataSetGuid = @DataSetGuid)) AND
				((@DataSetID IS NULL) OR (BDS.DataSetID = @DataSetID)) AND
				((@DataSetSourceGuid IS NULL) OR (BDS.SourceGuid = @DataSetSourceGuid)) AND
				((@IsSubmitted IS NULL) OR (BDR.IsSubmitted = @IsSubmitted)) AND
				((@OwnerGuid IS NULL) OR (BDO.OwnerGuid = @OwnerGuid)) AND
				((@OwnerID IS NULL) OR (BDO.OwnerID = @OwnerID));
								
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
											@PerformRollback = 0,
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
GRANT EXECUTE ON  [Cloud].[GetDataRuns] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetDataRuns] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRuns] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRuns] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRuns] TO [Submitter]
GO
