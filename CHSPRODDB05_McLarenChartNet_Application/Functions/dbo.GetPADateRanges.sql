SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetPADateRanges] (@MemberID int = NULL)
RETURNS @Results table
(
 [MemberMeasureSampleID] [int] NOT NULL,
 [MemberID] [int] NOT NULL,
 [MeasureID] [int] NOT NULL,
 [EventDate] datetime NOT NULL,
 [DeliveryDate] [datetime] NULL,
 [PrenatalCareScore] [varchar](32) NULL,
 [PrenatalCareStartDateScore] [datetime] NULL,
 [PrenatalCareEndDateScore] [datetime] NULL,
 [PrenatalCare1] [varchar](32) NULL,
 [PrenatalCareStartDate1] [datetime] NULL,
 [PrenatalCareEndDate1] [datetime] NULL,
 [PrenatalCare2] [varchar](32) NULL,
 [PrenatalCareStartDate2] [datetime] NULL,
 [PrenatalCareEndDate2] [datetime] NULL,
 [PrenatalCare3] [varchar](32) NULL,
 [PrenatalCareStartDate3] [datetime] NULL,
 [PrenatalCareEndDate3] [datetime] NULL,
 [PostpartumCareScore] [varchar](32) NULL,
 [PostpartumCareStartDateScore] [datetime] NULL,
 [PostpartumCareEndDateScore] [datetime] NULL,
 [PostpartumCare1] [varchar](32) NULL,
 [PostpartumCareStartDate1] [datetime] NULL,
 [PostpartumCareEndDate1] [datetime] NULL,
 [PostpartumCare2] [varchar](32) NULL,
 [PostpartumCareStartDate2] [datetime] NULL,
 [PostpartumCareEndDate2] [datetime] NULL,
 [DiffDays] [int] NULL,
 [EddDiffDays] [int] NULL,
 [AdminDeliveryDate] [datetime] NULL,
 [MRDeliveryDate] [datetime] NULL,
 [MREstimatedDate] [datetime] NULL,
 [LastEnrollSegStartDate] [datetime] NULL,
 [AdminPriorToDays] [smallint] NULL,
 [MRPriorToDays] [smallint] NULL,
 [MREddPriorToDays] [smallint] NULL,
 [AllowConcurrentScoringRanges] [bit] NULL,
 [AllowConcurrentScoringRangesPostpartum] [bit] NULL,
 DODSourceMeasureID int NULL,
 EDDSourceMeasureID int NULL,
 FirstTwoPrenatalStartDate datetime NULL,
 FirstTwoPrenatalEndDate datetime NULL,
 FirstTwoPrenatalStartSourceMeasureID int NULL,
 FirstTwoPrenatalEndSourceMeasureID int NULL,
 FirstTwoPrenatalStartSourceHasMultiMeasures bit NULL,
 FirstTwoPrenatalEndSourceHasMultiMeasures bit NULL,
 FirstTwoEnrolledPrenatalStartDate datetime NULL,
 FirstTwoEnrolledPrenatalEndDate datetime NULL,
 FirstTwoEnrolledPrenatalStartSourceMeasureID int NULL,
 FirstTwoEnrolledPrenatalEndSourceMeasureID int NULL,
 FirstTwoEnrolledPrenatalStartSourceHasMultiMeasures bit NULL,
 FirstTwoEnrolledPrenatalEndSourceHasMultiMeasures bit NULL,
 HasPrenatalVisit bit NOT NULL,
 HasPostpartumVisit bit NOT NULL,
 IsPPC1Denominator bit NOT NULL,
 IsPPC1Numerator bit NOT NULL,
 IsPPC2Denominator bit NOT NULL,
 IsPPC2Numerator bit NOT NULL
)
AS
BEGIN
    DECLARE @PPCAllowConcurrentScoringRanges bit;
    DECLARE @PPCAllowConcurrentScoringRangesPostpartum bit;
    SET @PPCAllowConcurrentScoringRanges = dbo.GetPPCAllowConcurrentScoringRanges();
    SET @PPCAllowConcurrentScoringRangesPostpartum = dbo.GetPPCAllowConcurrentScoringRangesPostpartum();

    DECLARE @PPCDeliveryDateMatchingWindow int;
    SET @PPCDeliveryDateMatchingWindow = ISNULL(ABS(dbo.GetPPCDeliveryDateMatchingWindow()),
                                                180);

    DECLARE @Measures table
