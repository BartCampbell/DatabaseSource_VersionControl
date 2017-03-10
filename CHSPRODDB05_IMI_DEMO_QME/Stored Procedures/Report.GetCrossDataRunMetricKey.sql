SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/20/2012
-- Description:	Retrieves the viewable populations for the specified datarun.
-- =============================================
CREATE PROCEDURE [Report].[GetCrossDataRunMetricKey]
(
	@FromDataRunID int,
	@PopulationID int = NULL,
	@ToDataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	*
		INTO	#CrossDataRunMetricKey
		FROM	Result.GetCrossDataRunMetricKey(@FromDataRunID, @ToDataRunID);
		
		WITH MeasureProductLines AS
		(
			SELECT	MeasureAbbrev,
					PopulationID,
					MIN(ProductLineID) AS ProductLineID
			FROM	#CrossDataRunMetricKey
			GROUP BY MeasureAbbrev,
					PopulationID
		),
		--TotalMeasures: Allows for all measures from a specific product line to be selected in the dashboard
		TotalMeasures AS
		(
			SELECT	MIN(DR1.MeasureSetDescr + ': ' + DR1.OwnerDescr + + ' (' + DR1.DataRunDescr + ')') AS FromDataRun,
					NULL AS FromMeasureID,
					CONVERT(bit, 1) AS IsAll,
					CONVERT(varchar(64), 'All Measures by Product Line') AS MeasClassDescr,
					CONVERT(int, -1) AS MeasClassID,
					CONVERT(varchar(16), MIN(PPL.Descr)) AS MeasureAbbrev,
					CONVERT(varchar(128), 'Complete List of All ' + MIN(PPL.Descr) + ' Measures') AS MeasureDescr,
					MIN(ISNULL(RDSPK1.PopulationNum + ', ' + RDSPK1.Descr, RDSPK2.PopulationNum + ', ' + RDSPK2.Descr)) AS PopulationDescr,
					t.PopulationID,
					t.ProductLineID,
					MIN(DR2.MeasureSetDescr + ': ' + DR2.OwnerDescr + ' (' + DR2.DataRunDescr + ')') AS ToDataRun,
					NULL AS ToMeasureID
			FROM	#CrossDataRunMetricKey AS t
					INNER JOIN Result.ProductLines AS PPL WITH(NOLOCK)
							ON t.ProductLineID = PPL.ProductLineID
					LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK1 WITH(NOLOCK)
						ON t.ToDataRunID = RDSPK1.DataRunID AND
							t.PopulationID = RDSPK1.PopulationID
					LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK2 WITH(NOLOCK)
						ON t.ToDataRunID = RDSPK2.DataRunID AND
							t.PopulationID = RDSPK2.PopulationID
					INNER JOIN Result.DataSetRunKey AS DR1 WITH(NOLOCK)
							ON DR1.DataRunID = @FromDataRunID AND
								DR1.IsShown = 1
					INNER JOIN Result.DataSetRunKey AS DR2 WITH(NOLOCK)
							ON DR2.DataRunID = @ToDataRunID AND
								DR2.IsShown = 1
			WHERE	((@PopulationID IS NULL) OR (t.PopulationID = @PopulationID)) AND
					((RDSPK1.PopulationID IS NOT NULL) OR (RDSPK2.PopulationID IS NOT NULL)) 
			GROUP BY t.PopulationID, t.ProductLineID
		)
		--SELECT	tm.FromDataRun,
		--		tm.FromMeasureID,
		--		tm.IsAll,
		--		tm.MeasClassDescr,
		--		tm.MeasClassID,
		--		tm.MeasureAbbrev,
		--		tm.MeasureDescr,
		--		tm.PopulationDescr,
		--		tm.PopulationID,
		--		tm.ProductLineID,
		--		CONVERT(bit, 0) AS ShowGraphs,
		--		tm.ToDataRun,
		--		tm.ToMeasureID
		--FROM	TotalMeasures AS tm
		--UNION ALL
		SELECT	MIN(DR1.MeasureSetDescr + ': ' + DR1.OwnerDescr + + ' (' + DR1.DataRunDescr + ')') AS FromDataRun,
				MIN(RMS1.MeasureID) AS FromMeasureID,
				CONVERT(bit, 0) AS IsAll,
				MIN(t.MeasClassDescr) AS MeasClassDescr,
				MIN(t.MeasClassID) AS MeasClassID,
				t.MeasureAbbrev,
				MIN(t.MeasureDescr) AS MeasureDescr,
				MIN(ISNULL(RDSPK1.PopulationNum + ', ' + RDSPK1.Descr, RDSPK2.PopulationNum + ', ' + RDSPK2.Descr)) AS PopulationDescr,
				t.PopulationID,
				t.ProductLineID,
				CONVERT(bit, 0) AS ShowGraphs,
				MIN(DR2.MeasureSetDescr + ': ' + DR2.OwnerDescr + ' (' + DR2.DataRunDescr + ')') AS ToDataRun,
				MIN(RMS2.MeasureID) AS ToMeasureID
		FROM	#CrossDataRunMetricKey AS t
				INNER JOIN MeasureProductLines AS MPL
						ON t.MeasureAbbrev = MPL.MeasureAbbrev AND
							t.PopulationID = MPL.PopulationID AND
							t.ProductLineID = MPL.ProductLineID
				INNER JOIN Result.DataSetRunKey AS DR1
						ON DR1.DataRunID = @FromDataRunID AND
							DR1.IsShown = 1
				INNER JOIN Result.DataSetRunKey AS DR2
						ON DR2.DataRunID = @ToDataRunID AND
							DR2.IsShown = 1
				LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK1
						ON t.FromDataRunID = RDSPK1.DataRunID AND
							t.PopulationID = RDSPK1.PopulationID
				LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK2
						ON t.ToDataRunID = RDSPK1.DataRunID AND
							t.PopulationID = RDSPK1.PopulationID
				LEFT OUTER JOIN Report.MeasureSettings AS RMS1
						ON t.FromMeasureID = RMS1.MeasureID AND
							RMS1.ShowOnReport = 1
				LEFT OUTER JOIN Report.MeasureSettings AS RMS2
						ON t.ToMeasureID = RMS2.MeasureID AND
							RMS2.ShowOnReport = 1
		WHERE	((@PopulationID IS NULL) OR (t.PopulationID = @PopulationID)) AND
				((RMS1.MeasureID IS NOT NULL) OR (RMS2.MeasureID IS NOT NULL))
		GROUP BY t.MeasureAbbrev,
				t.PopulationID,
				t.ProductLineID
		HAVING	((MIN(RDSPK1.PopulationID) IS NOT NULL) OR (MIN(RDSPK2.PopulationID) IS NOT NULL))
		ORDER BY PopulationDescr,
				IsAll DESC,
				MeasClassDescr,
				MeasureAbbrev;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetCrossDataRunMetricKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunMetricKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunMetricKey] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunMetricKey] TO [Reports]
GO
