SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[AbstractionManagementConsoleMeasure]
AS
SELECT  HSM.HEDISMeasureInit,
        HSM.HEDISSubMetricCode HEDISSubMetric,
		HSM.ReportName AS DisplayName,
		SUM(CONVERT(int, MMMS.Denominator)) AS Denominator,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.AdministrativeHit > 0 THEN 1 ELSE 0 END) AS AdministrativeHit,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.MedicalRecordHit > 0 THEN 1 ELSE 0 END) AS MedicalRecordHit,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.HybridHit > 0 THEN 1 ELSE 0 END) AS HybridHit,
        ((SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.HybridHit > 0 THEN 1 ELSE 0 END * 100.00) / SUM(CONVERT(int, MMMS.Denominator))) / 100) AS [Rate],
		SUM(CONVERT(int, MMMS.ReqExclusion)) AS ReqExclusion,
		SUM(CONVERT(int, MMMS.Exclusion)) AS Exclusion,
		SUM(CONVERT(int, MMMS.SampleVoid)) AS SampleVoid
FROM    MemberMeasureSample MMS
JOIN	MemberMeasureMetricScoring MMMS
		ON	MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
JOIN	HEDISSubMetric HSM ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID
GROUP BY HSM.HEDISMeasureInit, HSM.HEDISSubMetricCode, HSM.DisplayName, HSM.ReportName


GO
