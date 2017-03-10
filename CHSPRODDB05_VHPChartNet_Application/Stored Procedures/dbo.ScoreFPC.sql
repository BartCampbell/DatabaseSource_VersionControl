SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for FPC measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordFPC table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScorePPC '78568140'

CREATE PROCEDURE [dbo].[ScoreFPC] @MemberID int
AS 

SET NOCOUNT ON;

/******************************************
--FPC Scoring Options

1 = Combine admin plus medical record totals
2 = Use the higher total of admin vs medical record
3 = Use medical record total if present at all, otherwise admin

******************************************/

DECLARE @FPCScoringMethodOption tinyint;
SET @FPCScoringMethodOption = dbo.GetFPCScoringMethodOption();

SELECT * INTO #FPCBase FROM dbo.GetFPCDateRanges(@MemberID);          

CREATE UNIQUE INDEX IX_#FPCBase ON #FPCBase (MemberMeasureSampleID);

SELECT  b.MemberMeasureSampleID,
        c.SourceType,
        c.ServiceDate
INTO    #FPCVisits
FROM    #FPCBase AS b
        CROSS APPLY (SELECT DISTINCT
                            'MedicalRecord' AS SourceType,
                            a2.ServiceDate
                     FROM   MedicalRecordFPCPre a2
                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                     WHERE  b2.MemberID = b.MemberID AND
                            ((PrenatalServicingProviderType = 'OBGYN' AND
                              --OBGYNVisitFlag = '1' AND
                              ISNULL(OBGYNSource, '') <> ''
                             ) OR
                             (PrenatalServicingProviderType = 'PCP' AND
                              --PCPVisitFlag = '1' AND
                              ISNULL(PCPSource, '') <> ''
                             )
                            ) AND
                            a2.ServiceDate BETWEEN b.LastSegBeginDate
                                           AND     b.DeliveryDate
                    ) AS c
UNION ALL
SELECT  b.MemberMeasureSampleID,
        c.SourceType,
        c.ServiceDate
FROM    #FPCBase AS b
        CROSS APPLY (SELECT DISTINCT
                            'Administrative' AS SourceType,
                            AV.ServiceDate
                     FROM   dbo.AdministrativeEvent AS AV
                            INNER JOIN dbo.Measure AS M ON AV.MeasureID = M.MeasureID AND
                                                           M.HEDISMeasure = 'FPC'
                     WHERE  AV.MemberID = b.MemberID AND
                            AV.Data_Source LIKE '%Prenatal%' AND
                            AV.ServiceDate BETWEEN b.LastSegBeginDate
                                           AND     b.DeliveryDate
                    ) AS c 

CREATE UNIQUE CLUSTERED INDEX IX_#FPCVisits ON #FPCVisits (MemberMeasureSampleID, ServiceDate, SourceType);

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_FPC_Visits') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_FPC_Visits;

SELECT  b.MemberID,
        b.MeasureID,
        b.MemberMeasureSampleID,
        FPC_Prenatal_Expected_Visits = ISNULL(b.CountExpected, 100000), --100000: Put in as catch all, so at least "< 21" is marked
        FPC_Prenatal_Admin_Visits = ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'Administrative' THEN c.ServiceDate END), 0),
        FPC_Prenatal_MR_Visits = ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0),
		FPC_Prenatal_Hyb_Visits = CASE @FPCScoringMethodOption
									WHEN 1 THEN ISNULL(COUNT(DISTINCT c.ServiceDate), 0)
									WHEN 2 THEN 
											CASE WHEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'Administrative' THEN c.ServiceDate END), 0) >
													ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0)
												THEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'Administrative' THEN c.ServiceDate END), 0)
												ELSE ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0)	
												END
									WHEN 3 THEN
											CASE WHEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0) = 0
												THEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'Administrative' THEN c.ServiceDate END), 0)
												ELSE ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0)	
												END
									ELSE 0
									END,
		ScoringSource = CASE @FPCScoringMethodOption
									WHEN 1 THEN 'Combined'
									WHEN 2 THEN 
											CASE WHEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'Administrative' THEN c.ServiceDate END), 0) >
													ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0)
												THEN 'Administrative'
												ELSE 'MedicalRecord'	
												END
									WHEN 3 THEN
											CASE WHEN ISNULL(COUNT(DISTINCT CASE WHEN c.SourceType = 'MedicalRecord' THEN c.ServiceDate END), 0) = 0
												THEN 'Administrative'
												ELSE 'MedicalRecord'	
												END
									ELSE 'Unknown'
									END
