SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for ABA measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordLSC table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreABA '78560770'

CREATE PROCEDURE [dbo].[ScoreABA] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @BeginOfPrevYear varchar(8);
DECLARE @BeginOfYear varchar(8);
DECLARE @EndOfPrevYear varchar(8);
DECLARE @EndOfYear varchar(8);

SELECT  @BeginOfPrevYear = CONVERT(varchar, DATEADD(yy, -1,
                                                    dbo.MeasureYearStartDate()), 112),
        @BeginOfYear = CONVERT(varchar, dbo.MeasureYearStartDate(), 112),
        @EndOfPrevYear = CONVERT(varchar, DATEADD(yy, -1,
                                                  dbo.MeasureYearEndDate()), 112),
        @EndOfYear = CONVERT(varchar, dbo.MeasureYearEndDate(), 112)


--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        ABA_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
													--select *
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                (
													a2.DiagnosisCode LIKE 'V85%' OR --ICD9
													a2.DiagnosisCode LIKE 'Z68%' OR --ICD10
													a2.ProcedureCode = 'ABA-N-BMI1'
												) AND
                                                a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                              AND
                                                              @EndOfYear AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        ABA_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordABABMI a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                        INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
										WHERE  b2.MemberID = b.MemberID AND
								        (
										  ( -- 18-19 years old on date of service
												a2.ServiceDate BETWEEN DateOfBirth AND DATEADD(dd, -1, DATEADD(yy, 20, DateOfBirth)) AND
												ISNULL(a2.[Weight], 0) > 0 AND
												ISNULL(a2.[Height], 0) > 0 AND
												(
													(ISNULL(a2.BMIPercentile, 0) BETWEEN 1 AND 100) OR
													(ISNULL(a2.PlottedOnAgeGrowthChart, 0) = 1) OR
													(ISNULL(a2.BMIPercentileGT99, 0) = 1) OR
													(ISNULL(a2.BMIPercentileLT1, 0) = 1)
												)										  
										    )
										    OR
										    ( -- 20 or more years old on service date
											  DATEADD(yy, 20, DateOfBirth) <= a2.ServiceDate AND
											  ISNULL(a2.[Weight], 0) > 0 AND
											  ISNULL(a2.[BMIValue], 0) BETWEEN 1 AND 250
										     )  
										) AND                                             
                                        a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                       AND    @EndOfYear
                                ) > 0
						   THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
--select *
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'ABA' AND
        MemberID = @MemberID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordABAExcl a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
											ISNULL(d2.Gender, '') IN ('0', 'F', '', 'U', 'X') AND                                   
                                            a2.PregnancyDiagnosisFlag = 1 AND
                                            a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                           AND
                                                              @EndOfYear
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordABAExcl a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
															  ISNULL(d2.Gender, '') IN ('0', 'F', '', 'U', 'X') AND                                                            
                                                              a2.PregnancyDiagnosisFlag = 1 AND
                                                              a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                              AND
                                                              @EndOfYear
                                                          ) > 0
                                                     THEN 'Excluded for Pregnancy'
                                                END)
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'ABA' AND
        MemberID = @MemberID
		

--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN ABA_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN ABA_MR_Flag = 1 THEN 1
                              WHEN ABA_Admin_VisitFlag = 1 THEN 1
							  WHEN a.AdministrativeHitCount > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN ISNULL(x.ExclusionFlag, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'ABA', @MemberID = @MemberID;


--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************
IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents





GO
GRANT EXECUTE ON  [dbo].[ScoreABA] TO [Support]
GO
