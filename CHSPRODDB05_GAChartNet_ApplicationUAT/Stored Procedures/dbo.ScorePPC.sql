SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for PPC measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordPPC table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScorePPC '78568140'

CREATE PROCEDURE [dbo].[ScorePPC] @MemberID int
AS 

SET NOCOUNT ON;

SELECT * INTO #PPCBase FROM dbo.GetPPCDateRanges(@MemberID);

CREATE UNIQUE CLUSTERED INDEX IX_#PPCBase ON #PPCBase (MemberMeasureSampleID);
CREATE INDEX IX_#PPCBase2 ON #PPCBase (MemberID, MeasureID); 

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_PPC1') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_PPC1

SELECT  MemberMeasureMetricScoringID,
        PPC_Prenatal_Admin_VisitFlag = AdministrativeHitCount,
        PPC_Prenatal_MR_VisitFlag = CASE WHEN (SELECT   COUNT(*)
                                               FROM     MedicalRecordPPC a2
                                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                               WHERE    b2.MemberID = b.MemberID AND                                            
                                                        a2.NumeratorType = 'Prenatal' AND
                                                        ((PrenatalServicingProviderType = 'OBGYN' AND
                                                          --OBGYNVisitFlag = '1' AND
                                                          ISNULL(OBGYNVisitSource,
                                                              '') <> '' AND
                                                          (ISNULL(OBGYNVisitSource, '') <> 'Any visit with a diagnosis of pregnancy' AND
														  ISNULL(OBGYNVisitSource, '') <> 'Any visit with a principal diagnosis of pregnancy' AND
                                                           b.PPCEnrollmentCategoryID IN (
                                                           1, 2) OR
                                                           b.PPCEnrollmentCategoryID IN (
                                                           3))) OR
                                                         (PrenatalServicingProviderType = 'PCP' AND
                                                          --PCPVisitFlag = '1' AND
                                                          PCPDiagnosisOfPregnancy = '1' AND
                                                          ISNULL(PCPVisitSource,
                                                              '') <> '') OR
                                                         (PrenatalServicingProviderType = 'PCAP' AND
                                                          --PCAPVisitFlag = '1' AND
                                                          ISNULL(PCAPVisitSource,
                                                              '') <> '')) AND
                                                        (ISNULL(PCPVisitSource, '') <> 'Any visit with a diagnosis of pregnancy' AND
														ISNULL(PCPVisitSource, '') <> 'Any visit with a principal diagnosis of pregnancy' AND
                                                         b.PPCEnrollmentCategoryID IN (
                                                         1, 2) OR
                                                         b.PPCEnrollmentCategoryID IN (
                                                         3)) AND
                                                        ((a2.ServiceDate BETWEEN b.PPCPrenatalCareStartDateScore
                                                              AND
                                                              b.PPCPrenatalCareEndDateScore AND AllowConcurrentScoringRanges = 0) OR
														 (a2.ServiceDate BETWEEN b.PPCPrenatalCareStartDate1
                                                              AND
                                                              b.PPCPrenatalCareEndDate1 AND AllowConcurrentScoringRanges = 1) OR
                                                         (a2.ServiceDate BETWEEN b.PPCPrenatalCareStartDate2
                                                              AND
                                                              b.PPCPrenatalCareEndDate2 AND AllowConcurrentScoringRanges = 1) OR
                                                         (a2.ServiceDate BETWEEN b.PPCPrenatalCareStartDate3
                                                              AND
                                                              b.PPCPrenatalCareEndDate3 AND AllowConcurrentScoringRanges = 1))) > 0
                                         THEN 1
                                         ELSE 0
                                    END
INTO    #SubMetricRuleComponents_PPC1
FROM    MemberMeasureMetricScoring a
        INNER JOIN #PPCBase b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'PPC1' AND
        MemberID = @MemberID


IF OBJECT_ID('tempdb..#SubMetricRuleComponents_PPC2') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_PPC2

SELECT  MemberMeasureMetricScoringID,
        PPC_Postpartum_Admin_VisitFlag = AdministrativeHitCount,
        PPC_Postpartum_MR_VisitFlag = CASE WHEN (SELECT COUNT(*) --select *
                                                 FROM   MedicalRecordPPC a2
                                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                 WHERE  b2.MemberID = b.MemberID AND
                                                        a2.NumeratorType = 'Postpartum' AND
                                                        (--PostpartumVisitFlag = '1' AND
                                                         ISNULL(PostpartumVisitSource,
                                                              '') <> '') AND
                                                        ((a2.ServiceDate BETWEEN b.PPCPostpartumCareStartDateScore
                                                              AND
                                                              b.PPCPostpartumCareEndDateScore AND AllowConcurrentScoringRangesPostpartum = 0) OR
														 (a2.ServiceDate BETWEEN b.PPCPostpartumCareStartDate1
                                                              AND
                                                              b.PPCPostpartumCareEndDate1 AND AllowConcurrentScoringRangesPostpartum = 1) OR
                                                         (a2.ServiceDate BETWEEN b.PPCPostpartumCareStartDate2
                                                              AND
                                                              b.PPCPostpartumCareEndDate2 AND AllowConcurrentScoringRangesPostpartum = 1))) > 0
                                           THEN 1
                                           ELSE 0
                                      END
INTO    #SubMetricRuleComponents_PPC2
FROM    MemberMeasureMetricScoring a
        INNER JOIN #PPCBase b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'PPC2' AND
        MemberID = @MemberID




--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN PPC_Prenatal_MR_VisitFlag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN PPC_Prenatal_MR_VisitFlag = 1 THEN 1
                              WHEN PPC_Prenatal_Admin_VisitFlag = 1 THEN 1
							  WHEN AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents_PPC1 c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN PPC_Postpartum_MR_VisitFlag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN PPC_Postpartum_MR_VisitFlag = 1 THEN 1
                              WHEN PPC_Postpartum_Admin_VisitFlag = 1 THEN 1
							  WHEN AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents_PPC2 c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'PPC', @MemberID = @MemberID;


--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************


IF OBJECT_ID('tempdb..#SubMetricRuleComponents_PPC1') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_PPC1

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_PPC2') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_PPC2
GO
GRANT EXECUTE ON  [dbo].[ScorePPC] TO [Support]
GO
