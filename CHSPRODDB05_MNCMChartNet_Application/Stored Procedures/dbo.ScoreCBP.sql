SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for CBP measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the MedicalRecordCBP table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreABA '78560770'

CREATE PROCEDURE [dbo].[ScoreCBP] @MemberID int
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

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime
DECLARE @PriorMeasureYearStart datetime
DECLARE @MeasureYearHalfwayPoint datetime

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @MeasureYearHalfwayPoint = dbo.MeasureYearHalfway(0)


IF OBJECT_ID('tempdb..#cbp_conf') IS NOT NULL
    DROP TABLE #cbp_conf

SELECT  MemberID,
        MIN(CASE WHEN a.DocumentationType = 'Undated Problem List' THEN dbo.MeasureYearStartDate() ELSE a.ServiceDate END) AS ConfDate,
        CBPConfFlag = 'Y'
INTO    #cbp_conf
FROM    MedicalRecordCBPConf a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
WHERE   MemberID = @MemberID AND
        (NotationType IS NOT NULL AND
         DocumentationType = 'Undated Problem list' OR
         (NotationType IS NOT NULL AND
          ServiceDate <= @MeasureYearHalfwayPoint
         )
        )
GROUP BY MemberID;

IF OBJECT_ID('tempdb..#cbp_bp_services') IS NOT NULL
    DROP TABLE #cbp_bp_services

SELECT  MedicalRecordKey = 'MR' + CONVERT(varchar(10), MedicalRecordKey),
        b.MemberID,
        a.ServiceDate,
        SystolicLevel = a.SystolicLevel,
        DiastolicLevel = a.DiastolicLevel,
        event_type = 'medical record'
INTO    #cbp_bp_services
FROM    MedicalRecordCBPReading a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
        INNER JOIN #cbp_conf AS c ON b.MemberID = c.MemberID AND
                                     a.ServiceDate > ISNULL(c.ConfDate,
                                                            '1/1/1900')
WHERE   b.MemberID = @MemberID


IF OBJECT_ID('tempdb..#MedicalRecord_BP_Reading_most_recent_date') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Reading_most_recent_date

SELECT	DISTINCT
        MemberID,
        medical_record_date = (SELECT TOP 1
                                        ServiceDate
                               FROM     #cbp_bp_services a2
                               WHERE    a2.event_type = 'medical record' AND
                                        a.MemberID = a2.MemberID AND
                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                       AND    @MeasureYearEnd
                               ORDER BY ServiceDate DESC
                              ),
        hybrid_record_date = (SELECT TOP 1
                                        ServiceDate
                              FROM      #cbp_bp_services a2
                              WHERE     a.MemberID = a2.MemberID AND
                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                       AND    @MeasureYearEnd
                              ORDER BY  ServiceDate DESC
                             )
INTO    #MedicalRecord_BP_Reading_most_recent_date
FROM    #cbp_bp_services a

