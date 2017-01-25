SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for WCC measures for this member.
--
--It uses administrative claims data from the AdministrativeEvent table.
--
--It uses Medical Record data from the following tables:
--dbo.MedicalRecordWCCActive
--dbo.MedicalRecordWCCBMI
--dbo.MedicalRecordWCCNutri

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreWCC '78560770'

CREATE PROCEDURE [dbo].[ScoreWCC] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime
DECLARE @PriorMeasureYearStart datetime
DECLARE @PriorMeasureYearEnd datetime
DECLARE @HbA1cGoodcontrolCutoff int

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @PriorMeasureYearEnd = dbo.MeasureYearEndDateYearOffset(-1)

--*******************************************************************************
--*******************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        WCC_BMI_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                     FROM   MedicalRecordWCCBMI a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN Member c2 ON b2.MemberID = c2.MemberID
                                     WHERE  b2.MemberID = b.MemberID AND
											ISNULL(a2.HeightValueFromRecord, 0) BETWEEN 1 AND 288 AND
											ISNULL(a2.WeightValueFromRecord, 0) BETWEEN 1 AND 1000 AND                                   
                                            (
											--(ISNULL(a2.BMIValue, 0) > 0 AND
                                            --  a2.ServiceDate BETWEEN DATEADD(yy,
                                            --                  16, DateOfBirth)
                                            --                 AND
                                            --                  DATEADD(dd, -1,
                                            --                  DATEADD(yy, 18,
                                            --                  DateOfBirth))
                                            -- ) OR
                                             ISNULL(a2.BMIPercentile, 0) > 0 OR
											 ISNULL(a2.PlottedOnAgeGrowthChart, 0) = 1 OR
											 ISNULL(a2.BMIPercentileGT99, 0) = 1 OR
											 ISNULL(a2.BMIPercentileLT1, 0) = 1
                                            ) AND
                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                           AND
                                                              @MeasureYearEnd
                                    ) > 0 THEN 1
                               ELSE 0
                          END,
        WCC_Counsel_Nutri_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                               FROM     MedicalRecordWCCNutri a2
                                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                               WHERE    b2.MemberID = b.MemberID AND
                                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                        ISNULL(a2.DocumentationType,
                                                              '') <> ''
                                              ) > 0 THEN 1
                                         ELSE 0
                                    END,
        WCC_Phys_Activity_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                               FROM     MedicalRecordWCCActive a2
                                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                               WHERE    b2.MemberID = b.MemberID AND
                                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                        ISNULL(a2.DocumentationType,
                                                              '') <> ''
                                              ) > 0 THEN 1
                                         ELSE 0
                                    END,
        WCC_APC_Sexual_Activity_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   MedicalRecordWCCAPCSA a2
                                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                     WHERE  b2.MemberID = b.MemberID AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                            a2.DocumentationTypeID IS NOT NULL
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
        WCC_APC_Depression_MR_Flag = CASE WHEN (SELECT  COUNT(*)
                                                FROM    dbo.MedicalRecordWCCAPCDEP a2
                                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                WHERE   b2.MemberID = b.MemberID AND
                                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                        a2.DocumentationTypeID IS NOT NULL
                                               ) > 0 THEN 1
                                          ELSE 0
                                     END,
        WCC_APC_Smoking_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   dbo.MedicalRecordWCCAPCSMOK a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                             WHERE  b2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                    a2.DocumentationTypeID IS NOT NULL
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END,
        WCC_APC_Substance_Abuse_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   dbo.MedicalRecordWCCAPCSUBS a2
                                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                     WHERE  b2.MemberID = b.MemberID AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                            a2.DocumentationTypeID IS NOT NULL
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
		MemberAge = dbo.GetAgeAsOf(M.DateOfBirth, @MeasureYearEnd),
		WCC_APC_denominator = CASE WHEN dbo.GetAgeAsOf(M.DateOfBirth, @MeasureYearEnd) BETWEEN 12 AND 17 THEN 1 ELSE 0 END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
		INNER JOIN dbo.Member AS M ON M.MemberID = b.MemberID
WHERE   (LEFT(HEDISSubMetricCode, 3) = 'WCC' OR
         LEFT(HEDISSubMetricCode, 3) = 'APC'
        ) AND
        b.MemberID = @MemberID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordWCCExcl a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
											ISNULL(d2.Gender, '') IN ('0', 'F', '', 'U', 'X') AND                                   
                                            a2.PregnancyDiagnosisFlag = 1 AND
                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                           AND
                                                              @MeasureYearEnd
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordWCCExcl a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
															  ISNULL(d2.Gender, '') IN ('0', 'F', '', 'U', 'X') AND                                                            
                                                              a2.PregnancyDiagnosisFlag = 1 AND
                                                              a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                          ) > 0
                                                     THEN 'Excluded for Pregnancy'
                                                END)
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISMeasureInit = 'WCC' AND
        MemberID = @MemberID;


--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--Calculation of Hit Rules and Application to Scoring Table:


--BMI Percentile
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_BMI_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_BMI_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'WCC1'

--Counseling for Nutrition
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_Counsel_Nutri_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_Counsel_Nutri_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'WCC2'


--Counseling for Physical Activity
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_Phys_Activity_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_Phys_Activity_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'WCC3'


--Counseling for Sexual Activity
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_APC_Sexual_Activity_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_APC_Sexual_Activity_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason,
		DenominatorCount = WCC_APC_denominator
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'APC1'


--Counseling for Depression
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_APC_Depression_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_APC_Depression_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason,
		DenominatorCount = WCC_APC_denominator
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'APC2'


--Counseling for Smoking
UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN WCC_APC_Smoking_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_APC_Smoking_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason,
		DenominatorCount = WCC_APC_denominator
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'APC3'


--Counseling for Substance Abuse
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WCC_APC_Substance_Abuse_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WCC_APC_Substance_Abuse_MR_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason,
		DenominatorCount = WCC_APC_denominator
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
		LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'APC4'


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'WCC', @MemberID = @MemberID;


--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents






GO
GRANT EXECUTE ON  [dbo].[ScoreWCC] TO [Support]
GO
