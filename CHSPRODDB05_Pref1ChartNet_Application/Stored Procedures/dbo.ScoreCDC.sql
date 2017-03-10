SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--This procedure accepts a MemberID and then updates the contents of 
--the MemberMeasureMetricScoring table for CDC measures for this member.

--It uses administrative claims data from the AdministrativeEvent table.

--It uses Medical Record data from the following tables:
--MedicalRecordCDC_HbA1c
--MedicalRecordCDC_BloodPressure
--MedicalRecordCDC_EyeExam
--MedicalRecordCDC_LDLC
--MedicalRecordCDC_Nephropathy

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreCDC '78560770'

CREATE PROCEDURE [dbo].[ScoreCDC] @MemberID int
AS --*****************************************

SET NOCOUNT ON;

DECLARE @AllowableDays int;
SELECT  @AllowableDays = ISNULL(dbo.GetLabVarianceDaysAllowed(), 0);

DECLARE @MeasureYearStart datetime
DECLARE @MeasureYearEnd datetime
DECLARE @PriorMeasureYearStart datetime
DECLARE @PriorMeasureYearEnd datetime
DECLARE @HbA1cGoodcontrolCutoff int
DECLARE @HbA1cGoodcontrol8Cutoff int;

SELECT  @MeasureYearStart = dbo.MeasureYearStartDate()
SELECT  @MeasureYearEnd = dbo.MeasureYearEndDate()
SELECT  @PriorMeasureYearStart = dbo.MeasureYearStartDateYearOffset(-1)
SELECT  @PriorMeasureYearEnd = dbo.MeasureYearEndDateYearOffset(-1)

SELECT  @HbA1cGoodcontrolCutoff = dbo.GetHbA1cGoodControlCutoffValue()
SELECT  @HbA1cGoodcontrol8Cutoff = dbo.GetHbA1cGoodControl8CutoffValue()


IF OBJECT_ID('tempdb..#cdc_hba1c_services') IS NOT NULL
    DROP TABLE #cdc_hba1c_services

SELECT  MedicalRecordKey = 'MR' + CONVERT(varchar(10), MedicalRecordKey),
        MemberID,
        ServiceDate,
        EvalDate = DATEADD(DAY, @AllowableDays, ServiceDate),
        HbA1cResult = CASE WHEN ISNUMERIC(HbA1cResult) = 1 AND
                                HbA1cResult = 0.00 THEN 9999
                           WHEN ISNUMERIC(HbA1cResult) = 1 THEN HbA1cResult
                           WHEN HbA1cResult IS NULL OR
                                HbA1cResult = '' THEN 9999
                      END,
        event_type = 'medical record',
        data_type = CONVERT(varchar(20), 'medical record')
INTO    #cdc_hba1c_services
FROM    MedicalRecordCDC_HbA1c a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
WHERE   MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd
UNION ALL
SELECT  'AD' + CONVERT(varchar(10), AdministrativeEventID),
        MemberID,
        ServiceDate,
        EvalDate = ServiceDate,
        LabResult = CASE WHEN CPT_IICode IN ('3044F') THEN 6.9
                         WHEN CPT_IICode IN ('3045F') THEN 8.1
                         WHEN CPT_IICode IN ('3046F') THEN 9.1
                         WHEN ISNUMERIC(LabResult) = 1 AND
                              LabResult = 0.00 THEN 9999
                         WHEN ISNUMERIC(LabResult) = 1 THEN LabResult
                         WHEN LabResult IS NULL OR
                              LabResult = '' THEN 9999
                    END,
        event_type = 'administrative',
        data_type = CASE WHEN LOINC IN ('4548-4', '4549-2', '17856-6',
                                        '59261-8', '62388-4', '71875-9')
                         THEN CONVERT(varchar(20), 'automated')
                         WHEN ProcedureCode IN ('83036', '83037')
                         THEN CONVERT(varchar(20), 'automated')
                         WHEN CPT_IICode IN ('3044F', '3045F', '3046F',
                                             '3047F')
                         THEN CONVERT(varchar(20), 'automated') 
						 WHEN ProcedureCode IN ('CDC1-N-HbA1c1') --IMI's Supplemental data codes
                         THEN CONVERT(varchar(20), 'automated') 
                         WHEN ProcedureCode IN ('3044F', '3045F', '3046F',
                                                '3047F') --Added as safety net for CPT2 codes in the procedure code field
                         THEN CONVERT(varchar(20), 'automated')
                         ELSE CONVERT(varchar(20), 'claims')
                    END
FROM    AdministrativeEvent a
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode IN ('CDC1', 'CDC2', 'CDC3', 'CDC10') AND
        MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd

DELETE  FROM #cdc_hba1c_services
WHERE   data_type = 'claims' AND
        event_type = 'administrative';

UPDATE  t
SET     HbA1cResult = result.HbA1cResult
FROM    #cdc_hba1c_services AS t
        CROSS APPLY (SELECT TOP 1
                            t2.HbA1cResult
                     FROM   #cdc_hba1c_services AS t2
                     WHERE  (CONVERT(decimal(18, 6), t2.HbA1cResult) < 9999) AND
                            (t2.ServiceDate BETWEEN DATEADD(dd,
                                                            @AllowableDays *
                                                            -1, t.ServiceDate)
                                            AND     DATEADD(dd, -1,
                                                            t.ServiceDate)) AND
                            (t2.MedicalRecordKey <> t.MedicalRecordKey)
                     ORDER BY t2.ServiceDate DESC
                    ) AS result
WHERE   (CONVERT(decimal(18, 6), t.HbA1cResult) = 9999);

IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_PoorControl_most_recent') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_PoorControl_most_recent


