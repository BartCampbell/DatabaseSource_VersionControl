SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Export].[MetricScoring] AS 
WITH GeneralMeasureReason AS
(
	SELECT 'Excluded due to measure-specific criteria identified from the medical record' AS GeneralReason
)
SELECT TOP (100) PERCENT
		MBR.CustomerMemberID,
		MBR.ProductLine,
		MBR.Product,
		MMMS.MemberMeasureSampleID AS ChartNetSampleID,
		MMMS.MemberMeasureMetricScoringID AS IMIReferenceNumber,
		MX.HEDISMeasureInit AS Measure,
		MX.HEDISSubMetricCode AS Metric,
		MX.HEDISSubMetricDescription AS MetricDescription,
		MMS.EventDate,
		MMS.SampleType,
		MMS.SampleDrawOrder,
		MMMS.Denominator,
		MMMS.AdministrativeHit AS NumeratorAdmin,
		MMMS.MedicalRecordHit AS NumeratorMedicalRecord,
		MMMS.HybridHit AS NumeratorHybrid,
		MMMS.ReqExclusion AS RequiredExclusion,
		CASE WHEN MMMS.ReqExclusion = 1 THEN MMMS.ReqExclReason END AS RequiredExclusionReason,
		MMMS.Exclusion,
		CASE WHEN MMMS.Exclusion = 1 THEN MMMS.ExclusionReason END AS ExclusionReason,
		MMMS.SampleVoid,
		CASE WHEN MMMS.SampleVoid = 1 THEN MMMS.SampleVoidReason END AS SampleVoidReason,
		CASE WHEN MMMS.Exclusion  = 1 OR MMMS.SampleVoid = 1 THEN 1 ELSE 0 END ReportedExclusion,
		CASE WHEN MMMS.SampleVoid = 1 THEN MMMS.SampleVoidReason WHEN MMMS.Exclusion = 1 THEN t.GeneralReason END AS ReportedExclusionReason,
		CASE WHEN (MMMS.ExclusionCount > 0 AND MMMS.Exclusion = 0) OR (MMMS.SampleVoidCount > 0 AND MMMS.SampleVoid = 0) THEN 1 ELSE 0 END AS UnreportedExclusion,
		CASE WHEN MMMS.SampleVoidCount > 0 AND MMMS.SampleVoid = 0 THEN MMMS.SampleVoidReason WHEN MMMS.ExclusionCount > 0 AND MMMS.Exclusion = 0 THEN t.GeneralReason END AS UnreportedExclusionReason,
		CONVERT(BIT, CASE WHEN (MMMS.Denominator = 1 OR MMMS.Exclusion = 1 OR MMMS.SampleVoid = 1) AND MMS.SampleType LIKE '%over%' THEN 1 ELSE 0 END) AS IsFromOversample
FROM	dbo.MemberMeasureSample AS MMS
		INNER JOIN dbo.Member AS MBR
				ON MMS.MemberID = MBR.MemberID
		INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS
				ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
		INNER JOIN dbo.HEDISSubMetric AS MX
				ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
		CROSS JOIN GeneralMeasureReason AS t
ORDER BY CustomerMemberID, Measure, Metric;





GO
