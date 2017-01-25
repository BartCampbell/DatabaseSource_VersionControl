SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the viewable measures based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasures]
(
	@AllowAll bit = 1,
	@DataRunID int,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@SubMeasClassID smallint = NULL,
	@TopMeasClassID smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		WITH Measures AS 
		(
			SELECT	'(All Measures)' AS Descr, CAST(NULL AS int) AS ID
			UNION ALL
			SELECT DISTINCT	
					CASE WHEN LEN(RDSXK.MeasureAbbrev + ' - ' + RDSXK.MeasureDescr) > 60 
						THEN LEFT(RDSXK.MeasureAbbrev + ' - ' + RDSXK.MeasureDescr, 57) + '...'
						ELSE RDSXK.MeasureAbbrev + ' - ' + RDSXK.MeasureDescr 
						END AS Descr, 
					RDSXK.MeasureID AS ID
			FROM	Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
					INNER JOIN Report.MeasureSettingsKey AS RMTK WITH(NOLOCK)
							ON RDSXK.MeasureID = RMTK.MeasureID AND
								RMTK.ShowOnReport = 1
			WHERE	(RDSXK.DataRunID = @DataRunID) AND
					((@PopulationID IS NULL) OR (RDSXK.PopulationID = @PopulationID)) AND
					((@ProductLineID IS NULL) OR (RDSXK.ProductLineID = @ProductLineID)) AND
					((@SubMeasClassID IS NULL) OR (RDSXK.SubMeasClassID = @SubMeasClassID)) AND
					((@TopMeasClassID IS NULL) OR (RDSXK.TopMeasClassID = @TopMeasClassID))
		)
		SELECT	Descr, ID
		FROM	Measures
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (ID IS NOT NULL)))
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
GRANT EXECUTE ON  [Report].[GetMeasures] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasures] TO [Reports]
GO
