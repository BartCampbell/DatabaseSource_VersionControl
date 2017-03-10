SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for HPV measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordHPV table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreHPV '561296'

CREATE PROCEDURE [dbo].[ScoreHPV] @MemberID int
AS 

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#HEDISSubMetricComponent') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent

CREATE TABLE #HEDISSubMetricComponent
(
 HEDISSubMetricComponentID int IDENTITY(1, 1),
 HEDISSubMetricComponentCode varchar(50),
 HEDISSubMetricComponentDesc varchar(50),
 HEDISSubMetricCode varchar(50)
)

INSERT  INTO #HEDISSubMetricComponent
VALUES  ('HPV', 'HPV', 'HPV')



IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ProcCode_xref') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent_ProcCode_xref

CREATE TABLE #HEDISSubMetricComponent_ProcCode_xref
(
 ProcCode varchar(10),
 HEDISSubMetricComponentCode varchar(50)
)

INSERT  INTO #HEDISSubMetricComponent_ProcCode_xref
VALUES  ('90649', 'HPV')
INSERT  INTO #HEDISSubMetricComponent_ProcCode_xref
VALUES  ('90650', 'HPV')


IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ICD9Proc_xref') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent_ICD9Proc_xref

CREATE TABLE #HEDISSubMetricComponent_ICD9Proc_xref
(
 ICD9Proc varchar(10),
 HEDISSubMetricComponentCode varchar(50)
)

IF OBJECT_ID('tempdb..#AdministrativeEvent') IS NOT NULL 
    DROP TABLE #AdministrativeEvent

SELECT DISTINCT
        MeasureID = a.MeasureID,
        HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode,
        HEDISSubMetricComponentID = c.HEDISSubMetricComponentID,
        HEDISSubMetricCode = c.HEDISSubMetricCode,
        MemberID = a.MemberID,
        ServiceDate = a.ServiceDate,
        DateOfBirth,
        DateOfBirth_9years = DATEADD(yy, 9, DateOfBirth),
        DateOfBirth_13years = DATEADD(yy, 13, DateOfBirth)
INTO    #AdministrativeEvent
FROM    AdministrativeEvent a
        INNER JOIN #HEDISSubMetricComponent_ProcCode_xref b ON a.ProcedureCode = b.ProcCode
        INNER JOIN #HEDISSubMetricComponent c ON b.HEDISSubMetricComponentCode = c.HEDISSubMetricComponentCode
        INNER JOIN Member d ON a.MemberID = d.MemberID
WHERE   a.MemberID = @MemberID 


--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#single_shot_xref') IS NOT NULL 
    DROP TABLE #single_shot_xref

CREATE TABLE #single_shot_xref
(
 compound_shot varchar(50),
 single_shot varchar(50),
 HEDISSubMetricCode varchar(50),
 HEDISSubMetricComponentCode varchar(50),
 HEDISSubMetricID int,
 HEDISSubMetricComponentID int
)

INSERT  INTO #single_shot_xref
        (compound_shot,
         single_shot,
         HEDISSubMetricCode,
         HEDISSubMetricComponentCode
        )
        SELECT  'HPV',
                'HPV',
                'HPV',
                'HPV'

UPDATE  #single_shot_xref
SET     HEDISSubMetricComponentID = b.HEDISSubMetricComponentID
FROM    #single_shot_xref a
        INNER JOIN #HEDISSubMetricComponent b ON a.HEDISSubMetricComponentCode = b.HEDISSubMetricComponentCode


UPDATE  #single_shot_xref
SET     HEDISSubMetricID = b.HEDISSubMetricID
FROM    #single_shot_xref a
        INNER JOIN HEDISSubMetric b ON a.HEDISSubMetricCode = b.HEDISSubMetricCode


IF OBJECT_ID('tempdb..#MedicalRecordEvent') IS NOT NULL 
    DROP TABLE #MedicalRecordEvent

SELECT  a.*,
        b.MemberID,
        HEDISSubMetricCode,
        HEDISSubMetricComponentCode,
        DateOfBirth,
        DateOfBirth_9years = DATEADD(yy, 9, DateOfBirth),
        DateOfBirth_13years = DATEADD(yy, 13, DateOfBirth)
INTO    #MedicalRecordEvent
FROM    MedicalRecordHPV a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
        INNER JOIN DropDownValues_HPVEvidence e ON a.HPVEvidenceID = e.HPVEvidenceID
		INNER JOIN dbo.DropDownValues_HPVEvent f ON f.HPVEventID = e.HPVEventID AND f.DisplayText NOT LIKE '%Parent/Guardian Refusal%'
        INNER JOIN #single_shot_xref c ON e.DisplayText = c.compound_shot
        INNER JOIN Member d ON b.MemberID = d.MemberID
WHERE   b.MemberID = @MemberID AND
        NOT EXISTS ( SELECT *
                     FROM   #AdministrativeEvent a2
                     WHERE  b.MemberID = a2.MemberID AND
                            c.HEDISSubMetricComponentID = a2.HEDISSubMetricComponentID AND
                            a.ServiceDate = a2.ServiceDate )

IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecordDetail') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecordDetail


SELECT  MemberID,
        ServiceDate,
        HEDISSubMetricCode,
        HEDISSubMetricComponentCode,
		--************************************************************************************************
        hpv_adm = 0,
        hpv_mr = CASE WHEN HEDISSubMetricComponentCode = 'HPV' AND
                                ServiceDate BETWEEN DateOfBirth_9years
                                            AND     DateOfBirth_13years THEN 1
                           ELSE 0
                      END,
        hpv_hyb = 0