SELECT	DISTINCT
        MemberID,
        medical_record_key = (SELECT TOP 1
                                        MedicalRecordKey
                              FROM      #cdc_hba1c_services a2
                              WHERE     --a2.event_type = 'medical record' AND
                                        a.MemberID = a2.MemberID AND
                                    a2.data_type <> 'claims'
                              ORDER BY  EvalDate DESC,
                                        ISNULL(HbA1cResult, 9999),
										a2.MedicalRecordKey
                             ),
        hybrid_record_key = (SELECT TOP 1
                                    MedicalRecordKey
                             FROM   #cdc_hba1c_services a2
                             WHERE  a.MemberID = a2.MemberID AND
                                    a2.data_type <> 'claims'
                             ORDER BY EvalDate DESC,
                                    ISNULL(HbA1cResult, 9999),
									a2.MedicalRecordKey
                            )
INTO    #MedicalRecord_HbA1C_PoorControl_most_recent
FROM    #cdc_hba1c_services a


IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_PoorControl') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_PoorControl

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #MedicalRecord_HbA1C_PoorControl
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.medical_record_key


IF OBJECT_ID('tempdb..#Hybrid_HbA1C_PoorControl') IS NOT NULL
    DROP TABLE #Hybrid_HbA1C_PoorControl

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #Hybrid_HbA1C_PoorControl
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.hybrid_record_key


IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_GoodControl') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_GoodControl

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #MedicalRecord_HbA1C_GoodControl
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.medical_record_key


IF OBJECT_ID('tempdb..#Hybrid_HbA1C_GoodControl') IS NOT NULL
    DROP TABLE #Hybrid_HbA1C_GoodControl

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #Hybrid_HbA1C_GoodControl
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.hybrid_record_key


IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_GoodControl_8') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_GoodControl_8

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #MedicalRecord_HbA1C_GoodControl_8
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.medical_record_key


IF OBJECT_ID('tempdb..#Hybrid_HbA1C_GoodControl_8') IS NOT NULL
    DROP TABLE #Hybrid_HbA1C_GoodControl_8

SELECT  a.MemberID,
        ServiceDate,
        HbA1cResult
INTO    #Hybrid_HbA1C_GoodControl_8
FROM    #cdc_hba1c_services a
        INNER JOIN #MedicalRecord_HbA1C_PoorControl_most_recent b ON a.MedicalRecordKey = b.hybrid_record_key


IF OBJECT_ID('tempdb..#cdc_ldl_services') IS NOT NULL
    DROP TABLE #cdc_ldl_services

SELECT  MedicalRecordKey = 'MR' + CONVERT(varchar(10), MedicalRecordKey),
        MemberID,
        ServiceDate,
        EvalDate = DATEADD(DAY, @AllowableDays, ServiceDate),
        LDLCResult = CASE WHEN NumeratorType = 'Friedewald' AND
                               TriglyceridesLevelResult <= 400
                          THEN TotalCholesteralLevelResult - HDLLevelResult -
                               (TriglyceridesLevelResult / 5) -
                               ISNULL(LipoproteinLevelResult, 0) * (0.3)
                          WHEN ISNUMERIC(LDLCResult) = 1 AND
                               LDLCResult = 0.00 THEN 9999
                          WHEN LDLCResult IS NULL THEN 9999
                          WHEN LDLCTestFlag = 0 THEN 9999
                          ELSE LDLCResult
                     END,
        event_type = 'medical record',
        data_type = CONVERT(varchar(20), 'medical record')
INTO    #cdc_ldl_services
FROM    MedicalRecordCDC_LDLC a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
WHERE   MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd
UNION ALL
SELECT  'AD' + CONVERT(varchar(10), AdministrativeEventID),
        MemberID,
        ServiceDate,
        EvalDate = ServiceDate,
        LabResult = CASE WHEN CPT_IICode IN ('3048F') THEN 99
                         WHEN CPT_IICode IN ('3049F') THEN 129
                         WHEN CPT_IICode IN ('3050F') THEN 131
                         WHEN ISNUMERIC(LabResult) = 1 AND
                              LabResult = 0.00 THEN 9999
                         WHEN ISNUMERIC(LabResult) = 1 THEN LabResult
                         WHEN LabResult IS NULL THEN 9999
                    END,
        event_type = 'administrative',
        data_type = CASE WHEN LOINC IN ('2089-1', '12773-8', '13457-7',
                                        '18261-8', '18262-6', '22748-8',
                                        '24331-1', '39469-2', '49132-4',
                                        '55440-2')
                         THEN CONVERT(varchar(20), 'automated')
                         WHEN ProcedureCode IN ('80061', '83700', '83701',
                                                '83704', '83721')
                         THEN CONVERT(varchar(20), 'automated')
                         WHEN CPT_IICode IN ('3048F', '3049F', '3050F')
                         THEN CONVERT(varchar(20), 'automated')
						 WHEN ProcedureCode IN ('CDC1-N-HbA1c1') --IMI's Supplemental data codes
                         THEN CONVERT(varchar(20), 'automated') 
                         WHEN ProcedureCode IN ('3048F', '3049F', '3050F') --Added as safety net for CPT2 codes in the procedure code field
                              THEN CONVERT(varchar(20), 'automated')
                         ELSE CONVERT(varchar(20), 'claims')
                    END
FROM    AdministrativeEvent a
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode IN ('CDC5', 'CDC6') AND
        MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd


IF OBJECT_ID('tempdb..#MedicalRecord_LDL_Control_most_recent') IS NOT NULL
    DROP TABLE #MedicalRecord_LDL_Control_most_recent

