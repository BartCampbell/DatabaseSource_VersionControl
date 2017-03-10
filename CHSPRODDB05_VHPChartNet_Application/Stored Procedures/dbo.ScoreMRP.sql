SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for MRP measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the following tables:
--dbo.MedicalRecordMRP

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreMRP '78560770'

CREATE PROCEDURE [dbo].[ScoreMRP] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        b.DischargeDate
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   LEFT(HEDISSubMetricCode, 3) = 'MRP' AND
        MemberID = @MemberID


IF OBJECT_ID('tempdb..#MemberDischargeDates') IS NOT NULL 
    DROP TABLE #MemberDischargeDates
   
SELECT  mmms.DischargeDate,
        HitCount = CASE WHEN (SELECT    COUNT(*)
                              FROM      dbo.MedicalRecordMRP mr
                                        JOIN dbo.PursuitEvent pe ON mr.PursuitEventID = pe.PursuitEventID
                                        JOIN dbo.Pursuit purs ON pe.PursuitID = purs.PursuitID
                              WHERE     purs.MemberID = @MemberID AND
                                        pe.MeasureID = 21 AND
                                        mr.ServiceDate BETWEEN mmms.DischargeDate
                                                       AND    DATEADD(day, 30,
                                                              mmms.DischargeDate)
                             ) > 0 THEN 1
                        ELSE 0
                   END
INTO    #MemberDischargeDates
FROM    dbo.MemberMeasureSample mmms
WHERE   MemberID = @MemberID AND
        MeasureID = 21 AND
        mmms.DischargeDate BETWEEN @MeasureYearStart
                           AND     @MeasureYearEnd 

DECLARE @MissCount int
SET @MissCount = (SELECT    COUNT(*)
                  FROM      #MemberDischargeDates
                  WHERE     HitCount = 0
                 )

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN hits.HitCount > 0 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN hits.HitCount > 0 OR AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN #MemberDischargeDates AS hits ON c.DischargeDate = hits.DischargeDate
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'MRP'

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'MRP', @MemberID = @MemberID;
GO
GRANT EXECUTE ON  [dbo].[ScoreMRP] TO [Support]
GO
