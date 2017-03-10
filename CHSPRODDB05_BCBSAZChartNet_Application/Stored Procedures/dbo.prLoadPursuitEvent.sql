SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadPursuitEvent]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application tables: Pursuit, PursuitEvent, 
from Client Import table: PursuitEvent
*/
--***********************************************************************
--***********************************************************************
AS 
DECLARE @GroupOnPursuitNumber bit = 1;

INSERT  INTO Pursuit
        (PursuitNumber,
         MemberID,
         ProviderID,
         ProviderSiteID,
		 PursuitCategory
        )
        SELECT 
                MIN(a.PursuitEventTrackingNumber) AS PursuitNumber,
				b.MemberID,
				c.ProviderID,
				d.ProviderSiteID,
				a.PursuitCategory
        FROM    RDSM.PursuitEvent a
                INNER JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID AND
                                      a.ProductLine = b.ProductLine AND
                                      a.Product = b.Product
                INNER JOIN Providers c ON a.CustomerProviderID = c.CustomerProviderID
                INNER JOIN ProviderSite d ON a.ProviderSiteID = d.CustomerProviderSiteID
		GROUP BY CASE @GroupOnPursuitNumber WHEN 1 THEN a.PursuitEventTrackingNumber ELSE '' END,
				b.MemberID,
				c.ProviderID,
				d.ProviderSiteID,
				a.PursuitCategory;


INSERT  INTO PursuitEvent
        (PursuitID,
         PursuitEventStatus,
		 AbstractionStatusID,
         MeasureID,
         EventDate
        )
        SELECT  PursuitID = e.PursuitID,
                PursuitEventStatus = '1',
				AbstractionStatusID = 1,
                MeasureID = f.MeasureID,
                EventDate = a.EventDate
        FROM    RDSM.PursuitEvent a
                INNER JOIN Member b ON a.CustomerMemberID = b.CustomerMemberID AND
                                       a.ProductLine = b.ProductLine AND
                                       a.Product = b.Product
                INNER JOIN Providers c ON a.CustomerProviderID = c.CustomerProviderID
                INNER JOIN ProviderSite d ON a.ProviderSiteID = d.CustomerProviderSiteID
                INNER JOIN Pursuit e ON b.MemberID = e.MemberID AND
                                        c.ProviderID = e.ProviderID AND
										d.ProviderSiteID = e.ProviderSiteID AND
										(@GroupOnPursuitNumber = 0 OR a.PursuitEventTrackingNumber = e.PursuitNumber)                                   
                INNER JOIN Measure f ON a.HEDISMeasure = f.HEDISMeasure;





GO