(
 MeasureID int NOT NULL,
 PRIMARY KEY CLUSTERED (MeasureID)
);
	
    INSERT  INTO @Measures
            SELECT  MeasureID
            FROM    dbo.Measure
            WHERE   HEDISMeasure IN ('PDS', 'PSS', 'MRFA');

    WITH    DeliveryDates
              AS (SELECT    t.ServiceDate AS DeliveryDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate,
                            t.LastChangedDate
                  FROM      dbo.MedicalRecordPADOD AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                  WHERE     (t.NumeratorType IN ('Delivery Date', 'Delivery',
                                                 'DeliveryDate'))
                 ),
            EstimatedDeliveryDates
              AS (SELECT    t.ServiceDate AS DeliveryDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate,
                            t.LastChangedDate
                  FROM      dbo.MedicalRecordPADOD AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                  WHERE     (t.NumeratorType IN ('Chart EDD', 'EDD',
                                                 'ChartEDD'))
                 ),
            PrenatalVisitDatesBase
              AS (SELECT DISTINCT
                            t.ServiceDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate
                  FROM      dbo.MedicalRecordMRFAScreening AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                  UNION
                  SELECT DISTINCT
                            t.ServiceDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate
                  FROM      dbo.MedicalRecordPDSPrenatal AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                  UNION
                  SELECT DISTINCT
                            t.ServiceDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate
                  FROM      dbo.MedicalRecordPSSScreening AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                 ),
			PostpartumVisitDatesBase
              AS (SELECT DISTINCT
                            t.ServiceDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate
                  FROM      dbo.MedicalRecordPDSPostpartum AS t
                            INNER JOIN dbo.Pursuit AS R ON t.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON t.PursuitEventID = RV.PursuitEventID
                 ),
            DeliveryMatching
              AS (SELECT    MMS.*,
                            t1.MeasureID AS DODSourceMeasureID,
                            t2.MeasureID AS EDDSourceMeasureID,
                            DATEDIFF(dd,
                                     ISNULL(MMS.PPCDeliveryDate, MMS.EventDate),
                                     t1.DeliveryDate) AS DiffDays,
                            DATEDIFF(dd,
                                     ISNULL(MMS.PPCDeliveryDate, MMS.EventDate),
                                     t2.DeliveryDate) AS EddDiffDays,
                            t1.DeliveryDate AS MRDeliveryDate,
                            t2.DeliveryDate AS MREstimatedDate,
                            CASE WHEN MMS.PPCEnrollmentCategoryID = 1 AND
                                      DATEDIFF(dd,
                                               ISNULL(MMS.PPCLastEnrollSegStartDate,
                                                      MMS.PPCPrenatalCareStartDate),
                                               ISNULL(MMS.PPCDeliveryDate,
                                                      MMS.EventDate)) < 280
                                 THEN NULL
                                 ELSE ISNULL(MMS.PPCLastEnrollSegStartDate,
                                             MMS.PPCPrenatalCareStartDate)
                            END AS LastEnrollSegStartDate
                  FROM      dbo.MemberMeasureSample AS MMS
                            OUTER APPLY (SELECT TOP 1
                                                t.*
                                         FROM   DeliveryDates AS t
                                         WHERE  --t.MeasureID = MMS.MeasureID AND
                                                t.MemberID = MMS.MemberID AND
                                                t.EventDate = MMS.EventDate AND
                                                t.DeliveryDate BETWEEN DATEADD(dd,
                                                              (@PPCDeliveryDateMatchingWindow *
                                                              -1),
                                                              ISNULL(MMS.PPCDeliveryDate,
                                                              MMS.EventDate))
                                                              AND
                                                              DATEADD(dd,
                                                              @PPCDeliveryDateMatchingWindow,
                                                              ISNULL(MMS.PPCDeliveryDate,
                                                              MMS.EventDate)) AND
                                                t.MeasureID IN (SELECT
                                                              MeasureID
                                                              FROM
                                                              @Measures)
                                         ORDER BY t.LastChangedDate DESC
                                        ) AS t1
                            OUTER APPLY (SELECT TOP 1
                                                t.*
                                         FROM   EstimatedDeliveryDates AS t
                                         WHERE  --t.MeasureID = MMS.MeasureID AND
                                                t.MemberID = MMS.MemberID AND
                                                t.EventDate = MMS.EventDate AND
                                                t.DeliveryDate BETWEEN DATEADD(dd,
                                                              (@PPCDeliveryDateMatchingWindow *
                                                              -1),
                                                              ISNULL(MMS.PPCDeliveryDate,
                                                              MMS.EventDate))
                                                              AND
                                                              DATEADD(dd,
                                                              @PPCDeliveryDateMatchingWindow,
                                                              ISNULL(MMS.PPCDeliveryDate,
                                                              MMS.EventDate)) AND
                                                t.MeasureID IN (SELECT
                                                              MeasureID
                                                              FROM
                                                              @Measures)
                                         ORDER BY t.LastChangedDate DESC
                                        ) AS t2
                 ),
            DatesBase
              AS (SELECT    *,
                            DATEDIFF(dd,
                                     ISNULL(LastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     ISNULL(PPCDeliveryDate, EventDate)) AS AdminPriorToDays,
                            DATEDIFF(dd,
                                     ISNULL(PPCLastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     MRDeliveryDate) AS MRPriorToDays,
                            DATEDIFF(dd,
                                     ISNULL(PPCLastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     MREstimatedDate) AS MREddPriorToDays
                  FROM      DeliveryMatching
                 ),
            Dates
              AS (SELECT    *,
                            CASE WHEN AdminPriorToDays >= 280 OR
                                      LastEnrollSegStartDate IS NULL THEN 1
                                 WHEN AdminPriorToDays BETWEEN 219 AND 279
                                 THEN 2
                                 WHEN AdminPriorToDays BETWEEN 42 AND 218
                                 THEN 3
                            END AS CalcAdminEnrollmentCategoryID,
                            CASE WHEN MRPriorToDays >= 280 OR
                                      LastEnrollSegStartDate IS NULL THEN 1
                                 WHEN MRPriorToDays BETWEEN 219 AND 279 THEN 2
                                 WHEN MRPriorToDays BETWEEN 42 AND 218 THEN 3
                            END AS CalcMREnrollmentCategoryID,
                            CASE WHEN MREddPriorToDays >= 280 OR
                                      LastEnrollSegStartDate IS NULL THEN 1
                                 WHEN MREddPriorToDays BETWEEN 219 AND 279
                                 THEN 2
                                 WHEN MREddPriorToDays BETWEEN 42 AND 218
                                 THEN 3
                            END AS CalcMREddEnrollmentCategoryID
                  FROM      DatesBase
                 ),
            ResultsBase
              AS (SELECT    *,
                            CASE CalcAdminEnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -280, PPCDeliveryDate)
                              WHEN 2 THEN LastEnrollSegStartDate
                              WHEN 3 THEN LastEnrollSegStartDate
                            END AS AdminPrenatalStartDate,
                            CASE CalcAdminEnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -176, PPCDeliveryDate)
                              WHEN 2 THEN DATEADD(dd, -176, PPCDeliveryDate)
                              WHEN 3
                              THEN DATEADD(dd, 42, LastEnrollSegStartDate)
                            END AS AdminPrenatalEndDate,
                            CASE CalcMREnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -280, MRDeliveryDate)
                              WHEN 2 THEN LastEnrollSegStartDate
                              WHEN 3 THEN LastEnrollSegStartDate
                            END AS MRPrenatalStartDate,
                            CASE CalcMREnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -176, MRDeliveryDate)
                              WHEN 2 THEN DATEADD(dd, -176, MRDeliveryDate)
                              WHEN 3
                              THEN DATEADD(dd, 42, LastEnrollSegStartDate)
                            END AS MRPrenatalEndDate,
                            CASE CalcMREddEnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -280, MREstimatedDate)
                              WHEN 2 THEN LastEnrollSegStartDate
                              WHEN 3 THEN LastEnrollSegStartDate
                            END AS MREddPrenatalStartDate,
                            CASE CalcMREddEnrollmentCategoryID
                              WHEN 1 THEN DATEADD(dd, -176, MREstimatedDate)
                              WHEN 2 THEN DATEADD(dd, -176, MREstimatedDate)
                              WHEN 3
                              THEN DATEADD(dd, 42, LastEnrollSegStartDate)
                            END AS MREddPrenatalEndDate
                  FROM      Dates
                 ),
            Results
              AS (SELECT    t.MemberMeasureSampleID,
                            t.MemberID,
                            t.MeasureID,
                            t.EventDate,
                            ISNULL(t.MRDeliveryDate, t.PPCDeliveryDate) AS DeliveryDate,
				---------------------------------------------------------------------------------------------------------
                            CONVERT(varchar(32), CASE WHEN t.MREddPrenatalStartDate IS NOT NULL
                                                      THEN 'Chart EDD-based'
                                                      WHEN t.MRPrenatalStartDate IS NOT NULL
                                                      THEN 'Chart DOD-based'
                                                      ELSE 'Admin EDD-based'
                                                 END) AS PrenatalCareScore,
                            COALESCE(t.MREddPrenatalStartDate,
                                     t.MRPrenatalStartDate,
                                     t.AdminPrenatalStartDate) AS PrenatalCareStartDateScore, --Scoring Start
                            COALESCE(t.MREddPrenatalEndDate,
                                     t.MRPrenatalEndDate,
                                     t.AdminPrenatalEndDate) AS PrenatalCareEndDateScore, --Scoring End
                            CONVERT(varchar(32), 'Admin EDD-based') AS PrenatalCare1,
                            t.AdminPrenatalStartDate AS PrenatalCareStartDate1, --Admin EDD-based Start
                            t.AdminPrenatalEndDate AS PrenatalCareEndDate1, --Admin EDD-based End
                            CONVERT(varchar(32), 'Chart DOD-based') AS PrenatalCare2,
                            t.MRPrenatalStartDate AS PrenatalCareStartDate2, --Chart DOD-based Start
                            t.MRPrenatalEndDate AS PrenatalCareEndDate2, --Chart DOD-based End
                            CONVERT(varchar(32), 'Chart EDD-based') AS PrenatalCare3,
                            t.MREddPrenatalStartDate AS PrenatalCareStartDate3, --Chart EDD-based Start
                            t.MREddPrenatalEndDate AS PrenatalCareEndDate3, --Chart EDD-based End
				---------------------------------------------------------------------------------------------------------
                            CONVERT(varchar(32), CASE WHEN t.DiffDays IS NOT NULL
                                                      THEN 'Chart DOD-based'
                                                      ELSE 'Admin EDD-based'
                                                 END) AS PostpartumCareScore,
                            DATEADD(dd, 1,
                                    COALESCE(t.MRDeliveryDate,
                                             t.PPCDeliveryDate, t.EventDate)) AS PostpartumCareStartDateScore, --Scoring Start
                            DATEADD(dd, 56,
                                    COALESCE(t.MRDeliveryDate,
                                             t.PPCDeliveryDate, t.EventDate)) AS PostpartumCareEndDateScore, --Scoring End
                            CONVERT(varchar(32), 'Admin EDD-based') AS PostpartumCare1,
                            DATEADD(dd, 1, ISNULL(t.PPCDeliveryDate, t.EventDate)) AS PostpartumCareStartDate1, --Admin EDD-based Start
                            DATEADD(dd, 56, ISNULL(t.PPCDeliveryDate, t.EventDate)) AS PostpartumCareEndDate1, --Admin EDD-based End
                            CONVERT(varchar(32), 'Chart DOD-based') AS PostpartumCare2,
                            DATEADD(dd, 1, t.MRDeliveryDate) AS PostpartumCareStartDate2, --Chart DOD-based Start
                            DATEADD(dd, 56, t.MRDeliveryDate) AS PostpartumCareEndDate2, --Chart DOD-based End
                            t.DiffDays,
                            t.EddDiffDays,
                            ISNULL(t.PPCDeliveryDate, t.EventDate) AS AdminDeliveryDate,
                            t.MRDeliveryDate,
                            t.MREstimatedDate,
                            t.LastEnrollSegStartDate,
                            t.AdminPriorToDays,
                            t.MRPriorToDays,
                            t.MREddPriorToDays,
                            @PPCAllowConcurrentScoringRanges AS AllowConcurrentScoringRanges,
                            @PPCAllowConcurrentScoringRangesPostpartum AS AllowConcurrentScoringRangesPostpartum,
                            t.DODSourceMeasureID,
                            t.EDDSourceMeasureID,
                            COALESCE(t.MREstimatedDate, t.MRDeliveryDate,
                                     t.PPCDeliveryDate, t.EventDate) AS DeliveryDateScore,
                            DATEADD(dd, -280-60,
                                    COALESCE(t.MREstimatedDate,
                                             t.MRDeliveryDate,
                                             t.PPCDeliveryDate, t.EventDate)) PrenatalVisitsStartDateScore,
                            DATEADD(dd, -1,
                                    COALESCE(t.MREstimatedDate,
                                             t.MRDeliveryDate,
                                             t.PPCDeliveryDate, t.EventDate)) PrenatalVisitsEndDateScore,
                            DATEADD(dd, -280-60,
                                    ISNULL(t.PPCDeliveryDate, t.EventDate)) PrenatalVisitsStartDate1,
                            DATEADD(dd, -1,
                                    ISNULL(t.PPCDeliveryDate, t.EventDate)) PrenatalVisitsEndDate1,
                            DATEADD(dd, -280-60, t.MRDeliveryDate) PrenatalVisitsStartDate2,
                            DATEADD(dd, -1, t.MRDeliveryDate) PrenatalVisitsEndDate2,
                            DATEADD(dd, -280-60, t.MREstimatedDate) PrenatalVisitsStartDate3,
                            DATEADD(dd, -1, t.MREstimatedDate) PrenatalVisitsEndDate3
                  FROM      ResultsBase AS t
                  WHERE     (t.MeasureID IN (SELECT MeasureID
                                             FROM   @Measures)) AND
                            ((@MemberID IS NULL) OR
                             (t.MemberID = @MemberID)
                            )
                 ),
            PrenatalVisitDates
              AS (SELECT    t.ServiceDate,
                            t.MemberID,
                            t.EventDate,
                            CASE WHEN COUNT(DISTINCT t.MeasureID) > 1 THEN 1
                                 ELSE 0
                            END AS HasMultipleMeasures,
                            MIN(t.MeasureID) AS MeasureID,
                            ROW_NUMBER() OVER (PARTITION BY CASE
                                                              WHEN t.ServiceDate >= MIN(MMS.LastEnrollSegStartDate)
                                                              THEN 1
                                                              ELSE 0
                                                            END, t.MemberID,
                                               t.EventDate ORDER BY t.ServiceDate) AS EnrolledSortOrder,
                            ROW_NUMBER() OVER (PARTITION BY t.MemberID,
                                               t.EventDate ORDER BY t.ServiceDate) AS SortOrder,
                            CASE WHEN t.ServiceDate >= MIN(MMS.LastEnrollSegStartDate)
                                 THEN 1
                                 ELSE 0
                            END AS IsEnrolled
                  FROM      PrenatalVisitDatesBase AS t
                            CROSS APPLY (SELECT *
                                         FROM   Results AS r
                                         WHERE  r.MemberID = t.MemberID AND
                                                r.EventDate = t.EventDate AND
                                                r.MeasureID = t.MeasureID
                                        ) AS MMS
                  WHERE     (MMS.AllowConcurrentScoringRanges = 1 AND
                             (t.ServiceDate BETWEEN MMS.PrenatalVisitsStartDate1
                                            AND     MMS.PrenatalVisitsEndDate1 OR
                              t.ServiceDate BETWEEN MMS.PrenatalVisitsStartDate2
                                            AND     MMS.PrenatalVisitsEndDate2 OR
                              t.ServiceDate BETWEEN MMS.PrenatalVisitsStartDate3
                                            AND     MMS.PrenatalVisitsEndDate3
                             )
                            ) OR
                            (MMS.AllowConcurrentScoringRanges = 0 AND
                             t.ServiceDate BETWEEN MMS.PrenatalVisitsStartDateScore
                                           AND     MMS.PrenatalVisitsEndDateScore
                            )
                  GROUP BY  t.ServiceDate,
                            t.MemberID,
                            t.EventDate
                 ),
			PostpartumVisitDates
              AS (SELECT    t.ServiceDate,
                            t.MemberID,
                            t.EventDate,
                            CASE WHEN COUNT(DISTINCT t.MeasureID) > 1 THEN 1
                                 ELSE 0
                            END AS HasMultipleMeasures,
                            MIN(t.MeasureID) AS MeasureID,
                            ROW_NUMBER() OVER (PARTITION BY t.MemberID, t.EventDate ORDER BY t.ServiceDate) AS EnrolledSortOrder,
                            ROW_NUMBER() OVER (PARTITION BY t.MemberID, t.EventDate ORDER BY t.ServiceDate) AS SortOrder,
                            1 AS IsEnrolled
                  FROM      PostpartumVisitDatesBase AS t
                            CROSS APPLY (SELECT *
                                         FROM   Results AS r
                                         WHERE  r.MemberID = t.MemberID AND
                                                r.EventDate = t.EventDate AND
                                                r.MeasureID = t.MeasureID
                                        ) AS MMS
                  WHERE     (MMS.AllowConcurrentScoringRanges = 1 AND
                             (t.ServiceDate BETWEEN MMS.PostpartumCareStartDate1
                                            AND     MMS.PostpartumCareEndDate1 OR
                              t.ServiceDate BETWEEN MMS.PostpartumCareStartDate2
                                            AND     MMS.PostpartumCareEndDate2
                             )
                            ) OR
                            (MMS.AllowConcurrentScoringRanges = 0 AND
                             t.ServiceDate BETWEEN MMS.PostpartumCareStartDateScore
                                           AND     MMS.PostpartumCareEndDateScore
                            )
                  GROUP BY  t.ServiceDate,
                            t.MemberID,
                            t.EventDate
                 ),
            PrenatalVisitsDateRange
              AS (SELECT    t1.MemberID,
                            t1.EventDate,
                            t1.ServiceDate AS FirstTwoPrenatalStartDate,
                            ISNULL(t2.ServiceDate, t1.ServiceDate) AS FirstTwoPrenatalEndDate,
                            t1.MeasureID AS FirstTwoPrenatalStartSourceMeasureID,
                            ISNULL(t2.MeasureID, t1.MeasureID) AS FirstTwoPrenatalEndSourceMeasureID,
                            t1.HasMultipleMeasures AS FirstTwoPrenatalStartSourceHasMultiMeasures,
                            COALESCE(t2.HasMultipleMeasures,
                                     t1.HasMultipleMeasures, 0) AS FirstTwoPrenatalEndSourceHasMultiMeasures
                  FROM      PrenatalVisitDates AS t1
                            LEFT OUTER JOIN PrenatalVisitDates AS t2 ON t2.EventDate = t1.EventDate AND
                                                              t2.MemberID = t1.MemberID AND
                                                              t2.SortOrder = 2
                  WHERE     (t1.SortOrder = 1)
                 ),
            PrenatalVisitsEnrolledDateRange
              AS (SELECT    t1.MemberID,
                            t1.EventDate,
                            t1.ServiceDate AS FirstTwoEnrolledPrenatalStartDate,
                            ISNULL(t2.ServiceDate, t1.ServiceDate) AS FirstTwoEnrolledPrenatalEndDate,
                            t1.MeasureID AS FirstTwoEnrolledPrenatalStartSourceMeasureID,
                            ISNULL(t2.MeasureID, t1.MeasureID) AS FirstTwoEnrolledPrenatalEndSourceMeasureID,
                            t1.HasMultipleMeasures AS FirstTwoEnrolledPrenatalStartSourceHasMultiMeasures,
                            COALESCE(t2.HasMultipleMeasures,
                                     t1.HasMultipleMeasures, 0) AS FirstTwoEnrolledPrenatalEndSourceHasMultiMeasures
                  FROM      PrenatalVisitDates AS t1
                            LEFT OUTER JOIN PrenatalVisitDates AS t2 ON t2.EventDate = t1.EventDate AND
                                                              t2.MemberID = t1.MemberID AND
                                                              t2.EnrolledSortOrder = 2 AND
                                                              t2.IsEnrolled = 1
                  WHERE     (t1.EnrolledSortOrder = 1) AND
                            (t1.IsEnrolled = 1)
                 )
        INSERT  INTO @Results
                (MemberMeasureSampleID,
                 MemberID,
                 MeasureID,
                 EventDate,
                 DeliveryDate,
                 PrenatalCareScore,
                 PrenatalCareStartDateScore,
                 PrenatalCareEndDateScore,
                 PrenatalCare1,
                 PrenatalCareStartDate1,
                 PrenatalCareEndDate1,
                 PrenatalCare2,
                 PrenatalCareStartDate2,
                 PrenatalCareEndDate2,
                 PrenatalCare3,
                 PrenatalCareStartDate3,
                 PrenatalCareEndDate3,
                 PostpartumCareScore,
                 PostpartumCareStartDateScore,
                 PostpartumCareEndDateScore,
                 PostpartumCare1,
                 PostpartumCareStartDate1,
                 PostpartumCareEndDate1,
                 PostpartumCare2,
                 PostpartumCareStartDate2,
                 PostpartumCareEndDate2,
                 DiffDays,
                 EddDiffDays,
                 AdminDeliveryDate,
                 MRDeliveryDate,
                 MREstimatedDate,
                 LastEnrollSegStartDate,
                 AdminPriorToDays,
                 MRPriorToDays,
                 MREddPriorToDays,
                 AllowConcurrentScoringRanges,
                 AllowConcurrentScoringRangesPostpartum,
                 DODSourceMeasureID,
                 EDDSourceMeasureID,
                 FirstTwoPrenatalStartDate,
                 FirstTwoPrenatalEndDate,
                 FirstTwoPrenatalStartSourceMeasureID,
                 FirstTwoPrenatalEndSourceMeasureID,
                 FirstTwoPrenatalStartSourceHasMultiMeasures,
                 FirstTwoPrenatalEndSourceHasMultiMeasures,
                 FirstTwoEnrolledPrenatalStartDate,
                 FirstTwoEnrolledPrenatalEndDate,
                 FirstTwoEnrolledPrenatalStartSourceMeasureID,
                 FirstTwoEnrolledPrenatalEndSourceMeasureID,
                 FirstTwoEnrolledPrenatalStartSourceHasMultiMeasures,
                 FirstTwoEnrolledPrenatalEndSourceHasMultiMeasures,
				 HasPrenatalVisit,
				 HasPostpartumVisit,
				 IsPPC1Denominator,
				 IsPPC1Numerator,
				 IsPPC2Denominator,
				 IsPPC2Numerator
                )
                SELECT  t.MemberMeasureSampleID,
                        t.MemberID,
                        t.MeasureID,
                        t.EventDate,
                        t.DeliveryDate,
                        t.PrenatalCareScore,
                        t.PrenatalVisitsStartDateScore AS PrenatalCareStartDateScore,
                        t.PrenatalVisitsEndDateScore AS PrenatalCareEndDateScore,
                        t.PrenatalCare1,
                        t.PrenatalVisitsStartDate1 AS PrenatalCareStartDate1,
                        t.PrenatalVisitsEndDate1 AS PrenatalCareEndDate1,
                        t.PrenatalCare2,
                        t.PrenatalVisitsStartDate2 AS PrenatalCareStartDate2,
                        t.PrenatalVisitsEndDate2 AS PrenatalCareEndDate2,
                        t.PrenatalCare3,
                        t.PrenatalVisitsStartDate3 AS PrenatalCareStartDate3,
                        t.PrenatalVisitsEndDate3 AS PrenatalCareEndDate3,
                        t.PostpartumCareScore,
                        t.PostpartumCareStartDateScore,
                        t.PostpartumCareEndDateScore,
                        t.PostpartumCare1,
                        t.PostpartumCareStartDate1,
                        t.PostpartumCareEndDate1,
                        t.PostpartumCare2,
                        t.PostpartumCareStartDate2,
                        t.PostpartumCareEndDate2,
                        t.DiffDays,
                        t.EddDiffDays,
                        t.AdminDeliveryDate,
                        t.MRDeliveryDate,
                        t.MREstimatedDate,
                        t.LastEnrollSegStartDate,
                        t.AdminPriorToDays,
                        t.MRPriorToDays,
                        t.MREddPriorToDays,
                        t.AllowConcurrentScoringRanges,
                        t.AllowConcurrentScoringRangesPostpartum,
                        t.DODSourceMeasureID,
                        t.EDDSourceMeasureID,
                        PVDR.FirstTwoPrenatalStartDate,
                        PVDR.FirstTwoPrenatalEndDate,
                        PVDR.FirstTwoPrenatalStartSourceMeasureID,
                        PVDR.FirstTwoPrenatalEndSourceMeasureID,
                        PVDR.FirstTwoPrenatalStartSourceHasMultiMeasures,
                        PVDR.FirstTwoPrenatalEndSourceHasMultiMeasures,
                        PVEDR.FirstTwoEnrolledPrenatalStartDate,
                        PVEDR.FirstTwoEnrolledPrenatalEndDate,
                        PVEDR.FirstTwoEnrolledPrenatalStartSourceMeasureID,
                        PVEDR.FirstTwoEnrolledPrenatalEndSourceMeasureID,
                        PVEDR.FirstTwoEnrolledPrenatalStartSourceHasMultiMeasures,
                        PVEDR.FirstTwoEnrolledPrenatalEndSourceHasMultiMeasures,
						CONVERT(bit, CASE WHEN PVDR.FirstTwoPrenatalStartDate IS NOT NULL THEN 1 ELSE 0 END) AS HasPrenatalVisit,
						CONVERT(bit, CASE WHEN PSVD.ServiceDate IS NOT NULL THEN 1 ELSE 0 END) AS HasPostpartumVisit,
						CONVERT(bit, CASE WHEN PPC1.Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC1Denominator,
						CONVERT(bit, CASE WHEN PPC1.HybridHit = 1 AND PPC1.Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC1Numerator,
						CONVERT(bit, CASE WHEN PPC2.Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC2Denominator,
						CONVERT(bit, CASE WHEN PPC2.HybridHit = 1 AND PPC2.Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC2Numerator
                FROM    Results AS t
                        LEFT OUTER JOIN PrenatalVisitsDateRange AS PVDR ON PVDR.EventDate = t.EventDate AND
                                                              PVDR.MemberID = t.MemberID
                        LEFT OUTER JOIN PrenatalVisitsEnrolledDateRange AS PVEDR ON PVEDR.EventDate = t.EventDate AND
                                                              PVEDR.MemberID = t.MemberID
						OUTER APPLY (
										SELECT TOP 1
												*
										FROM	PostpartumVisitDates AS tPSVD
										WHERE	tPSVD.SortOrder = 1 AND
												tPSVD.MemberID = t.MemberID AND
												tPSVD.EventDate = t.EventDate
									) AS PSVD
						OUTER APPLY
						(
							SELECT TOP 1
									tMMMS.*
							FROM	dbo.MemberMeasureMetricScoring AS tMMMS
									INNER JOIN dbo.MemberMeasureSample AS tMMS
											ON tMMS.MemberMeasureSampleID = tMMMS.MemberMeasureSampleID
									INNER JOIN dbo.HEDISSubMetric AS tMX
											ON tMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID
							WHERE	tMX.HEDISSubMetricCode = 'PPC1' AND
									tMMS.MemberID = t.MemberID AND
									tMMS.EventDate = t.EventDate
						) AS PPC1
						OUTER APPLY
						(
							SELECT TOP 1
									tMMMS.*
							FROM	dbo.MemberMeasureMetricScoring AS tMMMS
									INNER JOIN dbo.MemberMeasureSample AS tMMS
											ON tMMS.MemberMeasureSampleID = tMMMS.MemberMeasureSampleID
									INNER JOIN dbo.HEDISSubMetric AS tMX
											ON tMX.HEDISSubMetricID = tMMMS.HEDISSubMetricID
							WHERE	tMX.HEDISSubMetricCode = 'PPC2' AND
									tMMS.MemberID = t.MemberID AND
									tMMS.EventDate = t.EventDate
						) AS PPC2;

    RETURN;
END;

GO
