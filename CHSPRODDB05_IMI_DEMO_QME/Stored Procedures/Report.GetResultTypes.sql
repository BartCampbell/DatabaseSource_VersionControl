SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the viewable result types based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetResultTypes]
(
	@DataRunID int,
	@MeasureID int = NULL,
	@MetricID int = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@SubMeasClassID smallint = NULL,
	@TopMeasClassID smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	'(Measure Default)' AS Descr, CAST(NULL AS tinyint) AS ID, 0 AS SortOrder
		UNION ALL 
		SELECT	Measure.GetResultTypeDescription(255) AS Descr, CAST(255 AS tinyint) AS ID, 1 AS SortOrder
		UNION ALL
		SELECT DISTINCT	
				Measure.GetResultTypeDescription(ResultTypeID) AS Descr, 
				ResultTypeID AS ID, 2 AS SortOrder
		FROM	Result.MeasureSummary AS RMS WITH(NOLOCK)
				INNER JOIN Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
						ON RMS.DataSetID = RDSXK.DataSetID AND
							RMS.DataRunID = RDSXK.DataRunID AND
							RMS.MeasureID = RDSXK.MeasureID AND
							RMS.MetricID = RDSXK.MetricID AND
							RMS.PopulationID = RDSXK.PopulationID AND
							RMS.ProductLineID = RDSXK.ProductLineID AND
							((RMS.AgeBandSegID = RDSXK.AgeBandSegID) OR (RDSXK.AgeBandSegID IS NULL))
		WHERE	(RMS.DataRunID = @DataRunID) AND
				((@MeasureID IS NULL) OR (RMS.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RMS.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RMS.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RMS.ProductLineID = @ProductLineID)) AND
				(RMS.ResultTypeID IN (2, 3)) AND
				((@SubMeasClassID IS NULL) OR (RDSXK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSXK.TopMeasClassID = @TopMeasClassID))
		ORDER BY SortOrder, ID;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetResultTypes] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetResultTypes] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetResultTypes] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetResultTypes] TO [Reports]
GO