IF OBJECT_ID('tempdb..#MedicalRecord_BP_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Control

SELECT	DISTINCT
        MemberID,
        medical_record_date,
        hybrid_record_date,
        MedicalRecord_Systolic = (SELECT TOP 1
                                            ISNULL(SystolicLevel, 9999)
                                  FROM      #cbp_bp_services a2
                                  WHERE     a2.event_type = 'medical record' AND
                                            a.MemberID = a2.MemberID AND
                                            a.medical_record_date = a2.ServiceDate
                                  ORDER BY  ISNULL(SystolicLevel, 9999)
                                 ),
        MedicalRecord_Diastolic = (SELECT TOP 1
                                            ISNULL(DiastolicLevel, 9999)
                                   FROM     #cbp_bp_services a2
                                   WHERE    a2.event_type = 'medical record' AND
                                            a.MemberID = a2.MemberID AND
                                            a.medical_record_date = a2.ServiceDate
                                   ORDER BY ISNULL(DiastolicLevel, 9999)
                                  ),
        Hybrid_Systolic = (SELECT TOP 1
                                    ISNULL(SystolicLevel, 9999)
                           FROM     #cbp_bp_services a2
                           WHERE    a.MemberID = a2.MemberID AND
                                    a.hybrid_record_date = a2.ServiceDate
                           ORDER BY ISNULL(SystolicLevel, 9999)
                          ),
        Hybrid_Diastolic = (SELECT TOP 1
                                    ISNULL(DiastolicLevel, 9999)
                            FROM    #cbp_bp_services a2
                            WHERE   a.MemberID = a2.MemberID AND
                                    a.hybrid_record_date = a2.ServiceDate
                            ORDER BY ISNULL(DiastolicLevel, 9999)
                           )
INTO    #MedicalRecord_BP_Control
FROM    #MedicalRecord_BP_Reading_most_recent_date a


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        CBP_Admin_VisitFlag = 0,
        BP_Control140_MR_Flag = CASE WHEN (SELECT   COUNT(*)
														--select *
                                           FROM     #MedicalRecord_BP_Control a2
                                           WHERE    a2.MemberID = b.MemberID AND
                                                    MedicalRecord_Systolic < 140 AND
                                                    MedicalRecord_Diastolic < 90 AND
                                                    a2.medical_record_date BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                          ) > 0 THEN 1
                                     ELSE 0
                                END,
        BP_Control150_MR_Flag = CASE WHEN (SELECT   COUNT(*)
														--select *
                                           FROM     #MedicalRecord_BP_Control a2
                                           WHERE    a2.MemberID = b.MemberID AND
                                                    MedicalRecord_Systolic < 150 AND
                                                    MedicalRecord_Diastolic < 90 AND
                                                    a2.medical_record_date BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                          ) > 0 THEN 1
                                     ELSE 0
                                END,
        BP_Control140_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
														--select *
                                            FROM    #MedicalRecord_BP_Control a2
                                            WHERE   a2.MemberID = b.MemberID AND
                                                    Hybrid_Systolic < 140 AND
                                                    Hybrid_Diastolic < 90 AND
                                                    a2.hybrid_record_date BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        BP_Control150_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
														--select *
                                            FROM    #MedicalRecord_BP_Control a2
                                            WHERE   a2.MemberID = b.MemberID AND
                                                    Hybrid_Systolic < 150 AND
                                                    Hybrid_Diastolic < 90 AND
                                                    a2.hybrid_record_date BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        Has_Diabetes = CASE WHEN (a.SuppIndicator = 1) OR
                                 (b.DiabetesDiagnosisDate IS NOT NULL AND
                                  b.DiabetesDiagnosisDate BETWEEN @BeginOfPrevYear
                                                          AND @EndOfYear
                                 ) THEN 1
                            ELSE 0
                       END,
        Cancel_Diabetes = CASE WHEN (SELECT COUNT(*)
                                     FROM   dbo.MedicalRecordCBPDiabetes AS a2
                                            INNER JOIN dbo.Pursuit AS b2 ON b2.PursuitID = a2.PursuitID
                                     WHERE  b2.MemberID = b.MemberID AND
                                            a2.NoDiabetesDiagnosisFlag = 1 AND
                                            a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                           AND
                                                              @EndOfYear
                                    ) > 0 AND
                                    (SELECT COUNT(*)
                                     FROM   dbo.MedicalRecordCBPDiabetes AS a2
                                            INNER JOIN dbo.Pursuit AS b2 ON b2.PursuitID = a2.PursuitID
                                     WHERE  b2.MemberID = b.MemberID AND
                                            a2.DiabetesRefutedFlag = 1 AND
                                            a2.ServiceDate BETWEEN @BeginOfPrevYear
                                                           AND
                                                              @EndOfYear
                                    ) > 0 THEN 1
                               ELSE 0
                          END,
        Member_Age = dbo.GetAgeAsOf(d.DateOfBirth, @EndOfYear)
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
        INNER JOIN dbo.Member d ON d.MemberID = b.MemberID AND
                                   d.Product = b.Product AND
                                   d.ProductLine = b.ProductLine
WHERE   c.HEDISSubMetricCode = 'CBP' AND
        b.MemberID = @MemberID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordCBPExclusion a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
                                            a2.ExclusionType IS NOT NULL AND
                                            ((a2.ExclusionType LIKE '%ESRD%' AND
                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                             AND
                                                              @EndOfYear
                                             ) OR
                                             (a2.ExclusionType LIKE '%kidney%' AND
                                              a2.ExclusionType LIKE '%transplant%' AND
                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                             AND
                                                              @EndOfYear
                                             ) OR
                                             (a2.ExclusionType LIKE '%dialysis%' AND
                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                             AND
                                                              @EndOfYear
                                             ) OR
                                             (a2.ExclusionType NOT LIKE '%ESRD%' AND
                                              NOT (a2.ExclusionType LIKE '%kidney%' AND
                                                   a2.ExclusionType LIKE '%transplant%'
                                                  ) AND
                                              a2.ExclusionType NOT LIKE '%dialysis%' AND
                                              a2.ExclusionType <> '' AND
                                              a2.ExclusionType NOT LIKE '%none%' AND
                                              a2.ServiceDate BETWEEN @BeginOfYear
                                                             AND
                                                              @EndOfYear
                                             )
                                            )
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordCBPExclusion a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.ExclusionType IS NOT NULL AND
                                                              ((a2.ExclusionType LIKE '%ESRD%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType LIKE '%kidney%' AND
                                                              a2.ExclusionType LIKE '%transplant%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType LIKE '%dialysis%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType NOT LIKE '%ESRD%' AND
                                                              NOT (a2.ExclusionType LIKE '%kidney%' AND
                                                              a2.ExclusionType LIKE '%transplant%'
                                                              ) AND
                                                              a2.ExclusionType NOT LIKE '%dialysis%' AND
                                                              a2.ExclusionType <> '' AND
                                                              a2.ExclusionType NOT LIKE '%none%' AND
                                                              a2.ServiceDate BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                                              )
                                                              )
                                                          ) > 0
                                                     THEN 'Excluded for ' +
                                                          (SELECT TOP 1
                                                              a2.ExclusionType
                                                           FROM
                                                              dbo.MedicalRecordCBPExclusion a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.ExclusionType IS NOT NULL AND
                                                              ((a2.ExclusionType LIKE '%ESRD%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType LIKE '%kidney%' AND
                                                              a2.ExclusionType LIKE '%transplant%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType LIKE '%dialysis%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @EndOfYear
                                                              ) OR
                                                              (a2.ExclusionType NOT LIKE '%ESRD%' AND
                                                              NOT (a2.ExclusionType LIKE '%kidney%' AND
                                                              a2.ExclusionType LIKE '%transplant%'
                                                              ) AND
                                                              a2.ExclusionType NOT LIKE '%dialysis%' AND
                                                              a2.ExclusionType <> '' AND
                                                              a2.ExclusionType NOT LIKE '%none%' AND
                                                              a2.ServiceDate BETWEEN @BeginOfYear
                                                              AND
                                                              @EndOfYear
                                                              )
                                                              )
                                                           ORDER BY a2.ServiceDate
                                                          )
                                                END)
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CBP' AND
        MemberID = @MemberID



