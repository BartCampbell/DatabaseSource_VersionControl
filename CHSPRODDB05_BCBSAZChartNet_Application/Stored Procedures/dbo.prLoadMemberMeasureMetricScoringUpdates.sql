SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[prLoadMemberMeasureMetricScoringUpdates]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: MemberMeasureMetricScoring, 
from Client Import table: MemberMeasureMetricScoring
*/
--select * from MemberMeasureMetricScoring
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO MemberMeasureMetricScoring
        (MemberMeasureSampleID,
         HEDISSubMetricID,
         DenominatorCount,
         AdministrativeHitCount,
         MedicalRecordHitCount,
         HybridHitCount,
		 PreExclusionAdmin,
		 PreExclusionValidData,
		 PreExclusionPlanEmployee,
		 SuppIndicator)
        SELECT  MemberMeasureSampleID = d.MemberMeasureSampleID,
                HEDISSubMetricID = e.HEDISSubMetricID,
                DenominatorCount = 1,
                AdministrativeHitCount = AdministrativeHitCount,
                MedicalRecordHitCount = MedicalRecordHitCount,
                HybridHitCount = HybridHitCount,
				a.ExclusionAdmin,
				a.ExclusionValidDataError,
				a.ExclusionPlanEmployee,
				SuppIndicator = a.SuppIndicator
        FROM    RDSM.MemberMeasureMetricScoringUpdatedDates a
                INNER JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID AND
                                       a.ProductLine = b.ProductLine AND
                                       a.Product = b.Product
                INNER JOIN Measure c ON a.HEDISMeasure = c.HEDISMeasure
                INNER JOIN MemberMeasureSample d ON b.MemberID = d.MemberID AND
                                                    c.MeasureID = d.MeasureID AND
                                                    a.EventDate = d.EventDate
                INNER JOIN HEDISSubMetric e ON a.HEDISSubMetric = e.HEDISSubMetricCode AND
                                               e.HEDISSubMetricID NOT IN (
                                               '222', '509')

UPDATE	MMMS
SET		DenominatorCount = 0
FROM	dbo.MemberMeasureMetricScoring AS MMMS
		INNER JOIN dbo.HEDISSubMetric AS MX
				ON MX.HEDISSubMetricID = MMMS.HEDISSubMetricID
WHERE	MX.HEDISSubMetricCode = 'CDC3' AND
		MMMS.SuppIndicator = 1;



GO
