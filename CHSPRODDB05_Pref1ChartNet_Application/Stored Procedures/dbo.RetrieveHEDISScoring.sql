SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RetrieveHEDISScoring] @PursuitEventID int
AS 
SET NOCOUNT ON

DECLARE @MeasureID int;
DECLARE @EventDate datetime;

SELECT  @MeasureID = MeasureID,
		@EventDate = EventDate
FROM    PursuitEvent
WHERE   PursuitEventID = @PursuitEventID

----------------------------------------------------------------------------------------------------
--IMPORTANT: Changes to this resultset must also be reflected in dbo.SubMetrics...
----------------------------------------------------------------------------------------------------

DECLARE @SubMetricScoring TABLE
    (
     MeasureID int,
     MemberMeasureMetricScoringID int,
     HEDISMeasure varchar(10),
     HEDISSubMetricID int,
     SubMetric varchar(50),
     Passed bit,
     SortOrder int
    )


INSERT  INTO @SubMetricScoring
        SELECT  MEA.MeasureID,
                NULL AS MemberMeasureMetricScoringID,
                MEA.HEDISMeasure,
                HSM.HEDISSubMetricID,
                COALESCE(HSM.DisplayName, HSM.HEDISSubMetricCode) SubMetric,
                0 AS Passed,
                HSM.SortOrder
        FROM    dbo.Measure MEA
                JOIN dbo.HEDISSubMetric HSM ON MEA.MeasureID = HSM.MeasureID
                JOIN dbo.Measure M ON HSM.MeasureID = M.MeasureID
        WHERE   HSM.MeasureID = @MeasureID AND
                DisplayInScoringPanel = 1

SELECT  HSM.HEDISSubMetricID,
        COALESCE(HSM.DisplayName, HSM.HEDISSubMetricCode) SubMetric,
        CAST(CASE WHEN MMMS.HybridHitCount > 0 THEN 1
                  ELSE 0
             END AS bit) AS Passed,
        P.MemberID,
        MMMS.MemberMeasureMetricScoringID
INTO    #ScoringResults
FROM    MemberMeasureMetricScoring MMMS
        JOIN MemberMeasureSample MMS ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID
        LEFT JOIN Pursuit P ON MMS.MemberID = P.MemberID
        LEFT JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        JOIN HEDISSubMetric HSM ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID
WHERE   PE.PursuitEventID = @PursuitEventID AND
		(MMS.EventDate = PE.EventDate OR MMS.EventDate IS NULL OR PE.EventDate IS NULL OR HSM.HEDISMeasureInit NOT IN ('MRP','PPC','FPC')) AND
        HSM.HEDISSubMetricID IN (SELECT HEDISSubMetricID
                                 FROM   @SubMetricScoring) AND
		MMMS.ReqExclCount = 0  AND
		MMMS.ExclusionCount = 0 AND
		MMMS.SampleVoidCount = 0 AND      
		MMMS.DenominatorCount > 0                             
 
 -- if any rows in #ScoringResults for the same sub-measure have Passed=0, set all to 0 for that sub-measure
 -- this is to fix the situation for MRP where there can be multiple
 -- MemberMeasureMetricScoring rows for the PursuitEvent, each with it's own score
UPDATE  #ScoringResults
SET     Passed = 0
FROM    #ScoringResults sr
        JOIN (SELECT    HEDISSubMetricID,
                        COUNT(*) AS cnt
              FROM      #ScoringResults
              WHERE     Passed = 0
              GROUP BY  HEDISSubMetricID
             ) nopass ON sr.HEDISSubMetricID = nopass.HEDISSubMetricID

UPDATE  @SubMetricScoring
SET     Passed = DT.Passed,
        MemberMeasureMetricScoringID = DT.MemberMeasureMetricScoringID
FROM    @SubMetricScoring SMS
        JOIN #ScoringResults DT ON SMS.HEDISSubMetricID = DT.HEDISSubMetricID


SELECT  MeasureID,
        HEDISSubMetricID,
        HEDISMeasure,
        SubMetric,
        CASE WHEN ISNULL(MemberMeasureMetricScoringID, 0) <> 0 THEN Passed
             ELSE NULL
        END AS Passed
FROM    @SubMetricScoring
ORDER BY SortOrder


GO
