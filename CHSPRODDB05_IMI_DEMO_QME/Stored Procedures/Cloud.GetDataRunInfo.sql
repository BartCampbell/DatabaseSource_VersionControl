SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/12/2012
-- Description:	Returns data set, data run, and batch information for the specified data run.
-- =============================================
CREATE PROCEDURE [Cloud].[GetDataRunInfo]
(
	@Data xml = NULL OUTPUT,
	@DataRunGuid uniqueidentifier = NULL,
	@DataRunID int = NULL,
	@IsSubmitted bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		IF @DataRunGuid IS NULL AND @DataRunID IS NULL
			RAISERROR('The data run was not specified.', 16, 1);
		
		DECLARE @DataSetID int;
		
		SELECT TOP 1 
				@DataRunGuid = DataRunGuid,
				@DataRunID = DataRunID,
				@DataSetID = DataSetID 
		FROM	Batch.DataRuns 
		WHERE	((@DataRunGuid IS NULL) OR (DataRunGuid = @DataRunGuid)) AND 
				((@DataRunID IS NULL) OR (DataRunID = @DataRunID));

		IF @DataRunGuid IS NULL
			RAISERROR('The specified data run is invalid.', 16, 1);

		IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.[Batches] WHERE DataRunID = @DataRunID)
			RAISERROR('The specified data run does not have any batches.', 16, 1);

		SET @Data = 
					(
						SELECT	BDS.DataSetGuid AS id,
								BDS.CountClaimCodes AS countclaimcodes,
								BDS.CountClaimLines AS countclaimlines,
								BDS.CountEnrollment AS countenrollment,
								BDS.CountMemberAttribs AS countmemberattributes,
								BDS.CountMembers AS countmembers,
								BDS.CountProviders AS countproviders,
								BDS.CreatedBy AS createdby,
								BDS.CreatedDate AS createddate,
								BDO.OwnerGuid AS [owner],
								(
									SELECT	BDR.DataRunGuid AS id,
											BDR.[BatchSize] AS [batchsize],
											BDR.BeginInitSeedDate AS beginseeddate,
											BDR.BeginTime AS begintime,
											dbo.ConvertBitToYN(BDR.CalculateMbrMonths) AS calculatemembermonths,
											BDR.CountBatches AS countbatches,
											BDR.CreatedBy AS createdby,
											BDR.CreatedDate AS createddate,
											PB.BenefitGuid AS defaultbenefit,
											BDR.EndInitSeedDate AS endseeddate,
											BDR.EndTime AS endtime,
											CFF1.FileFormatGuid AS fileformat,
											MMS.MeasureSetGuid AS measureset,
											MMM.MbrMonthGuid AS membermonths,
											CFF2.FileFormatGuid AS returnfileformat,
											BDR.SeedDate AS seeddate,
											(
												SELECT	BB.BatchGuid AS id,
														BB.CountClaimCodes AS countclaimcodes,
														BB.CountClaimLines AS countclaimlines,
														BB.CountEnrollment AS countenrollment,
														BB.CountItems AS countitems,
														BB.CountMeasures AS countmeasures,
														BB.CountMembers AS countmembers,
														BB.CountProviders AS countproviders
												FROM	Batch.[Batches] AS BB WITH(NOLOCK)
												WHERE	BB.DataRunID = BDR.DataRunID
												FOR XML RAW ('batch'), TYPE
											)
									FROM	Batch.DataRuns AS BDR WITH(NOLOCK)
											INNER JOIN Product.Benefits AS PB WITH(NOLOCK)
													ON BDR.DefaultBenefitID = PB.BenefitID
											INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
													ON BDR.MeasureSetID = MMS.MeasureSetID
											INNER JOIN Measure.MemberMonths AS MMM WITH(NOLOCK)
													ON BDR.MbrMonthID = MMM.MbrMonthID
											LEFT OUTER JOIN Cloud.FileFormats AS CFF1 WITH(NOLOCK)
													ON BDR.FileFormatID = CFF1.FileFormatID
											LEFT OUTER JOIN Cloud.FileFormats AS CFF2 WITH(NOLOCK)
													ON BDR.ReturnFileFormatID = CFF2.FileFormatID
									WHERE	(BDR.DataSetID = BDS.DataSetID) AND
											(BDR.DataRunID = @DataRunID)
									FOR XML RAW ('run'), TYPE
								)
						FROM	Batch.DataSets AS BDS WITH(NOLOCK)
								INNER JOIN Batch.DataOwners AS BDO WITH(NOLOCK)
										ON BDS.OwnerID = BDO.OwnerID
						WHERE	BDS.DataSetID = @DataSetID
						FOR XML RAW ('dataset'), TYPE
					);
		
		IF @IsSubmitted = 1
			UPDATE	Batch.DataRuns SET IsSubmitted = 1, SubmittedDate = GETDATE() WHERE DataRunID = @DataRunID;
		
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
GRANT EXECUTE ON  [Cloud].[GetDataRunInfo] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetDataRunInfo] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRunInfo] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRunInfo] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRunInfo] TO [Submitter]
GO
