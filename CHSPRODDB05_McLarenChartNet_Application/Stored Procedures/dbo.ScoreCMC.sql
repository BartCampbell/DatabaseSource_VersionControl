SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for CMC measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordCMC table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCMC '78560770'

CREATE PROCEDURE [dbo].[ScoreCMC] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @AllowableDays int;
SELECT  @AllowableDays = ISNULL(dbo.GetLabVarianceDaysAllowed(), 0);

DECLARE @debug bit
SET @debug = 0

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()

IF OBJECT_ID('tempdb..#cmc_services') IS NOT NULL 
    DROP TABLE #cmc_services

SELECT  MemberID,
        ServiceDate = ServiceDate,
        EvalDate = DATEADD(day, @AllowableDays, ServiceDate),
        LDLCResult = CASE WHEN FriedewaldEquationFlag = 1
                          THEN TotalCholesteralLevelResult - HDLLevelResult -
                               (TriglyceridesLevelResult / 5) -
                               ISNULL(LipoproteinLevelResult, 0) * (0.3)
                          WHEN LDLCTestFlag = 1 AND LDLCResult = 0.00 THEN 9999
						  WHEN LDLCTestFlag = 1 AND LDLCResult IS NULL THEN LDLCResult
						  WHEN LDLCTestFlag = 1 THEN LDLCResult
                          ELSE NULL
                     END,
        event_type = 'medical record'
INTO    #cmc_services
FROM    MedicalRecordCMC a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
WHERE   MemberID = @MemberID AND
		ServiceDate BETWEEN @MeasureYearStart AND @MeasureYearEnd
UNION ALL
SELECT  MemberID,
        ServiceDate,
        EvalDate = ServiceDate,
        LabResult,
        event_type = 'administrative'
FROM    AdministrativeEvent a
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode IN ('CMC1', 'CMC2') AND
        MemberID = @MemberID AND
		ServiceDate BETWEEN @MeasureYearStart AND @MeasureYearEnd;

IF @debug = 1 
    SELECT  '#cmc_services',
            *
    FROM    #cmc_services


IF OBJECT_ID('tempdb..#MedicalRecordCMC') IS NOT NULL 
    DROP TABLE #MedicalRecordCMC

SELECT  MemberID,
        ServiceDate = MAX(ServiceDate),
        LDLCResult = ISNULL(MIN(NULLIF(LDLCResult, 0)), 0)
INTO    #MedicalRecordCMC
FROM    #cmc_services a
WHERE   event_type = 'medical record' AND
        EXISTS ( SELECT MemberID
                 FROM   #cmc_services a2
                 WHERE  a2.event_type = 'medical record'
                 GROUP BY MemberID
                 HAVING a2.MemberID = a.MemberID AND
                        MAX(a2.EvalDate) = a.EvalDate )
GROUP BY MemberID


IF @debug = 1 
    SELECT  '#MedicalRecordCMC',
            *
    FROM    #MedicalRecordCMC



IF OBJECT_ID('tempdb..#HybridCMC') IS NOT NULL 
    DROP TABLE #HybridCMC

SELECT  MemberID,
        ServiceDate = MAX(ServiceDate),
        LDLCResult = MIN(LDLCResult)
INTO    #HybridCMC
FROM    #cmc_services a
WHERE   EXISTS ( SELECT MemberID
                 FROM   #cmc_services a2
                 GROUP BY MemberID
                 HAVING a2.MemberID = a.MemberID AND
                        MAX(a2.EvalDate) = a.EvalDate )
GROUP BY MemberID


IF @debug = 1 
    SELECT  '#HybridCMC',
            *
    FROM    #HybridCMC


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        CMC_Screening_Admin_VisitFlag = CASE WHEN (SELECT   COUNT(*)
                                                   FROM     AdministrativeEvent a2
                                                   WHERE    a2.MemberID = b.MemberID AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                            a.HEDISSubMetricID = a2.HEDISSubMetricID
                                                  ) > 0 THEN 1
                                             ELSE 0
                                        END,
        CMC_Screening_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                           FROM     #MedicalRecordCMC a2
                                           WHERE    a2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                          ) > 0 THEN 1
                                     ELSE 0
                                END,
        CMC_Screening_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                            FROM    #HybridCMC a2
                                            WHERE   a2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        CMC_Control_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                                 FROM   AdministrativeEvent a2
                                                 WHERE  a2.MemberID = b.MemberID AND
                                                        a2.LabResult < 100 AND
                                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                        a.HEDISSubMetricID = a2.HEDISSubMetricID
                                                ) > 0 THEN 1
                                           ELSE 0
                                      END,
        CMC_Control_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                         FROM   #MedicalRecordCMC a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                LDLCResult < 100 AND
                                                a2.LDLCResult > 0 AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        CMC_Control_HYB_Flag = CASE WHEN (SELECT    COUNT(*)
                                          FROM      #HybridCMC a2
                                          WHERE     a2.MemberID = b.MemberID AND
                                                    LDLCResult < 100 AND
                                                    a2.LDLCResult > 0 AND
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
WHERE   LEFT(HEDISSubMetricCode, 3) = 'CMC' AND
        MemberID = @MemberID

IF @debug = 1 
    SELECT  *
    FROM    #SubMetricRuleComponents


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CMC_Screening_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CMC_Screening_HYB_Flag = 1 OR a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CMC1'




UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CMC_Control_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CMC_Control_HYB_Flag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CMC2'


IF @debug = 1 
    SELECT  *
    FROM    MemberMeasureMetricScoring mmms
            INNER JOIN dbo.MemberMeasureSample mms ON mmms.MemberMeasureSampleID = mms.MemberMeasureSampleID
    WHERE   mms.MemberID = @MemberID


IF @debug = 1 
    SELECT  *
    FROM    administrativeevent
    WHERE   memberid = @MemberID

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'CMC', @MemberID = @MemberID;
GO
GRANT EXECUTE ON  [dbo].[ScoreCMC] TO [Support]
GO
