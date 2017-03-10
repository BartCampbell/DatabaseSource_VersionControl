SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AbstractionManagementConsoleAWC]

AS

SELECT      HSM.HEDISMeasureInit
			,CAST (HSM.HEDISSubMetricID AS VARCHAR(32)) AS HEDISSubMetric
            ,SUM(MMMS.DenominatorCount) AS [Sample]
            ,SUM(MMMS.AdministrativeHitCount) AS AdministrativeHitCount
            ,SUM(MMMS.MedicalRecordHitCount) AS MedicalRecordHitCount
            ,SUM(MMMS.HybridHitCount) AS HybridHitCount
            ,(SUM(MMMS.HybridHitCount*100.0)/SUM(MMMS.DenominatorCount)) / 100 AS HybridRate

FROM  dbo.MemberMeasureMetricScoring MMMS
JOIN  dbo.HEDISSubMetric HSM ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID

WHERE HSM.HEDISMeasureInit = 'AWC'
GROUP BY HEDISMeasureInit, HSM.HEDISSubMetricID



GO
