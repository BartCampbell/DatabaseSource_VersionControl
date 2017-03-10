SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the viewable top-level measure classes based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetTopMeasureClasses]
(
	@DataRunID int,
	@PopulationID int,
	@ProductLineID smallint
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	'(All Classes)' AS Descr, CAST(NULL AS smallint) AS ID
		UNION ALL
		SELECT DISTINCT	
				TopMeasClassDescr AS Descr, TopMeasClassID AS ID
		FROM	Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
		WHERE	(RDSXK.DataRunID = @DataRunID) AND
				(RDSXK.PopulationID = @PopulationID) AND
				(RDSXK.ProductLineID = @ProductLineID)
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
GRANT VIEW DEFINITION ON  [Report].[GetTopMeasureClasses] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetTopMeasureClasses] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetTopMeasureClasses] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetTopMeasureClasses] TO [Reports]
GO