SELECT	DISTINCT
        MemberID,
        medical_record_key = (SELECT TOP 1
                                        MedicalRecordKey
                              FROM      #cdc_ldl_services a2
                              WHERE     a2.event_type = 'medical record' AND
                                        a.MemberID = a2.MemberID
                              ORDER BY  EvalDate DESC,
                                        ISNULL(LDLCResult, 9999)
                             ),
        hybrid_record_key = (SELECT TOP 1
                                    MedicalRecordKey
                             FROM   #cdc_ldl_services a2
                             WHERE  a.MemberID = a2.MemberID AND
                                    a2.data_type <> 'claims'
                             ORDER BY EvalDate DESC,
                                    ISNULL(LDLCResult, 9999)
                            )
INTO    #MedicalRecord_LDL_Control_most_recent
FROM    #cdc_ldl_services a


IF OBJECT_ID('tempdb..#MedicalRecord_LDL_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_LDL_Control

SELECT  a.MemberID,
        ServiceDate,
        LDLCResult
INTO    #MedicalRecord_LDL_Control
FROM    #cdc_ldl_services a
        INNER JOIN #MedicalRecord_LDL_Control_most_recent b ON a.MedicalRecordKey = b.medical_record_key


IF OBJECT_ID('tempdb..#Hybrid_LDL_Control') IS NOT NULL
    DROP TABLE #Hybrid_LDL_Control

SELECT  a.MemberID,
        ServiceDate,
        LDLCResult
INTO    #Hybrid_LDL_Control
FROM    #cdc_ldl_services a
        INNER JOIN #MedicalRecord_LDL_Control_most_recent b ON a.MedicalRecordKey = b.hybrid_record_key


IF OBJECT_ID('tempdb..#cdc_bp_services') IS NOT NULL
    DROP TABLE #cdc_bp_services

SELECT  MedicalRecordKey = 'MR' + CONVERT(varchar(10), MedicalRecordKey),
        MemberID,
        ServiceDate,
        SystolicLevel = SystolicLevel,
        DiastolicLevel = DiastolicLevel,
        event_type = 'medical record'
INTO    #cdc_bp_services
FROM    MedicalRecordCDC_BloodPressure a
        INNER JOIN Pursuit b ON a.PursuitID = b.PursuitID
WHERE   MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd
UNION ALL
SELECT  'AD' + CONVERT(varchar(10), AdministrativeEventID),
        MemberID,
        ServiceDate,
        SystolicLevel = CASE WHEN CPT_IICode IN ('3074F') THEN 129
                             WHEN CPT_IICode IN ('3075F') THEN 129
							 WHEN LOINC IN ('3074F') THEN 129
                             WHEN LOINC IN ('3075F') THEN 129
							 WHEN ProcedureCode IN ('3074F') THEN 129
                             WHEN ProcedureCode IN ('3075F') THEN 129
							 WHEN ProcedureCode IN ('CDC9-N-BP139/89') THEN 139
                             ELSE 9999
                        END,
        DiastolicLevel = CASE WHEN CPT_IICode IN ('3078F') THEN 79
                              WHEN CPT_IICode IN ('3079F') THEN 89
							  WHEN LOINC IN ('3078F') THEN 79
                              WHEN LOINC IN ('3079F') THEN 89
							  WHEN ProcedureCode IN ('3078F') THEN 79
                              WHEN ProcedureCode IN ('3079F') THEN 89
							  WHEN ProcedureCode IN ('CDC9-N-BP139/89') THEN 89
                              ELSE 9999
                         END,
        event_type = 'administrative'
FROM    AdministrativeEvent a
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISSubMetricCode IN ('CDC8', 'CDC9', 'CDC8_old') AND
        MemberID = @MemberID AND
        ServiceDate BETWEEN @MeasureYearStart
                    AND     @MeasureYearEnd




IF OBJECT_ID('tempdb..#MedicalRecord_BP_Reading_most_recent_date') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Reading_most_recent_date

SELECT	DISTINCT
        MemberID,
        medical_record_date = (SELECT TOP 1
                                        ServiceDate
                               FROM     #cdc_bp_services a2
                               WHERE    --a2.event_type = 'medical record' AND
                                        a.MemberID = a2.MemberID
                               ORDER BY ServiceDate DESC
                              ),
        hybrid_record_date = (SELECT TOP 1
                                        ServiceDate
                              FROM      #cdc_bp_services a2
                              WHERE     a.MemberID = a2.MemberID
                              ORDER BY  ServiceDate DESC
                             )
INTO    #MedicalRecord_BP_Reading_most_recent_date
FROM    #cdc_bp_services a

--SELECT * FROM #cdc_bp_services;
--SELECT * FROM #MedicalRecord_BP_Reading_most_recent_date;


IF OBJECT_ID('tempdb..#MedicalRecord_BP_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Control

SELECT	DISTINCT
        MemberID,
        medical_record_date,
        hybrid_record_date,
        MedicalRecord_Systolic = (SELECT TOP 1
                                            CASE WHEN SystolicLevel IS NULL OR
                                                      SystolicLevel = 0
                                                 THEN 9999
                                                 ELSE SystolicLevel
                                            END
                                  FROM      #cdc_bp_services a2
                                  WHERE     a2.event_type = 'medical record' AND
                                            a.MemberID = a2.MemberID AND
                                            a.medical_record_date = a2.ServiceDate
                                  ORDER BY  CASE WHEN SystolicLevel IS NULL OR
                                                      SystolicLevel = 0
                                                 THEN 9999
                                                 ELSE SystolicLevel
                                            END
                                 ),
        MedicalRecord_Diastolic = (SELECT TOP 1
                                            CASE WHEN DiastolicLevel IS NULL OR
                                                      DiastolicLevel = 0
                                                 THEN 9999
                                                 ELSE DiastolicLevel
                                            END
                                   FROM     #cdc_bp_services a2
                                   WHERE    a2.event_type = 'medical record' AND
                                            a.MemberID = a2.MemberID AND
                                            a.medical_record_date = a2.ServiceDate
                                   ORDER BY CASE WHEN DiastolicLevel IS NULL OR
                                                      DiastolicLevel = 0
                                                 THEN 9999
                                                 ELSE DiastolicLevel
                                            END
                                  ),
        Hybrid_Systolic = (SELECT TOP 1
                                    CASE WHEN SystolicLevel IS NULL OR
                                              SystolicLevel = 0 THEN 9999
                                         ELSE SystolicLevel
                                    END
                           FROM     #cdc_bp_services a2
                           WHERE    a.MemberID = a2.MemberID AND
                                    a.hybrid_record_date = a2.ServiceDate
                           ORDER BY CASE WHEN SystolicLevel IS NULL OR
                                              SystolicLevel = 0 THEN 9999
                                         ELSE SystolicLevel
                                    END
                          ),
        Hybrid_Diastolic = (SELECT TOP 1
                                    CASE WHEN DiastolicLevel IS NULL OR
                                              DiastolicLevel = 0 THEN 9999
                                         ELSE DiastolicLevel
                                    END
                            FROM    #cdc_bp_services a2
                            WHERE   a.MemberID = a2.MemberID AND
                                    a.hybrid_record_date = a2.ServiceDate
                            ORDER BY CASE WHEN DiastolicLevel IS NULL OR
                                               DiastolicLevel = 0 THEN 9999
                                          ELSE DiastolicLevel
                                     END
                           )
INTO    #MedicalRecord_BP_Control
FROM    #MedicalRecord_BP_Reading_most_recent_date a


IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL
    DROP TABLE #SubMetricRuleComponents

SELECT  MemberMeasureMetricScoringID,
        CDC_HbA1C_Test_MR_Flag = CASE WHEN (SELECT  COUNT(*)
                                            FROM    MedicalRecordCDC_HbA1c a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            WHERE   b2.MemberID = b.MemberID AND
                                                    ISNULL(a2.HbA1cResult, 0) <> 0 AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        CDC_HbA1C_Test_HYB_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   #cdc_hba1c_services a2
                                             WHERE  a2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END,
        CDC_HbA1C_PoorControl_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                                   FROM     #MedicalRecord_HbA1C_PoorControl a2
                                                   WHERE    a2.MemberID = b.MemberID AND
                                                            HbA1cResult <= 9 AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                  ) > 0 THEN 0
                                             ELSE 1
                                        END,
        CDC_HbA1C_PoorControl_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
															--select *
                                                    FROM    #Hybrid_HbA1C_PoorControl a2
                                                    WHERE   a2.MemberID = b.MemberID AND
                                                            HbA1cResult <= 9 AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                   ) > 0 THEN 0
                                              ELSE 1
                                         END,
        CDC_HbA1C_GoodControl_MR_Flag = CASE WHEN (SELECT   COUNT(*)
                                                   FROM     #MedicalRecord_HbA1C_GoodControl a2
                                                   WHERE    a2.MemberID = b.MemberID AND
                                                            HbA1cResult < @HbA1cGoodcontrolCutoff AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                  ) > 0 THEN 1
                                             ELSE 0
                                        END,
        CDC_HbA1C_GoodControl_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                                    FROM    #Hybrid_HbA1C_GoodControl a2
                                                    WHERE   a2.MemberID = b.MemberID AND
                                                            HbA1cResult < @HbA1cGoodcontrolCutoff AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                   ) > 0 THEN 1
                                              ELSE 0
                                         END,
        CDC_HbA1C_GoodControl_8_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   #MedicalRecord_HbA1C_GoodControl a2
                                                     WHERE  a2.MemberID = b.MemberID AND
                                                            HbA1cResult < @HbA1cGoodcontrol8Cutoff AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
        CDC_HbA1C_GoodControl_8_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                                      FROM    #Hybrid_HbA1C_GoodControl a2
                                                      WHERE   a2.MemberID = b.MemberID AND
                                                              HbA1cResult < @HbA1cGoodcontrol8Cutoff AND
                                                              a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                     ) > 0 THEN 1
                                                ELSE 0
                                           END,
        CDC_EyeExam_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                         FROM   MedicalRecordCDC_EyeExam a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                         WHERE  b2.MemberID = b.MemberID AND 
												--ISNULL(a2.Results, '') <> '' AND // results can be blank for HEDIS 2015
                                                a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   WHEN (SELECT COUNT(*)
                                         FROM   MedicalRecordCDC_EyeExam a2
                                                INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                         WHERE  b2.MemberID = b.MemberID AND
                                                a2.Results = 'Negative Results' AND
                                                a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                        ) > 0 THEN 1
                                   ELSE 0
                              END,
        CDC_EyeExam_HYB_Flag = CASE WHEN (SELECT    COUNT(*)
                                          FROM      MedicalRecordCDC_EyeExam a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                          WHERE     b2.MemberID = b.MemberID AND 
													--ISNULL(a2.Results, '') <> '' AND // results can be blank for HEDIS 2015
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                         ) > 0 THEN 1
                                    WHEN (SELECT    COUNT(*)
                                          FROM      MedicalRecordCDC_EyeExam a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                          WHERE     b2.MemberID = b.MemberID AND
                                                    a2.Results = 'Negative Results' AND
                                                    a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                         ) > 0 THEN 1
                                    WHEN (SELECT    COUNT(*)
                                          FROM      dbo.AdministrativeEvent a
                                                    INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
                                          WHERE     HEDISSubMetricCode = 'CDC4' AND
                                                    MemberID = @MemberID AND
                                                    ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                         ) > 0 THEN 1
                                    ELSE 0
                               END,
        CDC_LDL_Screen_MR_Flag = CASE WHEN (SELECT  COUNT(*)
                                            FROM    #cdc_ldl_services a2
                                            WHERE   a2.MemberID = b.MemberID AND
                                                    a2.event_type = 'medical record' AND
                                                    a2.data_type = 'medical record' AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                           ) > 0 THEN 1
                                      ELSE 0
                                 END,
        CDC_LDL_Screen_HYB_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   #Hybrid_LDL_Control a2
                                             WHERE  a2.MemberID = b.MemberID AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END,
        CDC_LDL_Control_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   #MedicalRecord_LDL_Control a2
                                             WHERE  a2.MemberID = b.MemberID AND
                                                    LDLCResult < 100 AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END,
        CDC_LDL_Control_HYB_Flag = CASE WHEN (SELECT    COUNT(*)
                                              FROM      #Hybrid_LDL_Control a2
                                              WHERE     a2.MemberID = b.MemberID AND
                                                        LDLCResult < 100 AND
                                                        a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                             ) > 0 THEN 1
                                        ELSE 0
                                   END,
        CDC_Nephropathy_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                             FROM   MedicalRecordCDC_Nephropathy a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                             WHERE  b2.MemberID = b.MemberID AND
                                                    ((NumeratorType = 'Evidence of Nephropathy' AND
                                                      NOT (EvidenceType IS NULL OR
                                                           EvidenceType = ''
                                                          ) AND
                                                      (CASE WHEN EvidenceType = 'Positive Urine Macroalbumin test' AND
                                                              NOT (MacroalbuminTestType IS NULL OR
                                                              MacroalbuminTestType = '' OR
                                                              MacroalbuminTestType = 'Trace Results'
                                                              ) THEN 1
                                                            WHEN EvidenceType = 'Positive Urine Macroalbumin test' AND
                                                              (MacroalbuminTestType IS NULL OR
                                                              MacroalbuminTestType = '' OR
                                                              MacroalbuminTestType = 'Trace Results'
                                                              ) THEN 0
                                                            WHEN EvidenceType = 'Negative Urine Macroalbumin test'
                                                            THEN 0
                                                            ELSE 1
                                                       END) = 1
                                                     ) OR
                                                     (NumeratorType = 'Positive urine macroalbumin test' AND
                                                      NOT (MacroalbuminTestType IS NULL OR
                                                           MacroalbuminTestType = ''
                                                          )
                                                     )
                                                    ) AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       WHEN (SELECT COUNT(*)
                                             FROM   MedicalRecordCDC_Nephropathy a2
                                                    INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                             WHERE  b2.MemberID = b.MemberID AND
                                                    NumeratorType = 'Screening Test' AND
                                                    NOT (ScreeningSource IS NULL OR
                                                         ScreeningSource = '' --OR
                                                         --ScreeningResult IS NULL OR
                                                         --ScreeningResult = ''
                                                        ) AND
                                                    a2.ScreeningResultPresent = 1 AND
                                                    a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                            ) > 0 THEN 1
                                       ELSE 0
                                  END,
        CDC_BP_Control130over80_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   #MedicalRecord_BP_Control a2
                                                     WHERE  a2.MemberID = b.MemberID AND
                                                            MedicalRecord_Systolic < 130 AND
                                                            MedicalRecord_Diastolic < 80 AND
                                                            a2.medical_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
        CDC_BP_Control130over80_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                                      FROM    #MedicalRecord_BP_Control a2
                                                      WHERE   a2.MemberID = b.MemberID AND
                                                              Hybrid_Systolic < 130 AND
                                                              Hybrid_Diastolic < 80 AND
                                                              a2.hybrid_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                     ) > 0 THEN 1
                                                ELSE 0
                                           END,
        CDC_BP_Control140over80_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   #MedicalRecord_BP_Control a2
                                                     WHERE  a2.MemberID = b.MemberID AND
                                                            MedicalRecord_Systolic < 140 AND
                                                            MedicalRecord_Diastolic < 80 AND
                                                            a2.medical_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
        CDC_BP_Control140over80_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                                      FROM    #MedicalRecord_BP_Control a2
                                                      WHERE   a2.MemberID = b.MemberID AND
                                                              Hybrid_Systolic < 140 AND
                                                              Hybrid_Diastolic < 80 AND
                                                              a2.hybrid_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                     ) > 0 THEN 1
                                                ELSE 0
                                           END,
        CDC_BP_Control140over90_MR_Flag = CASE WHEN (SELECT COUNT(*)
                                                     FROM   #MedicalRecord_BP_Control a2
                                                     WHERE  a2.MemberID = b.MemberID AND
                                                            MedicalRecord_Systolic < 140 AND
                                                            MedicalRecord_Diastolic < 90 AND
                                                            a2.medical_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                    ) > 0 THEN 1
                                               ELSE 0
                                          END,
        CDC_BP_Control140over90_HYB_Flag = CASE WHEN (SELECT  COUNT(*)
                                                      FROM    #MedicalRecord_BP_Control a2
                                                      WHERE   a2.MemberID = b.MemberID AND
                                                              Hybrid_Systolic < 140 AND
                                                              Hybrid_Diastolic < 90 AND
                                                              a2.hybrid_record_date BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                     ) > 0 THEN 1
                                                ELSE 0
                                           END