INTO    #SubMetricRuleComponents_FPC_Visits
FROM    #FPCBase AS b
		LEFT OUTER JOIN #FPCVisits AS c
				ON b.MemberMeasureSampleID = c.MemberMeasureSampleID
GROUP BY b.MemberID,
        b.MeasureID,
        b.MemberMeasureSampleID,
        b.CountExpected;

--SELECT * FROM #FPCBase;
--SELECT * FROM #FPCVisits;
--SELECT * FROM #SubMetricRuleComponents_FPC_Visits;

--Sets Hybrid Results to the greater of Admin vs. Hybrid, instead of the distinct number of dates between the two (per HEDIS specifications).
UPDATE #SubMetricRuleComponents_FPC_Visits SET FPC_Prenatal_Hyb_Visits = CASE WHEN FPC_Prenatal_Admin_Visits > FPC_Prenatal_MR_Visits THEN FPC_Prenatal_Admin_Visits ELSE FPC_Prenatal_Hyb_Visits END;

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_FPC') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_FPC

SELECT  a.MemberMeasureMetricScoringID,
		d.ScoringSource,
		AdministrativeHitCount = CASE WHEN HEDISSubMetricCode = 'FPC0'
                                     THEN CASE WHEN (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC1'
                                     THEN CASE WHEN (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .41 AND
                                                    (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC2'
                                     THEN CASE WHEN (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .61 AND
                                                    (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .41 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC3'
                                     THEN CASE WHEN (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .81 AND
                                                    (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .61 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC4'
                                     THEN CASE WHEN (FPC_Prenatal_Admin_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .81 THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END,
        MedicalRecordHitCount = CASE WHEN HEDISSubMetricCode = 'FPC0'
                                     THEN CASE WHEN (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC1'
                                     THEN CASE WHEN (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .41 AND
                                                    (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC2'
                                     THEN CASE WHEN (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .61 AND
                                                    (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .41 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC3'
                                     THEN CASE WHEN (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .81 AND
                                                    (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .61 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC4'
                                     THEN CASE WHEN (FPC_Prenatal_MR_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .81 THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN HEDISSubMetricCode = 'FPC0'
                                     THEN CASE WHEN (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC1'
                                     THEN CASE WHEN (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .41 AND
                                                    (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .21 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC2'
                                     THEN CASE WHEN (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .61 AND
                                                    (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .41 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC3'
                                     THEN CASE WHEN (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) < .81 AND
                                                    (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .61 THEN 1
                                               ELSE 0
                                          END
                                     WHEN HEDISSubMetricCode = 'FPC4'
                                     THEN CASE WHEN (FPC_Prenatal_Hyb_Visits *
                                                     1.00) /
                                                    (FPC_Prenatal_Expected_Visits *
                                                     1.00) >= .81 THEN 1
                                               ELSE 0
                                          END
                                     ELSE 0
                                END
INTO    #SubMetricRuleComponents_FPC
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
        INNER JOIN #SubMetricRuleComponents_FPC_Visits d ON a.MemberMeasureSampleID = d.MemberMeasureSampleID
WHERE   HEDISSubMetricCode IN ('FPC0', 'FPC1', 'FPC2', 'FPC3', 'FPC4') 


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     AdministrativeHitCount = FPC_Prenatal_Admin_Visits,
		MedicalRecordHitCount = FPC_Prenatal_MR_Visits,
        HybridHitCount = FPC_Prenatal_Hyb_Visits
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
		INNER JOIN #SubMetricRuleComponents_FPC_Visits AS c ON b.MemberMeasureSampleID = c.MemberMeasureSampleID
WHERE	a.HEDISSubMetricID IN (SELECT HEDISSubMetricID FROM dbo.HEDISSubMetric AS t WHERE t.HEDISSubMetricCode = 'FPCRatio');


--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     AdministrativeHitCount = c.AdministrativeHitCount,
		MedicalRecordHitCount = c.MedicalRecordHitCount,
        HybridHitCount = c.HybridHitCount
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents_FPC c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'FPC', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_FPC_Visits') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_FPC_Visits

IF OBJECT_ID('tempdb..#SubMetricRuleComponents_FPC') IS NOT NULL 
    DROP TABLE #SubMetricRuleComponents_FPC









GO
GRANT EXECUTE ON  [dbo].[ScoreFPC] TO [Support]
GO
