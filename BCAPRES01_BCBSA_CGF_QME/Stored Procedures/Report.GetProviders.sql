SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/9/2011
-- Description:	Retrieves the viewable providers based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetProviders]
(
	@DataRunID int,
	@MedGrpID int = NULL,
	@RegionName varchar(64) = NULL,
	@SubRegionName varchar(64) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
	
		DECLARE @DescrLength smallint;
		DECLARE @IDLength smallint;
		
		SET @DescrLength = 45;
		SET @IDLength = 14;
		
		SELECT @IDLength = MAX(LEN(CustomerProviderID)) + 1 FROM Result.DataSetProviderKey WHERE (DataRunID = @DataRunID);
		
		SELECT	'(All Providers)' AS Descr, CAST(NULL AS int) AS ID,
				'(All Providers)' AS ProviderName
		UNION ALL
		SELECT DISTINCT	TOP 200
				CASE 
					WHEN LEN(ProviderName) > (@DescrLength - @IDLength) THEN
						LEFT(
								LEFT(CustomerProviderID, @IDLength) + REPLICATE(' ', @IDLength - LEN(LEFT(CustomerProviderID, @IDLength))) +  '  ' + ProviderName, 
								@DescrLength - 3
							) + '...'
					ELSE
						LEFT(CustomerProviderID, @IDLength) + REPLICATE(' ', @IDLength - LEN(LEFT(CustomerProviderID, @IDLength))) +  '  ' + ProviderName
					END AS Descr, 
				RDSPK.DSProviderID AS ID,
				RDSPK.ProviderName
		FROM	Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
				INNER JOIN Result.DataSetMemberProviderKey AS RDSMPK WITH(NOLOCK)
						ON RDSMGK.DataRunID = RDSMPK.DataRunID AND
							RDSMGK.DataSetID = RDSMPK.DataSetID AND
							RDSMGK.MedGrpID = RDSMPK.MedGrpID
				INNER JOIN Result.DataSetProviderKey AS RDSPK WITH(NOLOCK)
						ON RDSMPK.DataRunID = RDSPK.DataRunID AND
							RDSMPK.DataSetID = RDSPK.DataSetID AND
							RDSMPK.DSProviderID = RDSPK.DSProviderID
		WHERE	(RDSMGK.DataRunID = @DataRunID) AND
				((@MedGrpID IS NULL) OR ((RDSMPK.MedGrpID = @MedGrpID) AND (RDSMGK.MedGrpID = @MedGrpID))) AND
				((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName)) AND
				((@SubRegionName IS NULL) OR (RDSMGK.SubRegionName = @SubRegionName))
		ORDER BY ProviderName;
	
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
GRANT EXECUTE ON  [Report].[GetProviders] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetProviders] TO [Reports]
GO
