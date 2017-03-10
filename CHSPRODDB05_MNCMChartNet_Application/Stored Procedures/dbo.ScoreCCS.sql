SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for CCS measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordCCS table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCCS '78568140'

CREATE PROCEDURE [dbo].[ScoreCCS] @MemberID int
AS 

SET NOCOUNT ON;

DECLARE @MeasureYearStart datetime;
DECLARE @MeasureYearEnd datetime;
DECLARE @PriorMeasureYearStart datetime;
DECLARE @PriorMeasureYearEnd datetime;

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @PriorMeasureYearEnd = dbo.MeasureYearEndDateYearOffset(-1)


DECLARE @CCSStartDate datetime;
SELECT  @CCSStartDate = dbo.MeasureYearStartDateYearOffset(-2);

DECLARE @CCSStartDate4Years datetime;
SELECT  @CCSStartDate4Years = dbo.MeasureYearStartDateYearOffset(-4);

DECLARE @MemberAge tinyint;
DECLARE @MemberDOB datetime;
SELECT	@MemberAge = dbo.GetAgeAsOf(CASE WHEN DateOfBirth < '1/1/1800' THEN '1/1/1800' ELSE DateOfBirth END, @MeasureYearEnd), @MemberDOB = DateOfBirth FROM dbo.Member WHERE MemberID = @MemberID;

--set up a rules table that is 1 row per HEDISSubMetric, containing 
--all necessary decision flags:

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        CCS_Admin_VisitFlag = CASE WHEN (SELECT COUNT(*)
                                         FROM   AdministrativeEvent a2
                                         WHERE  a2.MemberID = b.MemberID AND
                                                a.HEDISSubMetricID = a2.HEDISSubMetricID AND
                                                a2.ServiceDate BETWEEN @CCSStartDate
                                                              AND
                                                              @MeasureYearEnd
												AND (a2.Data_Source LIKE '%Cytology%')
                                        ) > 0 
										THEN 1
                                   ELSE 0
                              END,
        CCS_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordCCS a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        a2.EvidenceType IN ('Numerator', 'Cervical Cytology', 'CervicalCytology'/*, 'Cervical Cytology w/ HPV Test'*/) AND
                                        NOT (a2.PapTestResult = 'Inadequate' OR
                                             a2.PapTestResult = 'Other' OR
                                             (a2.PapTestResult = '' AND
											 ISNULL(a2.DocumentedResult, 0) = 0)
                                            ) AND
										@MemberAge BETWEEN 24 AND 64 AND                                          
                                        a2.ServiceDate BETWEEN @CCSStartDate
                                                       AND    @MeasureYearEnd
                                ) > 0 
								THEN 1
						   WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordCCS a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        a2.EvidenceType IN ('Numerator', 'Cervical Cytology', 'CervicalCytology') AND
                                        NOT (a2.PapTestResult = 'Inadequate' OR
                                             a2.PapTestResult = 'Other' OR
                                             (a2.PapTestResult = '' AND
											 ISNULL(a2.DocumentedResult, 0) = 0)
                                            ) AND
										@MemberAge BETWEEN 30 AND 64 AND  
										a2.ServiceDate >= DATEADD(yy, 30, @MemberDOB) AND                                         
                                        a2.ServiceDate BETWEEN @CCSStartDate4Years
                                                       AND    @MeasureYearEnd AND
										--Check for same-day HPV Test                                                     
										EXISTS (SELECT TOP 1 1 
												FROM   MedicalRecordCCS a3
														INNER JOIN Pursuit b3 ON a3.PursuitID = b3.PursuitID
														INNER JOIN PursuitEvent c3 ON a2.PursuitEventID = c3.PursuitEventID
												WHERE  b3.MemberID = b2.MemberID AND
														a3.EvidenceType IN ('HPV Test', 'HPVTest') AND
														NOT (a3.PapTestResult = 'Inadequate' OR
															 a3.PapTestResult = 'Other' OR
															 (a2.PapTestResult = '' AND
																ISNULL(a2.DocumentedResult, 0) = 0)
															) AND                                          
														a3.ServiceDate = a2.ServiceDate)
                                ) > 0 
								THEN 1
							WHEN (SELECT COUNT(*)
                                 FROM   MedicalRecordCCS a2
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                 WHERE  b2.MemberID = b.MemberID AND
                                        a2.EvidenceType IN ('Cervical Cytology w/ HPV Test') AND
                                        NOT (a2.PapTestResult = 'Inadequate' OR
                                             a2.PapTestResult = 'Other' OR
                                             (a2.PapTestResult = '' AND
											 ISNULL(a2.DocumentedResult, 0) = 0)
                                            ) AND
										@MemberAge BETWEEN 30 AND 64 AND  
										a2.ServiceDate >= DATEADD(yy, 30, @MemberDOB) AND                                         
                                        a2.ServiceDate BETWEEN @CCSStartDate4Years
                                                       AND    @MeasureYearEnd
                                ) > 0 
								THEN 1
                           ELSE 0
                      END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CCS' AND
        MemberID = @MemberID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL 
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordCCS a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
											a2.EvidenceType = 'Exclusion' AND  
											(a2.HystNoResidualCervixFlg = 1 OR a2.VaginalPapWithHystFlag = 1 OR a2.HystNoTestingFlag = 1) AND
                                            a2.ServiceDate BETWEEN d2.DateOfBirth 
                                                           AND
                                                              @MeasureYearEnd
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200),	(SELECT   MIN(CASE WHEN VaginalPapWithHystFlag = 1 THEN 'Vaginal Pap Smear in Conjunction with Documentation of Hysterectomy' 
																	WHEN HystNoResidualCervixFlg = 1 THEN HysterectomyType + ', No Residual Cervix'
																	WHEN HystNoTestingFlag = 1 THEN 'Hysterectomy, Pap Testing Not Needed'
																	END)
												   FROM     dbo.MedicalRecordCCS a2
															INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
															INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
															INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
												   WHERE    b2.MemberID = b.MemberID AND
															a2.EvidenceType = 'Exclusion' AND  
															(a2.HystNoResidualCervixFlg = 1 OR a2.VaginalPapWithHystFlag = 1 OR a2.HystNoTestingFlag = 1) AND
															a2.ServiceDate BETWEEN d2.DateOfBirth 
																		   AND
																			  @MeasureYearEnd))
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CCS' AND
        MemberID = @MemberID;


--Calculation of Hit Rules and Application to Scoring Table:
UPDATE  MemberMeasureMetricScoring
SET     --select  
        MedicalRecordHitCount = CASE WHEN CCS_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CCS_MR_Flag = 1 THEN 1
                              WHEN ISNULL(AdministrativeHitCount, CCS_Admin_VisitFlag) >= 1 THEN 1
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


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'CCS', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents


GO
GRANT EXECUTE ON  [dbo].[ScoreCCS] TO [Support]
GO
