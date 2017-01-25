SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MeasureDesc]
AS

--SELECT DISTINCT
--		cm.MeasureDesc
--	FROM cgf.resultsByMember rbm
--		INNER JOIN CGF.MeasureMetrics cm
--			ON rbm.MetricXrefGuid = cm.MetricXrefGuid
--	WHERE rbm.IsDenominator = 1 
--	ORDER BY cm.MeasureDesc

SELECT MeasureDesc
	FROM CGF.MetricDescList
	ORDER BY MeasureDesc
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MeasureDesc] TO [db_ViewProcedures]
GO
