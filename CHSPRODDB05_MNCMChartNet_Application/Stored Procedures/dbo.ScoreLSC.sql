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

--It uses Medical Record data from the MedicalRecordLSC table.


--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreLSC '78560872'

CREATE PROCEDURE [dbo].[ScoreLSC] @MemberID int
AS 

SET NOCOUNT ON;

--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        LSC_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        LSC_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordLSC a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                        INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        (a2.Result <> '' OR a2.ResultPresent = 1) AND
                                        a2.ServiceDate BETWEEN d2.DateOfBirth AND DATEADD(yy, 2, d2.DateOfBirth)
                                ) > 0 THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'LSC' AND
        MemberID = @MemberID




--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN LSC_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN LSC_MR_Flag = 1 THEN 1
                              WHEN LSC_Admin_VisitFlag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'LSC', @MemberID = @MemberID;


--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

GO
GRANT EXECUTE ON  [dbo].[ScoreLSC] TO [Support]
GO
