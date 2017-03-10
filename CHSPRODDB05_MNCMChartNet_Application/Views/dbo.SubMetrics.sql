SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[SubMetrics]

AS

SELECT	M.MeasureID
		,H.HEDISSubMetricID
		,M.HEDISMeasure
		,H.HEDISSubMetricCode AS SubMetric
		,CAST(NULL as Bit) as Passed

FROM	dbo.Measure M
JOIN	dbo.HEDISSubMetric H ON M.MeasureID = H.MeasureID


GO
