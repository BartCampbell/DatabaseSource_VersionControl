SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/9/2011
-- Description:	Retrieves the viewable medical groups based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetMedicalGroups]
(
	@DataRunID int,
	@RegionName varchar(64) = NULL,
	@SubRegionName varchar(64) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	'(All Medical Groups)' AS Descr, CAST(NULL AS int) AS ID
		UNION ALL
		SELECT	'(No Medical Group Assigned)' AS Descr, CAST(-1 AS int) AS ID
		UNION ALL
		SELECT DISTINCT	
				LEFT(CASE WHEN @RegionName IS NULL AND @SubRegionName IS NULL 
					THEN RDSMGK.MedGrpFullName
					ELSE RDSMGK.MedGrpName 
					END, 50) AS Descr, 
				RDSMGK.MedGrpID AS ID
		FROM	Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
		WHERE	(RDSMGK.DataRunID = @DataRunID) AND
				((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName)) AND
				((@SubRegionName IS NULL) OR (RDSMGK.SubRegionName = @SubRegionName))
		ORDER BY Descr;
	
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
GRANT EXECUTE ON  [Report].[GetMedicalGroups] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMedicalGroups] TO [Reports]
GO
