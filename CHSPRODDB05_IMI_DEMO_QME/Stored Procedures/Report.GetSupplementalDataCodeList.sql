SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/8/2015
-- Description:	Returns a list of the custom IMI supplemental data codes and the metrics effected by them.  
-- =============================================
CREATE PROCEDURE [Report].[GetSupplementalDataCodeList]
AS
BEGIN
	SET NOCOUNT ON;

    WITH Results AS
	(
		SELECT DISTINCT
				MX.Abbrev + ' - ' + MX.Descr AS [Metric],
				MX.Abbrev AS [MetricAbbrev],
				MMT.Descr AS [Mapping Type],
				--ME.EntityID AS [Entity ID],
				--ME.Descr AS [Entity],
				--MV.EventID AS [Event ID], 
				--MV.Descr AS [Event],
				MVC.EventCritID AS [Event Criteria ID],
				MVC.Descr AS [Event Criteria],
				CCT.Descr AS [Code Type],
				MVCC.Code,
				REPLACE(Provider.ConvertBitSpecialtiesToDescr(MVCS.BitSpecialties), ' :: ', ' or ') AS [Required Specialty],
				MVCVT.Descr AS [Value Type],
				MVC.DefaultValue AS [Default Value],
				MVCC.Value
		FROM	Measure.EventCriteria AS MVC WITH(NOLOCK)
				INNER JOIN Measure.EventOptions AS MVO
						ON MVO.EventCritID = MVC.EventCritID
				INNER JOIN Measure.Events AS MV WITH(NOLOCK)
						ON MV.EventID = MVO.EventID
				INNER JOIN Measure.EventCriteriaCodes AS MVCC WITH(NOLOCK) 
						ON MVCC.EventCritID = MVC.EventCritID
				INNER JOIN Claim.CodeTypes AS CCT
						ON CCT.CodeTypeID = MVCC.CodeTypeID
				INNER JOIN Measure.EntityCriteria AS MEC WITH(NOLOCK)
						ON MEC.DateComparerInfo = MV.EventID AND
							MEC.AllowSupplemental = 1
				OUTER APPLY	(
								SELECT	SUM(DISTINCT tPS.BitValue) AS BitSpecialties
								FROM	Measure.EventCriteriaSpecialties AS tMVCS WITH(NOLOCK)
										INNER JOIN Provider.Specialties AS tPS WITH(NOLOCK)
												ON tPS.SpecialtyID = tMVCS.SpecialtyID
								WHERE	tMVCS.EventCritID = MVC.EventCritID
							) AS MVCS
				INNER JOIN Measure.Entities AS ME WITH(NOLOCK)
						ON ME.EntityID = MEC.EntityID AND
							ME.MeasureSetID = MV.MeasureSetID
				INNER JOIN Measure.EntityToMetricMapping AS METMM WITH(NOLOCK)
						ON METMM.EntityID = ME.EntityID
				INNER JOIN Measure.MappingTypes AS MMT
						ON MMT.MapTypeID = METMM.MapTypeID
				INNER JOIN Measure.Metrics AS MX WITH(NOLOCK)
						ON MX.MetricID = METMM.MetricID
				LEFT OUTER JOIN Measure.EventCriteriaValueTypes AS MVCVT
						ON MVCVT.ValueTypeID = MVC.ValueTypeID
		WHERE	(MVCC.CodeTypeID = (SELECT CodeTypeID FROM Claim.CodeTypes WHERE CodeType = '!')) AND
				ME.IsEnabled = 1 AND
				MV.IsEnabled = 1 AND
				MVO.IsEnabled = 1 AND
				MX.IsEnabled = 1
	),
	CodeCount AS 
	(
		SELECT	Code,
				dbo.Concatenate(MetricAbbrev, ', ') AS [Metric List],
				COUNT(DISTINCT Metric) AS [Metric Count]
		FROM	Results
		GROUP BY Code
	)
	SELECT	t.Metric,
			t.[Mapping Type],
			t.[Event Criteria ID],
			t.[Event Criteria],
			t.[Code Type],
			t.Code,
			t.[Required Specialty],
			t.[Value Type],
			t.[Default Value],
			t.Value,
			CASE WHEN c.[Metric Count] > 1 THEN 'Y' ELSE 'N' END AS [Multiple Metrics],
			c.[Metric List]
	FROM	Results AS t
			INNER JOIN CodeCount AS c
					ON c.Code = t.Code
	ORDER BY [Metric], [Code Type], [Code], [Event Criteria]
END

GO
GRANT VIEW DEFINITION ON  [Report].[GetSupplementalDataCodeList] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataCodeList] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataCodeList] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSupplementalDataCodeList] TO [Reports]
GO
