SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Report_UserCreatedPursuits]
AS 
SELECT  a.PursuitID,
        ChartStatus = LEFT(ChartStatus, 25),
        b.CustomerMemberID,
        b.NameFirst,
        b.NameLast,
        DateOfBirth = CONVERT(varchar(8), b.DateOfBirth, 112),
        HEDISMeasure,
        e.CustomerProviderID,
        e.NameEntityFullName,
        ProviderSiteName
FROM    Pursuit a
        INNER JOIN Member b ON a.MemberID = b.MemberID
        INNER JOIN PursuitEvent c ON a.PursuitID = c.PursuitID
        INNER JOIN Measure d ON c.MeasureID = d.MeasureID
        INNER JOIN Providers e ON a.ProviderID = e.ProviderID
        INNER JOIN ProviderSite f ON a.ProviderSiteID = f.ProviderSiteID
WHERE   CONVERT(varchar(30), a.PursuitID) = PursuitNumber


GO
