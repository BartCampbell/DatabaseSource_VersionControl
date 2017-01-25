SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MetricDesc]

AS

SELECT DISTINCT
		cm.MeasureMetricDesc
	FROM CGF.ResultsByMember rbm
		INNER JOIN CGF.MeasureMetrics cm
			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
	WHERE rbm.IsDenominator = 1 
	ORDER BY cm.MeasureMetricDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MetricDesc] TO [db_ViewProcedures]
GO
