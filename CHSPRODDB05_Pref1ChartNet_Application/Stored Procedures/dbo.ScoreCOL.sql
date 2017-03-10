SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for COL measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordCOL table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCOL '78562322'

CREATE PROCEDURE [dbo].[ScoreCOL] @MemberID int
AS 

SET NOCOUNT ON;

--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime
DECLARE @NineYearPriorMeasureYearStart datetime
DECLARE @FourYearPriorMeasureYearStart datetime
DECLARE @TwoYearPriorMeasureYearStart datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @NineYearPriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-9)
SELECT  @FourYearPriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-4)
SELECT  @TwoYearPriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-2)


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        COL_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        COL_MR_Flag = CASE WHEN (SELECT COUNT(*) --select *
                                 FROM   MedicalRecordCOL a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        a2.EvidenceType = 'Numerator' AND
                                        ((NumeratorType = 'Medical History Documentation' AND
                                          ScreeningInMedicalHistory = 1 AND
                                          a2.ServiceDate BETWEEN @MeasureYearStart
                                                         AND  @MeasureYearEnd
                                         ) OR
                                         (NumeratorType = 'Screening Evidence' AND
                                          ((FOBTTestType IN ('UnknownFOBT',
															'Unknown FOBT, With Count',
                                                            'Guaiac') AND
                                            FOBTSampleCount >= 3
                                           ) OR
                                           FOBTTestType IN ('Immunochemical',
															'Unknown',
															'Unknown FOBT, Unknown Count',
                                                            'GuaiacNoCount',
															'Guaiac, Unknown Count')
                                          ) AND
                                          a2.ServiceDate BETWEEN @MeasureYearStart
                                                         AND  @MeasureYearEnd
                                         ) OR
                                         (NumeratorType IN ('Flexible sigmoidoscopy','Pathology flexible sigmoidosocopy') AND
                                          a2.ServiceDate BETWEEN @FourYearPriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         ) OR
                                         (NumeratorType IN ('Colonoscopy','Pathology Colonoscopy') AND
                                          a2.ServiceDate BETWEEN @NineYearPriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         )
											OR
                                         (NumeratorType = 'CT Colonoscopy' AND
                                          a2.ServiceDate BETWEEN @FourYearPriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         )
											OR
                                         (NumeratorType = 'FIT-DNA' AND
                                          a2.ServiceDate BETWEEN @TwoYearPriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         )
											OR
                                         (NumeratorType = 'Pathology' AND
                                          a2.ServiceDate BETWEEN @TwoYearPriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         )
                                        )
                                ) > 0 THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COL' AND
        MemberID = @MemberID



--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordCOL a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
                                            a2.EvidenceType = 'Exclusion' AND
                                            (a2.PriorDiagnosisOfColorectalCancerFlag = 1 OR
                                             a2.PriorTotalColorectomyFlag = 1
                                            ) AND
                                            a2.ServiceDate BETWEEN d2.DateOfBirth
                                                           AND
                                                              @MeasureYearEnd
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordCOL a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.EvidenceType = 'Exclusion' AND
                                                              a2.PriorDiagnosisOfColorectalCancerFlag = 1 AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                          ) > 0
                                                     THEN 'Excluded for Diagnosis of Colorectal Cancer'
                                                     WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordCOL a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.EvidenceType = 'Exclusion' AND
                                                              a2.PriorTotalColorectomyFlag = 1 AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                          ) > 0
                                                     THEN 'Excluded for Total Colectomy'
                                                     ELSE 'Excluded'
                                                END)
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'COL' AND
        MemberID = @MemberID


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN COL_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN COL_MR_Flag = 1 THEN 1
                              WHEN COL_Admin_VisitFlag = 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN x.ExclusionFlag > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'COL', @MemberID = @MemberID;

GO
GRANT EXECUTE ON  [dbo].[ScoreCOL] TO [Support]
GO
