SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for AWC measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordW34 table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreW34 '78551528'

CREATE PROCEDURE [dbo].[ScoreW34] @MemberID int
AS

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime
DECLARE @PriorMeasureYearStart datetime
DECLARE @PriorMeasureYearEnd datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @PriorMeasureYearEnd = dbo.MeasureYearEndDateYearOffset(-1)


--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:
IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        W34_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        W34_HlthDevPhysFlag = CASE WHEN (SELECT SUM(CASE WHEN PhysHlthDevFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                         FROM   MedicalRecordW34 a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                         WHERE  b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        W34_HlthDevMentFlag = CASE WHEN (SELECT SUM(CASE WHEN MentalHlthDevFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                         FROM   MedicalRecordW34 a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                         WHERE  b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        W34_PhysExamFlag = CASE WHEN (SELECT    SUM(CASE WHEN PhysExamFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordW34 a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                      WHERE     b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                     ) > 0 THEN 1
                                ELSE 0
                           END,
        W34_HlthEducFlag = CASE WHEN (SELECT    SUM(CASE WHEN HlthEducFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordW34 a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                      WHERE     b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                     ) > 0 THEN 1
                                ELSE 0
                           END,
		W34_HlthHistoryFlag = CASE WHEN (SELECT    SUM(CASE WHEN HlthHistoryFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordW34 a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                      WHERE     b2.MemberID = b.MemberID AND
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
WHERE   HEDISSubMetricCode = 'W34' AND
        MemberID = @MemberID


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN W34_HlthDevPhysFlag = 1 AND
                                          W34_HlthDevMentFlag = 1 AND
                                          W34_PhysExamFlag = 1 AND
                                          W34_HlthEducFlag = 1 AND
										  W34_HlthHistoryFlag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN W34_HlthDevPhysFlag = 1 AND
                                   W34_HlthDevMentFlag = 1 AND
                                   W34_PhysExamFlag = 1 AND
                                   W34_HlthEducFlag = 1 AND
								   W34_HlthHistoryFlag = 1 THEN 1
                              WHEN W34_Admin_VisitFlag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID



EXEC dbo.RunPostScoringSteps @HedisMeasure = 'W34', @MemberID = @MemberID;



GO
GRANT EXECUTE ON  [dbo].[ScoreW34] TO [Support]
GO
