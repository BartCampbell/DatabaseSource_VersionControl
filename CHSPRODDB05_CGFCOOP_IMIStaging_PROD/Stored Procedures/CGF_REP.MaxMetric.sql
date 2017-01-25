SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [CGF_REP].[MaxMetric]
AS

SELECT DISTINCT
		TOP 1 cm.MeasureMetricDesc
	FROM CGF.ResultsByMember rbm
		INNER JOIN CGF.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
	WHERE rbm.IsDenominator = 1 
	ORDER BY cm.MeasureMetricDesc

GO
