SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxMeasureMetricDesc] AS

SELECT TOP 1 MeasureMetricDesc
	FROM CGF.ResultsByMember rbm
	WHERE IsDenominator = 1
		AND rbm.Measure = 'CDC'
	GROUP BY MeasureMetricDesc
	ORDER BY COUNT(*) desc


GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MaxMeasureMetricDesc] TO [db_ViewProcedures]
GO
