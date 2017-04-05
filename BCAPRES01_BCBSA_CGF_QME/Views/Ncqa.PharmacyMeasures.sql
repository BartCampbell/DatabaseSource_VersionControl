SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Ncqa].[PharmacyMeasures] AS
WITH PharmacyEventCriteria AS
(
	SELECT DISTINCT
			MVCC.EventCritID, MVC.MeasureSetID
	FROM	Measure.EventCriteriaCodes AS MVCC
			INNER JOIN Measure.EventCriteria AS MVC
					ON MVCC.EventCritID = MVC.EventCritID
			INNER JOIN Claim.CodeTypes AS CCT
					ON MVCC.CodeTypeID = CCT.CodeTypeID 
	WHERE	CCT.CodeType = 'N'
	UNION 
	SELECT DISTINCT
			MVC.EventCritID, MVC.MeasureSetID
	FROM	Measure.EventCriteria AS MVC
			INNER JOIN Claim.ClaimTypes AS CCT
					ON MVC.ClaimTypeID = CCT.ClaimTypeID
	WHERE	CCT.Abbrev = 'P'
),
PharmacyEvents AS
(
	SELECT DISTINCT
			MV.EventID, MV.MeasureSetID
	FROM	PharmacyEventCriteria AS PVC
			INNER JOIN Measure.EventOptions AS MVO
					ON PVC.EventCritID = MVO.EventCritID
			INNER JOIN Measure.[Events] AS MV
					ON MVO.EventID = MV.EventID AND
						PVC.MeasureSetID = MV.MeasureSetID
)
SELECT DISTINCT
		MM.Abbrev AS Measure, MM.MeasureID, MM.MeasureSetID
FROM	PharmacyEvents AS PV
		INNER JOIN Measure.Entities AS ME
				ON PV.MeasureSetID = ME.MeasureSetID
		INNER JOIN Measure.EntityCriteria AS MEC
				ON ME.EntityID = MEC.EntityID AND
					MEC.DateComparerInfo = PV.EventID
		INNER JOIN Measure.DateComparers AS MDC
				ON MEC.DateComparerID = MDC.DateComparerID
		INNER JOIN Measure.DateComparerTypes AS MDCT
				ON MDC.DateCompTypeID = MDCT.DateCompTypeID
		INNER JOIN Measure.EntityToMetricMapping AS METMM
				ON ME.EntityID = METMM.EntityID
		INNER JOIN Measure.Metrics AS MX
				ON METMM.MetricID = MX.MetricID
		INNER JOIN Measure.Measures AS MM
				ON MX.MeasureID = MM.MeasureID AND
					ME.MeasureSetID = MM.MeasureSetID
WHERE	MDCT.Abbrev = 'V'
				
GO