INTO    #SubMetricRuleComponents
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   LEFT(HEDISSubMetricCode, 3) = 'CDC' AND
        MemberID = @MemberID


--Evaluate Exclusion(s)...
IF OBJECT_ID('tempdb..#Exclusions') IS NOT NULL
    DROP TABLE #Exclusions

SELECT  MemberMeasureMetricScoringID,
        ExclusionFlag = CASE WHEN (SELECT   COUNT(*)
                                   FROM     dbo.MedicalRecordCDC_Exclusion a2
                                            INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                            INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                            INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                   WHERE    b2.MemberID = b.MemberID AND
                                            a2.ExclusionType IS NOT NULL AND
                                            ((a2.ExclusionType LIKE '%polycystic%' AND
                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                             AND
                                                              @MeasureYearEnd
                                             ) OR
                                             (a2.ExclusionType NOT LIKE '%polycystic%' AND
                                              a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                             AND
                                                              @MeasureYearEnd
                                             )
                                            ) AND
                                            (d2.Gender = 'F' OR
                                             a2.ExclusionType LIKE '%steroid-induced%' OR
                                             a2.ExclusionType LIKE '%steriod-induced%'
                                            )
                                  ) > 0 THEN 1
                             ELSE 0
                        END,
        ExclusionReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                           FROM
                                                              dbo.MedicalRecordCDC_Exclusion a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.ExclusionType IS NOT NULL AND
                                                              ((a2.ExclusionType LIKE '%polycystic%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (a2.ExclusionType NOT LIKE '%polycystic%' AND
                                                              a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                              )
                                                              ) AND
                                                              (d2.Gender = 'F' OR
                                                              a2.ExclusionType LIKE '%steroid-induced%' OR
                                                              a2.ExclusionType LIKE '%steriod-induced%'
                                                              )
                                                          ) > 0
                                                     THEN 'Excluded for ' +
                                                          (SELECT TOP 1
                                                              a2.ExclusionType
                                                           FROM
                                                              dbo.MedicalRecordCDC_Exclusion a2
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                           WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              a2.ExclusionType IS NOT NULL AND
                                                              ((a2.ExclusionType LIKE '%polycystic%' AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (a2.ExclusionType NOT LIKE '%polycystic%' AND
                                                              a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                              )
                                                              ) AND
                                                              (d2.Gender = 'F' OR
                                                              a2.ExclusionType LIKE '%steroid-induced%' OR
                                                              a2.ExclusionType LIKE '%steriod-induced%'
                                                              )
                                                           ORDER BY a2.ServiceDate
                                                          )
                                                END)
