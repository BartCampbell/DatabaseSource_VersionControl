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

--It uses Medical Record data from the MedicalRecordW15 table.

--**************************************************************************************
--**************************************************************************************
--**************************************************************************************
--sample execution:
--exec ScoreW15 '78569951'

CREATE PROCEDURE [dbo].[ScoreW15] @MemberID int
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

IF OBJECT_ID('tempdb..#W15_visits') IS NOT NULL 
    DROP TABLE #W15_visits

DECLARE @W15Visits TABLE
(
	RecordType varchar(20) NOT NULL,
	MemberID int NOT NULL,
	ProviderID int NOT NULL,
	ServiceDate datetime NOT NULL,
	MeasureID int NOT NULL,
	HlthHistoryFlag int NOT NULL,
	PhysHealthDevFlag int NOT NULL,
	MentalHlthDevFlag int NOT NULL,
	PhysExamFlag int NOT NULL,
	HlthEducFlag int NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	PRIMARY KEY CLUSTERED (RecordType, MemberID, ProviderID, ServiceDate)
);

INSERT INTO @W15Visits SELECT * FROM dbo.GetW15WellVisits(@MemberID);


IF OBJECT_ID('tempdb..#results') IS NOT NULL 
    DROP TABLE #results

SELECT  elig.MemberID,
        MemberMeasureSampleID,
        W15_0_visits = CASE WHEN ISNULL((SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ), 0) = 0 THEN 1
                       END,
        W15_1_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) = 1 THEN 1
                       END,
        W15_2_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) = 2 THEN 1
                       END,
        W15_3_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) = 3 THEN 1
                       END,
        W15_4_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) = 4 THEN 1
                       END,
        W15_5_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) = 5 THEN 1
                       END,
        W15_6_visits = CASE WHEN (SELECT    COUNT(*)
                                  FROM      @W15Visits b
                                  WHERE     elig.MemberID = b.MemberID AND
											b.RecordType IN ('A','Admin', 'Administrative')
                                 ) >= 6 THEN 1
                       END,
        W15_0_visits_mr_flag = CASE WHEN ISNULL((SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ), 0) = 0 THEN 1
                                    ELSE 0
                               END,
        W15_1_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) = 1 THEN 1
                                    ELSE 0
                               END,
        W15_2_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) = 2 THEN 1
                                    ELSE 0
                               END,
        W15_3_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) = 3 THEN 1
                                    ELSE 0
                               END,
        W15_4_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) = 4 THEN 1
                                    ELSE 0
                               END,
        W15_5_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) = 5 THEN 1
                                    ELSE 0
                               END,
        W15_6_visits_mr_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID AND
													b.RecordType IN ('MR','MedRcd', 'Med Rcd', 'Medical Record')
                                         ) >= 6 THEN 1
                                    ELSE 0
                               END,
        W15_0_visits_hyb_flag = CASE WHEN ISNULL((SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID), 0) = 0 THEN 1
                                     ELSE 0
                                END,
        W15_1_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) = 1 THEN 1
                                     ELSE 0
                                END,
        W15_2_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) = 2 THEN 1
                                     ELSE 0
                                END,
        W15_3_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) = 3 THEN 1
                                     ELSE 0
                                END,
        W15_4_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) = 4 THEN 1
                                     ELSE 0
                                END,
        W15_5_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) = 5 THEN 1
                                     ELSE 0
                                END,
        W15_6_visits_hyb_flag = CASE WHEN (SELECT    CASE 
														WHEN SUM(b.PhysHealthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.PhysHealthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.MentalHlthDevFlag) AND
															SUM(b.PhysHealthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.PhysHealthDevFlag) 
														WHEN SUM(b.MentalHlthDevFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.MentalHlthDevFlag) <= SUM(b.PhysExamFlag) AND
															SUM(b.MentalHlthDevFlag) <= SUM(b.HlthHistoryFlag)
														THEN SUM(b.MentalHlthDevFlag) 
														WHEN SUM(b.HlthHistoryFlag) <= SUM(b.HlthEducFlag) AND 
															SUM(b.HlthHistoryFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthHistoryFlag) 
														WHEN SUM(b.HlthEducFlag) <= SUM(b.PhysExamFlag)
														THEN SUM(b.HlthEducFlag)
														ELSE SUM(b.PhysExamFlag)
														END
										  FROM      @W15Visits b
										  WHERE     elig.MemberID = b.MemberID) >= 6 THEN 1
                                     ELSE 0
                                END
INTO    #results
FROM    MemberMeasureSample elig
        INNER JOIN Measure b ON elig.MeasureID = b.MeasureID
WHERE   HEDISMeasure = 'W15' AND
        elig.MemberID = @MemberID


--Calculation of Hit Rules and Application to Scoring Table

UPDATE  MemberMeasureMetricScoring
SET     MedicalRecordHitCount = CASE WHEN HEDISSubMetricCode = 'W150' AND
                                          W15_0_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W151' AND
                                          W15_1_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W152' AND
                                          W15_2_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W153' AND
                                          W15_3_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W154' AND
                                          W15_4_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W155' AND
                                          W15_5_visits_mr_flag = 1 THEN 1
                                     WHEN HEDISSubMetricCode = 'W156' AND
                                          W15_6_visits_mr_flag = 1 THEN 1
                                     ELSE 0
                                END,
        HybridHitCount = CASE WHEN HEDISSubMetricCode = 'W150' AND
                                   W15_0_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W151' AND
                                   W15_1_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W152' AND
                                   W15_2_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W153' AND
                                   W15_3_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W154' AND
                                   W15_4_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W155' AND
                                   W15_5_visits_hyb_flag = 1 THEN 1
                              WHEN HEDISSubMetricCode = 'W156' AND
                                   W15_6_visits_hyb_flag = 1 THEN 1
                              ELSE 0
                         END
FROM    MemberMeasureMetricScoring a
        INNER JOIN MemberMeasureSample b ON a.MemberMeasureSampleID = b.MemberMeasureSampleID
        INNER JOIN #results c ON a.MemberMeasureSampleID = c.MemberMeasureSampleID
        INNER JOIN HEDISSubMetric d ON a.HEDISSubMetricID = d.HEDISSubMetricID


EXEC dbo.RunPostScoringSteps @HedisMeasure = 'W15', @MemberID = @MemberID;


GO
GRANT EXECUTE ON  [dbo].[ScoreW15] TO [Support]
GO
