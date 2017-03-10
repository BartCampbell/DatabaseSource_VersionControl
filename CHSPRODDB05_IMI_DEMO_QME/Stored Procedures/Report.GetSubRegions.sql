SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/9/2011
-- Description:	Retrieves the viewable sub regions based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetSubRegions]
(
	@DataRunID int,
	@RegionName varchar(64) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	'(All Sub Regions)' AS Descr, CAST(NULL AS varchar(64)) AS ID
		UNION ALL
		SELECT	'(No Medical Group Assigned)' AS Descr, CAST('(No Medical Group Assigned)' AS varchar(64)) AS ID
		UNION ALL
		SELECT DISTINCT	
				RDSMGK.SubRegionName AS Descr, 
				RDSMGK.SubRegionName AS ID
		FROM	Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
		WHERE	(RDSMGK.DataRunID = @DataRunID) AND
				((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName))
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
GRANT VIEW DEFINITION ON  [Report].[GetSubRegions] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSubRegions] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSubRegions] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSubRegions] TO [Reports]
GO
