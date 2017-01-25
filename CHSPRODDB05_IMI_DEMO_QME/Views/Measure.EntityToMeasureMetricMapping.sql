SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Measure].[EntityToMeasureMetricMapping] AS
WITH EntityToMetricMapping AS
(
	SELECT	METMM.EntityID,
            METMM.MapTypeID,
			MX.MeasureID,
            METMM.MetricID
	FROM	Measure.EntityToMetricMapping AS METMM WITH(NOLOCK)
			INNER JOIN Measure.Metrics AS MX WITH(NOLOCK)
					ON MX.MetricID = METMM.MetricID
)
SELECT	ME.*, MME.MeasureID, METMM.MapTypeID, METMM.MetricID
FROM	Measure.Entities AS ME
		INNER JOIN Measure.GetMeasureEntities(DEFAULT, DEFAULT, DEFAULT) AS MME 
				ON MME.EntityID = ME.EntityID 
		LEFT OUTER JOIN EntityToMetricMapping AS METMM
				ON METMM.EntityID = MME.EntityID AND
					METMM.MeasureID = MME.MeasureID
GO
