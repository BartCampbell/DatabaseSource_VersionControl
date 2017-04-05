SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Batch].[ItemSource] AS
WITH	PossibleMeasures AS
(
	SELECT DISTINCT
			MeasureID
	FROM	Measure.Metrics AS MX
			INNER JOIN Measure.EntityToMetricMapping AS MEXM
					ON MX.MetricID = MEXM.MetricID
)
SELECT	M.DataSetID, M.DSMemberID, t.MeasureID
FROM	Member.Members AS M
		INNER JOIN Batch.DataSets AS DS
				ON M.DataSetID = DS.DataSetID
		INNER JOIN Measure.Measures AS t
				ON DS.MeasureSetID = t.MeasureSetID AND
					t.MeasureID IN (SELECT MeasureID FROM PossibleMeasures);


GO
