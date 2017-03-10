SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetPPCDateRanges]
(	
	@MemberID int = NULL
)
RETURNS @Results TABLE 
(
	[MemberMeasureSampleID] [int] NOT NULL,
	[MemberID] [int] NOT NULL,
	[MeasureID] [int] NOT NULL,
	[EventDate] datetime NOT NULL,
	[PPCDeliveryDate] [datetime] NULL,
	[PPCPrenatalCareScore] [varchar](32) NULL,
	[PPCPrenatalCareStartDateScore] [datetime] NULL,
	[PPCPrenatalCareEndDateScore] [datetime] NULL,
	[PPCPrenatalCare1] [varchar](32) NULL,
	[PPCPrenatalCareStartDate1] [datetime] NULL,
	[PPCPrenatalCareEndDate1] [datetime] NULL,
	[PPCPrenatalCare2] [varchar](32) NULL,
	[PPCPrenatalCareStartDate2] [datetime] NULL,
	[PPCPrenatalCareEndDate2] [datetime] NULL,
	[PPCPrenatalCare3] [varchar](32) NULL,
	[PPCPrenatalCareStartDate3] [datetime] NULL,
	[PPCPrenatalCareEndDate3] [datetime] NULL,
	[PPCPostpartumCareScore] [varchar](32) NULL,
	[PPCPostpartumCareStartDateScore] [datetime] NULL,
	[PPCPostpartumCareEndDateScore] [datetime] NULL,
	[PPCPostpartumCare1] [varchar](32) NULL,
	[PPCPostpartumCareStartDate1] [datetime] NULL,
	[PPCPostpartumCareEndDate1] [datetime] NULL,
	[PPCPostpartumCare2] [varchar](32) NULL,
	[PPCPostpartumCareStartDate2] [datetime] NULL,
	[PPCPostpartumCareEndDate2] [datetime] NULL,
	[PPCEnrollmentCategoryID] [int] NULL,
	[DiffDays] [int] NULL,
	[EddDiffDays] [int] NULL,
	[AdminDeliveryDate] [datetime] NULL,
	[MRDeliveryDate] [datetime] NULL,
	[MREstimatedDate] [datetime] NULL,
	[LastEnrollSegStartDate] [datetime] NULL,
	[AdminPriorToDays] [smallint] NULL,
	[MRPriorToDays] [smallint] NULL,
	[MREddPriorToDays] [smallint] NULL,
	[CalcAdminEnrollmentCategoryID] [int] NULL,
	[CalcMREnrollmentCategoryID] [int] NULL,
	[CalcMREddEnrollmentCategoryID] [int] NULL,
	[AllowConcurrentScoringRanges] [bit] NULL,
	[AllowConcurrentScoringRangesPostpartum] [bit] NULL
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

	DECLARE @PPCMeasureID int;
	SELECT  @PPCMeasureID = MeasureID
	FROM    dbo.Measure
	WHERE   HEDISMeasure = 'PPC';

    WITH    PPCDeliveryDates
              AS (SELECT    PPC.ServiceDate AS DeliveryDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate,
                            PPC.LastChangedDate
                  FROM      dbo.MedicalRecordPPC AS PPC
                            INNER JOIN dbo.Pursuit AS R ON PPC.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON PPC.PursuitEventID = RV.PursuitEventID
                  WHERE     (PPC.NumeratorType IN ('Delivery Date', 'Delivery',
                                                   'DeliveryDate'))),
            PPCEstimatedDeliveryDates
              AS (SELECT    PPC.ServiceDate AS DeliveryDate,
                            RV.MeasureID,
                            R.MemberID,
                            RV.EventDate,
                            PPC.LastChangedDate
                  FROM      dbo.MedicalRecordPPC AS PPC
                            INNER JOIN dbo.Pursuit AS R ON PPC.PursuitID = R.PursuitID
                            INNER JOIN dbo.PursuitEvent AS RV ON PPC.PursuitEventID = RV.PursuitEventID
                  WHERE     (PPC.NumeratorType IN ('Chart EDD', 'EDD',
                                                   'ChartEDD'))),
            PPCDeliveryMatching
              AS (SELECT    MMS.*,
                            DATEDIFF(dd, MMS.PPCDeliveryDate, t1.DeliveryDate) AS DiffDays,
                            DATEDIFF(dd, MMS.PPCDeliveryDate, t2.DeliveryDate) AS EddDiffDays,
                            t1.DeliveryDate AS MRDeliveryDate,
                            t2.DeliveryDate AS MREstimatedDate,
                            CASE WHEN MMS.PPCEnrollmentCategoryID = 1 AND
                                      DATEDIFF(dd,
                                               ISNULL(MMS.PPCLastEnrollSegStartDate,
                                                      MMS.PPCPrenatalCareStartDate),
                                               MMS.PPCDeliveryDate) < 280
                                 THEN NULL
                                 ELSE ISNULL(MMS.PPCLastEnrollSegStartDate,
                                             MMS.PPCPrenatalCareStartDate)
                            END AS LastEnrollSegStartDate
                  FROM      dbo.MemberMeasureSample AS MMS
                            OUTER APPLY (SELECT TOP 1
                                                PPC.*
                                         FROM   PPCDeliveryDates AS PPC
                                         WHERE  PPC.MeasureID = MMS.MeasureID AND
                                                PPC.MemberID = MMS.MemberID AND
                                                PPC.EventDate = MMS.EventDate AND
                                                --Added HEDIS 2014 with addition of PursuitEvent.EventDate                                    
												PPC.DeliveryDate BETWEEN DATEADD(dd,
                                                              (@PPCDeliveryDateMatchingWindow *
                                                              -1),
                                                              MMS.PPCDeliveryDate)
                                                              AND
                                                              DATEADD(dd,
                                                              @PPCDeliveryDateMatchingWindow,
                                                              MMS.PPCDeliveryDate) AND
                                                PPC.MeasureID = @PPCMeasureID
                                         ORDER BY DeliveryDate DESC) AS t1
                            OUTER APPLY (SELECT TOP 1
                                                PPC.*
                                         FROM   PPCEstimatedDeliveryDates AS PPC
                                         WHERE  PPC.MeasureID = MMS.MeasureID AND
                                                PPC.MemberID = MMS.MemberID AND
                                                PPC.EventDate = MMS.EventDate AND
                                                --Added HEDIS 2014 with addition of PursuitEvent.EventDate                                      
												PPC.DeliveryDate BETWEEN DATEADD(dd,
                                                              (@PPCDeliveryDateMatchingWindow *
                                                              -1),
                                                              MMS.PPCDeliveryDate)
                                                              AND
                                                              DATEADD(dd,
                                                              @PPCDeliveryDateMatchingWindow,
                                                              MMS.PPCDeliveryDate) AND
                                                PPC.MeasureID = @PPCMeasureID
                                         ORDER BY DeliveryDate DESC) AS t2),
            PPCDatesBase
              AS (SELECT    *,
                            DATEDIFF(dd,
                                     ISNULL(LastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     PPCDeliveryDate) AS AdminPriorToDays,
                            DATEDIFF(dd,
                                     ISNULL(PPCLastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     MRDeliveryDate) AS MRPriorToDays,
                            DATEDIFF(dd,
                                     ISNULL(PPCLastEnrollSegStartDate,
                                            PPCPrenatalCareStartDate),
                                     MREstimatedDate) AS MREddPriorToDays
                  FROM      PPCDeliveryMatching),
			PPCDates 
			  AS (SELECT	*,
							CASE WHEN AdminPriorToDays >= 280 OR LastEnrollSegStartDate IS NULL
								 THEN 1
								 WHEN AdminPriorToDays BETWEEN 219 AND 279 
								 THEN 2
								 WHEN AdminPriorToDays BETWEEN 42 AND 218
								 THEN 3
								 END AS CalcAdminEnrollmentCategoryID,
							CASE WHEN MRPriorToDays >= 280 OR LastEnrollSegStartDate IS NULL
								 THEN 1
								 WHEN MRPriorToDays BETWEEN 219 AND 279 
								 THEN 2
								 WHEN MRPriorToDays BETWEEN 42 AND 218
								 THEN 3
								 END AS CalcMREnrollmentCategoryID,
							CASE WHEN MREddPriorToDays >= 280 OR LastEnrollSegStartDate IS NULL
								 THEN 1
								 WHEN MREddPriorToDays BETWEEN 219 AND 279 
								 THEN 2
								 WHEN MREddPriorToDays BETWEEN 42 AND 218
								 THEN 3
								 END AS CalcMREddEnrollmentCategoryID	                        
				  FROM		PPCDatesBase),
			PPCBase
			  AS (SELECT	*,
							CASE CalcAdminEnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -280, PPCDeliveryDate)
								 WHEN 2 
								 THEN LastEnrollSegStartDate
								 WHEN 3
								 THEN LastEnrollSegStartDate
								 END AS AdminPrenatalStartDate,
							CASE CalcAdminEnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -176, PPCDeliveryDate)
								 WHEN 2 
								 THEN DATEADD(dd, -176, PPCDeliveryDate)
								 WHEN 3
								 THEN DATEADD(dd, 42, LastEnrollSegStartDate)
								 END AS AdminPrenatalEndDate,
							CASE CalcMREnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -280, MRDeliveryDate)
								 WHEN 2 
								 THEN LastEnrollSegStartDate
								 WHEN 3
								 THEN LastEnrollSegStartDate
								 END AS MRPrenatalStartDate,
							CASE CalcMREnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -176, MRDeliveryDate)
								 WHEN 2 
								 THEN DATEADD(dd, -176, MRDeliveryDate)
								 WHEN 3
								 THEN DATEADD(dd, 42, LastEnrollSegStartDate)
								 END AS MRPrenatalEndDate,
							CASE CalcMREddEnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -280, MREstimatedDate)
								 WHEN 2 
								 THEN LastEnrollSegStartDate
								 WHEN 3
								 THEN LastEnrollSegStartDate
								 END AS MREddPrenatalStartDate,
							CASE CalcMREddEnrollmentCategoryID 
								 WHEN 1
								 THEN DATEADD(dd, -176, MREstimatedDate)
								 WHEN 2 
								 THEN DATEADD(dd, -176, MREstimatedDate)
								 WHEN 3
								 THEN DATEADD(dd, 42, LastEnrollSegStartDate)
								 END AS MREddPrenatalEndDate
				  FROM		PPCDates)
		INSERT INTO @Results
		SELECT  PPC.MemberMeasureSampleID,
				PPC.MemberID,
				PPC.MeasureID,
				PPC.EventDate,
				ISNULL(PPC.MRDeliveryDate, PPC.PPCDeliveryDate) AS PPCDeliveryDate,
				---------------------------------------------------------------------------------------------------------
				CONVERT(varchar(32), CASE WHEN PPC.MREddPrenatalStartDate IS NOT NULL THEN 'Chart EDD-based' WHEN PPC.MRPrenatalStartDate IS NOT NULL THEN 'Chart DOD-based' ELSE  'Admin EDD-based' END) AS PPCPrenatalCareScore, 
				COALESCE(PPC.MREddPrenatalStartDate, PPC.MRPrenatalStartDate, PPC.AdminPrenatalStartDate) AS PPCPrenatalCareStartDateScore, --Scoring Start
				COALESCE(PPC.MREddPrenatalEndDate, PPC.MRPrenatalEndDate, PPC.AdminPrenatalEndDate) AS PPCPrenatalCareEndDateScore, --Scoring End
				CONVERT(varchar(32), 'Admin EDD-based') AS PPCPrenatalCare1, 
				PPC.AdminPrenatalStartDate AS PPCPrenatalCareStartDate1, --Admin EDD-based Start
				PPC.AdminPrenatalEndDate AS PPCPrenatalCareEndDate1, --Admin EDD-based End
				CONVERT(varchar(32), 'Chart DOD-based') AS PPCPrenatalCare2, 
				PPC.MRPrenatalStartDate AS PPCPrenatalCareStartDate2, --Chart DOD-based Start
				PPC.MRPrenatalEndDate AS PPCPrenatalCareEndDate2, --Chart DOD-based End
				CONVERT(varchar(32), 'Chart EDD-based') AS PPCPrenatalCare3, 
				PPC.MREddPrenatalStartDate AS PPCPrenatalCareStartDate3, --Chart EDD-based Start
				PPC.MREddPrenatalEndDate AS PPCPrenatalCareEndDate3, --Chart EDD-based End
				---------------------------------------------------------------------------------------------------------
				CONVERT(varchar(32), CASE WHEN PPC.DiffDays IS NOT NULL THEN 'Chart DOD-based' ELSE 'Admin EDD-based' END) AS PPCPostpartumCareScore, 
				DATEADD(dd, 21, COALESCE(PPC.MRDeliveryDate, PPC.PPCDeliveryDate)) AS PPCPostpartumCareStartDateScore, --Scoring Start
				DATEADD(dd, 56, COALESCE(PPC.MRDeliveryDate, PPC.PPCDeliveryDate)) AS PPCPostpartumCareEndDateScore, --Scoring End
				CONVERT(varchar(32), 'Admin EDD-based') AS PPCPostpartumCare1, 
				DATEADD(dd, 21, PPC.PPCDeliveryDate) AS PPCPostpartumCareStartDate1, --Admin EDD-based Start
				DATEADD(dd, 56, PPC.PPCDeliveryDate) AS PPCPostpartumCareEndDate1, --Admin EDD-based End
				CONVERT(varchar(32), 'Chart DOD-based') AS PPCPostpartumCare2, 
				DATEADD(dd, 21, PPC.MRDeliveryDate) AS PPCPostpartumCareStartDate2, --Chart DOD-based Start
				DATEADD(dd, 56, PPC.MRDeliveryDate) AS PPCPostpartumCareEndDate2, --Chart DOD-based End
				PPC.PPCEnrollmentCategoryID,
				PPC.DiffDays,
				PPC.EddDiffDays,
				PPC.PPCDeliveryDate AS AdminDeliveryDate,
				PPC.MRDeliveryDate,
				PPC.MREstimatedDate,
				PPC.LastEnrollSegStartDate,
				PPC.AdminPriorToDays,
				PPC.MRPriorToDays,
				PPC.MREddPriorToDays,
				PPC.CalcAdminEnrollmentCategoryID,
				PPC.CalcMREnrollmentCategoryID,
				PPC.CalcMREddEnrollmentCategoryID,
				@PPCAllowConcurrentScoringRanges AS AllowConcurrentScoringRanges,
				@PPCAllowConcurrentScoringRangesPostpartum AS AllowConcurrentScoringRangesPostpartum
		FROM    PPCBase AS PPC
		WHERE   (PPC.MeasureID = @PPCMeasureID) AND
				((@MemberID IS NULL) OR (PPC.MemberID = @MemberID));

		RETURN;
END
GO
