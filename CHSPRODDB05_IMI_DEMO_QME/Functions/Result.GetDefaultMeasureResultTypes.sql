SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/14/2013
-- Description:	Returns the default result type for the list of measures associated with the specified data run(s).
-- =============================================
CREATE FUNCTION [Result].[GetDefaultMeasureResultTypes] 
(	
	@DataRunID int = NULL,
	@OverrideResultTypeID tinyint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH Results AS
	(
		SELECT DISTINCT
				t.DataRunID,
				t.DataSetID,
				t.MeasureID,
				t.MeasureXrefID,
				--PopulationID,
				t.ResultTypeID
		FROM	Result.MeasureSummary AS t WITH(NOLOCK)
				INNER JOIN Measure.Metrics AS MX
						ON MX.MetricID = t.MetricID AND
							MX.IsShown = 1
		UNION 
		SELECT DISTINCT
				t.DataRunID,
				t.DataSetID,
				t.MeasureID,
				t.MeasureXrefID,
				--PopulationID, 
				t.ResultTypeID
		FROM	Result.MeasureDetail AS t WITH(NOLOCK)
				INNER JOIN Measure.Metrics AS MX
						ON MX.MetricID = t.MetricID AND
							MX.IsShown = 1
		WHERE	(DataRunID NOT IN (SELECT DISTINCT DataRunID FROM Result.MeasureSummary))
	)
	SELECT	DataRunID,
			DataSetID,
			MeasureID,
			MeasureXrefID,
			NULL AS PopulationID,
			ISNULL(@OverrideResultTypeID, MAX(ResultTypeID)) AS ResultTypeID
	FROM	Results 
	WHERE	((@DataRunID IS NULL) OR (DataRunID = @DataRunID))
	GROUP BY DataRunID, 
			DataSetID, 
			MeasureID, 
			MeasureXrefID--,
			--PopulationID
)
GO
