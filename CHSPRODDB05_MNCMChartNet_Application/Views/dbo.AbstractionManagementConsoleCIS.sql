SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AbstractionManagementConsoleCIS]

AS

SELECT  HSM.HEDISMeasureInit
        ,HSM.HEDISSubMetricCode HEDISSubMetric
		,SUM(MMMS.DenominatorCount) [Sample]
        ,SUM(MMMS.AdministrativeHitCount) AdministrativeHitCount
        ,SUM(MMMS.MedicalRecordHitCount) MedicalRecordHitCount 
        ,SUM(MMMS.HybridHitCount) HybridHitCount
        ,((sum(MMMS.HybridHitCount*100.0)/sum(MMMS.DenominatorCount)) / 100) HybridRate

FROM    MemberMeasureSample MMS
JOIN	MemberMeasureMetricScoring MMMS
		ON	MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
JOIN	HEDISSubMetric HSM ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID

WHERE   HSM.HEDISMeasureInit = 'CIS'

GROUP BY HSM.HEDISMeasureInit, HSM.HEDISSubMetricCode



GO
