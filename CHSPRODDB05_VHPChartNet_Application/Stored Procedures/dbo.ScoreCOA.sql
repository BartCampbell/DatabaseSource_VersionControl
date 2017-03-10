SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for COA measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the following tables:
--dbo.MedicalRecordCOACarePlan
--dbo.MedicalRecordCOAMedRev
--dbo.MedicalRecordCOAFunctAsmt
--dbo.MedicalRecordCOAPain

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCOA '78560770'

CREATE PROCEDURE [dbo].[ScoreCOA] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate();
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate();

WITH PartialFunctionIndependence (NotationType) AS
(
	SELECT 'Assessment of Cognitive Status'
	UNION 
	SELECT 'Assessment of Ambulation Status'
	UNION 
	SELECT 'Assessment of Sensory Ability'
	UNION 
	SELECT 'Assessment of Other Functional Independence'
)
SELECT * INTO #PartialFunctionIndependence FROM PartialFunctionIndependence;

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        COA_CarePlan_MR_Flag = CASE WHEN (SELECT    COUNT(*)
														--select *
                                          FROM      MedicalRecordCOACarePlan a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                          WHERE     b2.MemberID = b.MemberID AND
                                                    ((a2.DocumentationType = 'Discussion of Advanced Care Planning' AND
                                                      a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                     ) OR
                                                     a2.DocumentationType <> 'Discussion of Advanced Care Planning'
                                                    )
                                         ) > 0 THEN 1
                                    ELSE 0
                               END,
        COA_Med_Review_MR_Flag = CASE WHEN (SELECT  COUNT(*)
                                            FROM    MedicalRecordCOAMedRev a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            WHERE   b2.MemberID = b.MemberID AND
                                                    ((a2.EvidenceOfMedicationList = 1 AND
                                                      a2.EvidenceOfMedicationReview = 1 AND
                                                      a2.NotationOfNoMedicationTaken = 0
                                                     ) OR
                                                     (a2.EvidenceOfMedicationList = 0 AND
                                                      a2.EvidenceOfMedicationReview = 0 AND
                                                      a2.NotationOfNoMedicationTaken = 1
                                                     )
                                                    ) AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        COA_Func_Asmt_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                           FROM     MedicalRecordCOAFunctAsmt a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                           WHERE    b2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
													a2.NotationType NOT IN (SELECT NotationType FROM #PartialFunctionIndependence)
                                          ) > 0 THEN 1
									 WHEN (SELECT   COUNT(DISTINCT NotationType)
                                           FROM     MedicalRecordCOAFunctAsmt a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                           WHERE    b2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
													a2.NotationType IN (SELECT NotationType FROM #PartialFunctionIndependence)
                                          ) >= 3 THEN 1
                                     ELSE 0
                                END,
        COA_Pain_Screen_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   MedicalRecordCOAPain a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                             WHERE  b2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   LEFT(HEDISSubMetricCode, 3) = 'COA' AND
        MemberID = @MemberID


--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--Calculation of Hit Rules and Application to Scoring Table:


--Advanced Care Planning
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN COA_CarePlan_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN COA_CarePlan_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COA1'


--Medication Review
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN COA_Med_Review_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN COA_Med_Review_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COA2'


--Functional Status Assessment
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN COA_Func_Asmt_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN COA_Func_Asmt_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COA3'


--Pain Screening
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN COA_Pain_Screen_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN COA_Pain_Screen_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COA4'


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'COA', @MemberID = @MemberID;

GO
GRANT EXECUTE ON  [dbo].[ScoreCOA] TO [Support]
GO