INTO    #SubMetricRuleComponentMetricsMedicalRecordDetail
FROM    #MedicalRecordEvent a
UNION ALL
SELECT  MemberID,
        ServiceDate,
        HEDISSubMetricCode,
        HEDISSubMetricComponentCode,
        hpv_adm = CASE WHEN HEDISSubMetricComponentCode = 'HPV' AND
                                  ServiceDate BETWEEN DateOfBirth_9years
                                              AND     DateOfBirth_13years
                             THEN 1
                             ELSE 0
                        END,
        hpv_mr = 0,
        hpv_hyb = 0
		--************************************************************************************************
FROM    #AdministrativeEvent a


IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord;
    WITH    Results
              AS (
                  SELECT    MemberID,
                            ServiceDate,
                            HEDISSubMetricCode,
                            hpv_adm = MAX(hpv_adm),
                            hpv_mr = MAX(hpv_mr),
                            hpv_hyb = MAX(CASE WHEN hpv_adm > 0
                                                     THEN hpv_adm
                                                     ELSE hpv_mr
                                                END)
							--************************************************************************************************
                  FROM      #SubMetricRuleComponentMetricsMedicalRecordDetail
                  GROUP BY  MemberID,
                            ServiceDate,
                            HEDISSubMetricCode
                 )
    SELECT  MemberID,
            HEDISSubMetricCode,
            hpv_adm = SUM(hpv_adm),
            hpv_mr = SUM(hpv_mr),
            hpv_hyb = SUM(hpv_hyb)
    INTO    #SubMetricRuleComponentMetricsMedicalRecord
    FROM    Results
    GROUP BY MemberID,
            HEDISSubMetricCode;


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        c.HEDISSubMetricCode,
        hpv_adm = SUM(hpv_adm),
        hpv_mr = SUM(hpv_mr),
        hpv_hyb = SUM(hpv_hyb)
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
        LEFT JOIN #SubMetricRuleComponentMetricsMedicalRecord d ON d.MemberID = b.MemberID AND
                                                              d.HEDISSubMetricCode = c.HEDISSubMetricCode
WHERE   HEDISMeasureInit = 'HPV' AND
        b.MemberID = @MemberID
GROUP BY MemberMeasureMetricScoringID,
        c.HEDISSubMetricCode


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordHPV a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
											INNER JOIN dbo.DropDownValues_HPVEvidence AS v2 ON a2.HPVEvidenceID = v2.HPVEvidenceID
											INNER JOIN dbo.DropDownValues_HPVEvent AS e2 ON v2.HPVEventID = e2.HPVEventID
                                   WHERE    b2.MemberID = b.MemberID AND
											e2.DisplayText = 'Exclusion' AND  
											a2.ServiceDate BETWEEN d2.DateOfBirth 
                                                           AND
                                                              DATEADD(yy, 13, d2.DateOfBirth)
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200),	(SELECT   MIN(v2.DisplayText)
												   FROM     dbo.MedicalRecordHPV a2
															INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
															INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
															INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
															INNER JOIN dbo.DropDownValues_HPVEvidence AS v2 ON a2.HPVEvidenceID = v2.HPVEvidenceID
															INNER JOIN dbo.DropDownValues_HPVEvent AS e2 ON v2.HPVEventID = e2.HPVEventID
												   WHERE    b2.MemberID = b.MemberID AND
															e2.DisplayText = 'Exclusion' AND  
															a2.ServiceDate BETWEEN d2.DateOfBirth 
																		   AND
																			  DATEADD(yy, 13, d2.DateOfBirth)))
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISMeasureInit = 'HPV' AND
        MemberID = @MemberID;


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     AdministrativeHitCount = CASE WHEN hpv_adm >= 3 THEN 1
                                     WHEN a.AdministrativeHitCount >= 1 THEN 1
                                     ELSE 0
                                END,
		MedicalRecordHitCount = CASE WHEN hpv_mr >= 3 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN hpv_hyb >= 3 THEN 1
                              WHEN a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID;


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'HPV', @MemberID = @MemberID;

----**********************************************************************************************
----**********************************************************************************************
----temp table cleanup
----**********************************************************************************************
----**********************************************************************************************



IF OBJECT_ID('tempdb..#HEDISSubMetricComponent') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent

IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ProcCode_xref') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent_ProcCode_xref

IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_DiagCode3_xref') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent_DiagCode3_xref

IF OBJECT_ID('tempdb..#HEDISSubMetricComponent_ICD9Proc_xref') IS NOT NULL 
    DROP TABLE #HEDISSubMetricComponent_ICD9Proc_xref

IF OBJECT_ID('tempdb..#AdministrativeEvent') IS NOT NULL 
    DROP TABLE #AdministrativeEvent

IF OBJECT_ID('tempdb..#single_shot_xref') IS NOT NULL 
    DROP TABLE #single_shot_xref

IF OBJECT_ID('tempdb..#MedicalRecordEvent') IS NOT NULL 
    DROP TABLE #MedicalRecordEvent

IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecordDetail') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecordDetail

IF OBJECT_ID('tempdb..#SubMetricRuleComponentMetricsMedicalRecord') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentMetricsMedicalRecord

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

IF OBJECT_ID('tempdb..#SubMetricRuleComponentsTotal') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponentsTotal















GO
GRANT EXECUTE ON  [dbo].[ScoreHPV] TO [Support]
GO
