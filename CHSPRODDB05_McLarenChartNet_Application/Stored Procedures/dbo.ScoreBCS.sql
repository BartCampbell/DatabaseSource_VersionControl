SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for BCS measures for this member.
--
--It uses administrative claims data from the AdministrativeEvent table.
--
--It uses Medical Record data from the MedicalRecordbCS tabB.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreBCS '78568140'

CREATE PROCEDURE [dbo].[ScoreBCS] @MemberID int
AS --*****************************************
--declare @MemberID int
--
----set		@MemberID = '78568140'
--set		@MemberID =
--(select	MemberID
--from	Member a
--where	ProductLine			= 'Medicaid' and
--		Product				= 'MCD' and
--		CustomerMemberID	= '107882501')
--
--print	@MemberID
--*****************************************

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime;
DECLARE @MeasureYearEnd datetime;
DECLARE @PriorMeasureYearStart datetime;
DECLARE @PriorMeasureYearEnd datetime;

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @PriorMeasureYearEnd = dbo.MeasureYearEndDateYearOffset(-1)

--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        BCS_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID AND
                                                a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        BCS_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordBCS a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        a2.EvidenceType = 'Numerator' AND
                                        a2.MammogramFlag = 1 AND
                                        NOT (a2.BilateralMastectomyFlag = 1 OR
                                             a2.DualSeperateUnilateralMastectomiesFlag = 1
                                            ) AND
                                        a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                       AND    @MeasureYearEnd
                                ) > 0 THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'BCS' AND
        MemberID = @MemberID



--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN BCS_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN BCS_MR_Flag = 1 THEN 1
                              WHEN BCS_Admin_VisitFlag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID



EXEC dbo.RunPostScoringSteps @HedisMeasure = 'BCS', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents





















GO
GRANT EXECUTE ON  [dbo].[ScoreBCS] TO [Support]
GO