--Calculation of Hit Rules and Application to Scoring Table:

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN BP_Control140_MR_Flag = 1 AND
                                          ISNULL(d.CountConf, 0) > 0 THEN 1
                                     WHEN BP_Control150_MR_Flag = 1 AND
                                          (Has_Diabetes = 0 OR Cancel_Diabetes = 1) AND
                                          Member_Age BETWEEN 60 AND 85 AND
                                          ISNULL(d.CountConf, 0) > 0 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN BP_Control140_HYB_Flag = 1 AND
                                   ISNULL(d.CountConf, 0) > 0 THEN 1
                              WHEN BP_Control150_HYB_Flag = 1 AND
                                   (Has_Diabetes = 0 OR Cancel_Diabetes = 1) AND
                                   Member_Age BETWEEN 60 AND 85 AND
                                   ISNULL(d.CountConf, 0) > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionCount = CASE WHEN x.ExclusionFlag > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = x.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        LEFT OUTER JOIN #Exclusions AS x ON a.MemberMeasureMetricScoringID = x.MemberMeasureMetricScoringID
        OUTER APPLY (SELECT COUNT(*) AS CountConf
                     FROM   #cbp_conf
                    ) AS d

EXEC dbo.RunPostScoringSteps @HedisMeasure = 'CBP', @MemberID = @MemberID;

--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************

IF OBJECT_ID('tempdb..#cbp_conf') IS NOT NULL
    DROP TABLE #cbp_conf

IF OBJECT_ID('tempdb..#cbp_bp_services') IS NOT NULL
    DROP TABLE #cbp_bp_services

IF OBJECT_ID('tempdb..#MedicalRecord_BP_Reading_most_recent_date') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Reading_most_recent_date

IF OBJECT_ID('tempdb..#MedicalRecord_BP_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Control

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL
    DROP TABLE #SubMetricRuleComponents




GO
GRANT EXECUTE ON  [dbo].[ScoreCBP] TO [Support]
GO
