SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for AWC measures for this member.
--
--It uses administrative claims data from the AdministrativeEvent table.
--
--It uses Medical Record data from the MedicalRecordAWC table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreAWC '78569872'

CREATE PROCEDURE [dbo].[ScoreAWC] @MemberID int
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
        AWC_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
--		AWC_HlthDevFlag			= 	case	when (	select	sum(HlthDevFlag)
--													from	MedicalRecordAWC a2
--															inner join Pursuit b2 on 
--																a2.PursuitID = b2.PursuitID 
--															inner join PursuitEvent c2 on 
--																a2.PursuitEventID = c2.PursuitEventID 
--													where	b2.MemberID = b.MemberID ) > 0
--											then	1
--											else	0
--									end,
        AWC_HlthDevPhysFlag = CASE WHEN (SELECT SUM(CASE WHEN PhysHlthDevFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                         FROM   MedicalRecordAWC a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                         WHERE  b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        AWC_HlthDevMentFlag = CASE WHEN (SELECT SUM(CASE WHEN MentalHlthDevFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                         FROM   MedicalRecordAWC a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                         WHERE  b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        AWC_PhysExamFlag = CASE WHEN (SELECT    SUM(CASE WHEN PhysExamFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordAWC a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                      WHERE     b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                     ) > 0 THEN 1
                                ELSE 0
                           END,
        AWC_HlthEducFlag = CASE WHEN (SELECT    SUM(CASE WHEN HlthEducFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordAWC a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                      WHERE     b2.MemberID = b.MemberID AND
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                     ) > 0 THEN 1
                                ELSE 0
                           END,
		AWC_HlthHistoryFlag = CASE WHEN (SELECT    SUM(CASE WHEN HlthHistoryFlag = 1
                                                         THEN 1
                                                         ELSE 0
                                                    END)
                                      FROM      MedicalRecordAWC a2
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
WHERE   HEDISSubMetricCode = 'AWC' AND
        MemberID = @MemberID




--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN	--AWC_HlthDevFlag = 1 and
                                          AWC_HlthDevPhysFlag = 1 AND
                                          AWC_HlthDevMentFlag = 1 AND
                                          AWC_PhysExamFlag = 1 AND
                                          AWC_HlthEducFlag = 1 AND
										  AWC_HlthHistoryFlag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN	--AWC_HlthDevFlag = 1 and
                                   AWC_HlthDevPhysFlag = 1 AND
                                   AWC_HlthDevMentFlag = 1 AND
                                   AWC_PhysExamFlag = 1 AND
                                   AWC_HlthEducFlag = 1 AND
								   AWC_HlthHistoryFlag = 1 THEN 1
                              WHEN AWC_Admin_VisitFlag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'AWC', @MemberID = @MemberID;





GO
GRANT EXECUTE ON  [dbo].[ScoreAWC] TO [Support]
GO