INTO    #Exclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   HEDISMeasureInit = 'CDC' AND
        MemberID = @MemberID


--Evaluate Required Exclusion(s)...
IF OBJECT_ID('tempdb..#RequiredExclusions') IS NOT NULL
    DROP TABLE #RequiredExclusions

SELECT  MemberMeasureMetricScoringID,
        ReqExclFlag = CASE WHEN (SELECT COUNT(*)
                                 FROM   dbo.MedicalRecordCDC_HbA1cExclusion a2
                                        INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                        AS x2 ON a2.ExclusionTypeID = x2.ExclusionTypeID
                                        INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                        INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                        INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                        OUTER APPLY (SELECT TOP 1
                                                            a3.*
                                                     FROM   dbo.MedicalRecordCDC_HbA1cExclusion a3
                                                            INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                                            AS x3 ON a3.ExclusionTypeID = x3.ExclusionTypeID
                                                            INNER JOIN Pursuit b3 ON a3.PursuitID = b3.PursuitID
                                                            INNER JOIN PursuitEvent c3 ON a3.PursuitEventID = c3.PursuitEventID
                                                            INNER JOIN Member d3 ON b3.MemberID = d3.MemberID
                                                     WHERE  b3.MemberID = b2.MemberID AND
                                                            a3.ExclusionTypeID = a2.ExclusionTypeID AND
                                                            a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                            a3.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @PriorMeasureYearEnd AND
                                                            (x2.Description <> 'IVD' OR
                                                             (a2.IVDDiagnosisID IS NOT NULL AND
                                                              a2.IVDDiagnosisID > 0
                                                             )
                                                            ) AND
                                                            (x3.Description <> 'IVD' OR
                                                             (a3.IVDDiagnosisID IS NOT NULL AND
                                                              a3.IVDDiagnosisID > 0
                                                             )
                                                            )
                                                    ) t2
                                 WHERE  b2.MemberID = b.MemberID AND
                                        ((x2.Description LIKE '%Age 65%' AND
                                          (a2.ServiceDate <= DATEADD(yy, -65,
                                                              @MeasureYearEnd) OR
                                           d2.DateOfBirth <= DATEADD(yy, -65,
                                                              @MeasureYearEnd)
                                          )
                                         ) OR
                                         (x2.Description IN ('CHF', 'Prior MI',
                                                             'ESRD',
                                                             'CRF/ESRD',
                                                             'Chronic Kidney Disease (Stage 4)',
                                                             'Dementia',
                                                             'Blindness',
                                                             'Amputation (lower extremity)') AND
                                          a2.ServiceDate BETWEEN d2.DateOfBirth
                                                         AND  @MeasureYearEnd
                                         ) OR
                                         (x2.Description IN ('CABG', 'PCI',
                                                             'CABG or PTCA') AND
                                          a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                         AND  @MeasureYearEnd
                                         ) OR
                                         (x2.Description IN ('IVD',
                                                             'Thoracoabdominal or Thoracic Aortic Aneurysm') AND
                                          a2.ServiceDate BETWEEN d2.DateOfBirth
                                                         AND  @MeasureYearEnd /*AND t2.ServiceDate IS NOT NULL*/
                                         )
                                        )
                                ) > 0 THEN 1
                           ELSE 0
                      END,
        ReqExclReason = CONVERT(varchar(200), CASE WHEN (SELECT
                                                              COUNT(*)
                                                         FROM dbo.MedicalRecordCDC_HbA1cExclusion a2
                                                              INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                                              AS x2 ON a2.ExclusionTypeID = x2.ExclusionTypeID
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                              OUTER APPLY (SELECT TOP 1
                                                              a3.*
                                                              FROM
                                                              dbo.MedicalRecordCDC_HbA1cExclusion a3
                                                              INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                                              AS x3 ON a3.ExclusionTypeID = x3.ExclusionTypeID
                                                              INNER JOIN Pursuit b3 ON a3.PursuitID = b3.PursuitID
                                                              INNER JOIN PursuitEvent c3 ON a3.PursuitEventID = c3.PursuitEventID
                                                              INNER JOIN Member d3 ON b3.MemberID = d3.MemberID
                                                              WHERE
                                                              b3.MemberID = b2.MemberID AND
                                                              a3.ExclusionTypeID = a2.ExclusionTypeID AND
                                                              a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                              a3.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @PriorMeasureYearEnd AND
                                                              (x2.Description <> 'IVD' OR
                                                              (a2.IVDDiagnosisID IS NOT NULL AND
                                                              a2.IVDDiagnosisID > 0
                                                              )
                                                              ) AND
                                                              (x3.Description <> 'IVD' OR
                                                              (a3.IVDDiagnosisID IS NOT NULL AND
                                                              a3.IVDDiagnosisID > 0
                                                              )
                                                              )
                                                              ) t2
                                                         WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              ((x2.Description LIKE '%Age 65%' AND
                                                              (a2.ServiceDate <= DATEADD(yy,
                                                              -65,
                                                              @MeasureYearEnd) OR
                                                              d2.DateOfBirth <= DATEADD(yy,
                                                              -65,
                                                              @MeasureYearEnd)
                                                              )
                                                              ) OR
                                                              (x2.Description IN (
                                                              'CHF',
                                                              'Prior MI',
                                                              'ESRD',
                                                              'CRF/ESRD',
                                                              'Chronic Kidney Disease (Stage 4)',
                                                              'Dementia',
                                                              'Blindness',
                                                              'Amputation (lower extremity)') AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (x2.Description IN (
                                                              'CABG', 'PCI',
                                                              'CABG or PTCA') AND
                                                              a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (x2.Description IN (
                                                              'IVD',
                                                              'Thoracoabdominal or Thoracic Aortic Aneurysm') /*AND
                                                              t2.ServiceDate IS NOT NULL*/
                                                              )
                                                              )
                                                        ) > 0
                                                   THEN (SELECT TOP 1
                                                              x2.Description
                                                         FROM dbo.MedicalRecordCDC_HbA1cExclusion a2
                                                              INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                                              AS x2 ON a2.ExclusionTypeID = x2.ExclusionTypeID
                                                              INNER JOIN Pursuit b2 ON a2.PursuitID = b2.PursuitID
                                                              INNER JOIN PursuitEvent c2 ON a2.PursuitEventID = c2.PursuitEventID
                                                              INNER JOIN Member d2 ON b2.MemberID = d2.MemberID
                                                              OUTER APPLY (SELECT TOP 1
                                                              a3.*
                                                              FROM
                                                              dbo.MedicalRecordCDC_HbA1cExclusion a3
                                                              INNER JOIN dbo.DropDownValues_CDCHbA1cExclusionType
                                                              AS x3 ON a3.ExclusionTypeID = x3.ExclusionTypeID
                                                              INNER JOIN Pursuit b3 ON a3.PursuitID = b3.PursuitID
                                                              INNER JOIN PursuitEvent c3 ON a3.PursuitEventID = c3.PursuitEventID
                                                              INNER JOIN Member d3 ON b3.MemberID = d3.MemberID
                                                              WHERE
                                                              b3.MemberID = b2.MemberID AND
                                                              a3.ExclusionTypeID = a2.ExclusionTypeID AND
                                                              a2.ServiceDate BETWEEN @MeasureYearStart
                                                              AND
                                                              @MeasureYearEnd AND
                                                              a3.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @PriorMeasureYearEnd AND
                                                              (x2.Description <> 'IVD' OR
                                                              (a2.IVDDiagnosisID IS NOT NULL AND
                                                              a2.IVDDiagnosisID > 0
                                                              )
                                                              ) AND
                                                              (x3.Description <> 'IVD' OR
                                                              (a3.IVDDiagnosisID IS NOT NULL AND
                                                              a3.IVDDiagnosisID > 0
                                                              )
                                                              )
                                                              ) t2
                                                         WHERE
                                                              b2.MemberID = b.MemberID AND
                                                              ((x2.Description LIKE '%Age 65%' AND
                                                              (a2.ServiceDate <= DATEADD(yy,
                                                              -65,
                                                              @MeasureYearEnd) OR
                                                              d2.DateOfBirth <= DATEADD(yy,
                                                              -65,
                                                              @MeasureYearEnd)
                                                              )
                                                              ) OR
                                                              (x2.Description IN (
                                                              'CHF',
                                                              'Prior MI',
                                                              'ESRD',
                                                              'CRF/ESRD',
                                                              'Chronic Kidney Disease (Stage 4)',
                                                              'Dementia',
                                                              'Blindness',
                                                              'Amputation (lower extremity)') AND
                                                              a2.ServiceDate BETWEEN d2.DateOfBirth
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (x2.Description IN (
                                                              'CABG', 'PCI',
                                                              'CABG or PTCA') AND
                                                              a2.ServiceDate BETWEEN @PriorMeasureYearStart
                                                              AND
                                                              @MeasureYearEnd
                                                              ) OR
                                                              (x2.Description IN (
                                                              'IVD',
                                                              'Thoracoabdominal or Thoracic Aortic Aneurysm') /*AND
                                                              t2.ServiceDate IS NOT NULL*/
                                                              )
                                                              )
                                                         ORDER BY a2.ServiceDate
                                                        )
                                              END)
INTO    #RequiredExclusions
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric c ON a.HEDISSubMetricID = c.HEDISSubMetricID
WHERE   c.HEDISSubMetricCode = 'CDC3' AND
        MemberID = @MemberID

--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--******************************************************************************************
--Calculation of Hit Rules and Application to Scoring Table:

--Exclusions
UPDATE  MemberMeasureMetricScoring
SET     ExclusionCount = CASE WHEN c.ExclusionFlag > 0 THEN 1
                              ELSE 0
                         END,
        ExclusionReason = c.ExclusionReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #Exclusions c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID;
	
	
--Required Exclusions
UPDATE  MemberMeasureMetricScoring
SET     ReqExclCount = CASE WHEN c.ReqExclFlag > 0 THEN 1
                            ELSE 0
                       END,
        ReqExclReason = c.ReqExclReason
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN dbo.HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
        INNER JOIN #RequiredExclusions c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
WHERE   HEDISSubMetricCode = 'CDC3';		

--Comprehensive Diabetes Care -  HbA1C Test
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_HbA1C_Test_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_HbA1C_Test_HYB_Flag = 1 OR
                                   a.AdministrativeHitCount >= 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC1'


--Comprehensive Diabetes Care - Poor HbA1C Control > 9.0
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_HbA1C_PoorControl_MR_Flag = 1
                                     THEN 0
                                     ELSE 1
                                END,
        HybridHitCount = CASE WHEN CDC_HbA1C_PoorControl_HYB_Flag = 1 THEN 0
                              ELSE 1
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC2'


--Comprehensive Diabetes Care - Good HbA1C Control < 7.0
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_HbA1C_GoodControl_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_HbA1C_GoodControl_HYB_Flag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC3'


--Comprehensive Diabetes Care - Good HbA1C Control < 8.0
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_HbA1C_GoodControl_8_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_HbA1C_GoodControl_8_HYB_Flag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC10'


--Comprehensive Diabetes Care - Eye Exams
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_EyeExam_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = (CASE WHEN AdministrativeHitCount = 1 THEN 1
                               WHEN CDC_EyeExam_HYB_Flag = 1 THEN 1
                               ELSE 0
                          END)
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC4'


--Comprehensive Diabetes Care - LDL Screening
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_LDL_Screen_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_LDL_Screen_HYB_Flag = 1 THEN 1
                              WHEN a.AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC5'


--Comprehensive Diabetes Care - LDL Level < 100
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_LDL_Control_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_LDL_Control_HYB_Flag = 1 THEN 1
                              WHEN a.AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC6'


--Comprehensive Diabetes Care - Nephropathy
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_Nephropathy_MR_Flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_Nephropathy_MR_Flag = 1 THEN 1
                              WHEN a.AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC7'


--Comprehensive Diabetes Care - Blood Pressure Control < 130/80
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_BP_Control130over80_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_BP_Control130over80_MR_Flag = 1 THEN 1
                              WHEN a.AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC8_old'


--Comprehensive Diabetes Care - Blood Pressure Control < 140/80
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_BP_Control140over80_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_BP_Control140over80_HYB_Flag = 1 THEN 1
								WHEN AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC8'


--Comprehensive Diabetes Care - Blood Pressure Control < 140/90
UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN CDC_BP_Control140over90_MR_Flag = 1
                                     THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN CDC_BP_Control140over90_HYB_Flag = 1 THEN 1
								WHEN AdministrativeHitCount = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #SubMetricRuleComponents c ON a.MemberMeasureMetricScoringID = c.MemberMeasureMetricScoringID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID
WHERE   HEDISSubMetricCode = 'CDC9'


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'CDC', @MemberID = @MemberID;


--**********************************************************************************************
--**********************************************************************************************
--temp table cleanup
--**********************************************************************************************
--**********************************************************************************************


IF OBJECT_ID('tempdb..#cdc_hba1c_services') IS NOT NULL
    DROP TABLE #cdc_hba1c_services

IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_PoorControl_most_recent') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_PoorControl_most_recent

IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_PoorControl') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_PoorControl

IF OBJECT_ID('tempdb..#Hybrid_HbA1C_PoorControl') IS NOT NULL
    DROP TABLE #Hybrid_HbA1C_PoorControl

IF OBJECT_ID('tempdb..#MedicalRecord_HbA1C_GoodControl') IS NOT NULL
    DROP TABLE #MedicalRecord_HbA1C_GoodControl

IF OBJECT_ID('tempdb..#Hybrid_HbA1C_GoodControl') IS NOT NULL
    DROP TABLE #Hybrid_HbA1C_GoodControl

IF OBJECT_ID('tempdb..#cdc_ldl_services') IS NOT NULL
    DROP TABLE #cdc_ldl_services

IF OBJECT_ID('tempdb..#MedicalRecord_LDL_Control_most_recent') IS NOT NULL
    DROP TABLE #MedicalRecord_LDL_Control_most_recent

IF OBJECT_ID('tempdb..#MedicalRecord_LDL_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_LDL_Control

IF OBJECT_ID('tempdb..#Hybrid_LDL_Control') IS NOT NULL
    DROP TABLE #Hybrid_LDL_Control

IF OBJECT_ID('tempdb..#cdc_bp_services') IS NOT NULL
    DROP TABLE #cdc_bp_services

IF OBJECT_ID('tempdb..#MedicalRecord_BP_Reading_most_recent_date') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Reading_most_recent_date

IF OBJECT_ID('tempdb..#MedicalRecord_BP_Control') IS NOT NULL
    DROP TABLE #MedicalRecord_BP_Control

IF OBJECT_ID('tempdb..#SubMetricRuleComponents') IS NOT NULL
    DROP TABLE #SubMetricRuleComponents

GO
GRANT EXECUTE ON  [dbo].[ScoreCDC] TO [Support]
GO
