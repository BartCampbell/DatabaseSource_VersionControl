SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for WOP measures for this member.

--It uses Medical Record data from the MedicalRecordWOP table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCCS '78568140'

CREATE PROCEDURE [dbo].[ScoreWOP] @MemberID int
AS 

SET NOCOUNT ON;

--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        WOP_Admin_Flag = 0,
        WOP_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordWOP a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        (a2.EDD IS NOT NULL OR
                                         (a2.GestationalAge IS NOT NULL AND
                                          a2.GestationalAgeSource IS NOT NULL
                                         )
                                        )
                                ) > 0 THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'WOPC1' AND
        MemberID = @MemberID


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN WOP_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN WOP_MR_Flag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'WOP', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents




















GO
GRANT EXECUTE ON  [dbo].[ScoreWOP] TO [Support]
GO
