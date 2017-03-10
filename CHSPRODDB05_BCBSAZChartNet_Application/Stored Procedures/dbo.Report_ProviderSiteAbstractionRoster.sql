SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Report_ProviderSiteAbstractionRoster]
    @ProviderSiteID int = NULL,
    @MemberID int = NULL
AS 
DECLARE @YearEndDate datetime
SET @YearEndDate = CAST('12/31/' + CAST(YEAR(GETDATE()) AS varchar) AS datetime)


SELECT	DISTINCT
        M.MemberID,
        PR.CustomerProviderSiteID,
        M.NameLast,
        M.NameFirst,
        M.NameLast + ', ' + M.NameFirst FullName,
        M.Gender,
        DATEDIFF(yy, M.DateOfBirth, @YearEndDate) Age,
        CONVERT(varchar, M.DateOfBirth, 101) DateOfBirth,
        ME.HEDISMeasureDescription,
        PR.ProviderSiteID,
        prv.ProviderID,
        prv.NameEntityFullName,
        ME.HEDISMeasure
FROM    Member M
        JOIN Pursuit P ON M.MemberID = P.MemberID
        JOIN PursuitEvent PE ON P.PursuitID = PE.PursuitID
        JOIN Measure ME ON PE.MeasureID = ME.MeasureID
        JOIN ProviderSite PR ON P.ProviderSiteID = PR.ProviderSiteID
        JOIN dbo.Providers prv ON p.ProviderID = prv.ProviderID
WHERE   PR.ProviderSiteID = ISNULL(@ProviderSiteID, PR.ProviderSiteID) AND
        M.MemberID = ISNULL(@MemberID, M.MemberID)
ORDER BY M.NameLast,
        M.NameFirst,
        ME.HEDISMeasureDescription


GO
