SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ProviderSiteAbstractionRoster]

AS


SELECT	DISTINCT
		M.MemberID 
		,PR.ProviderSiteID
		,M.NameLast
		,M.NameFirst
		,M.NameLast + ', ' + M.NameFirst FullName
		,M.Gender
		,DATEDIFF( yy, M.DateOfBirth, CAST( '12/31/' + CAST( YEAR(getdate()) AS varchar) AS DateTime) ) Age
		,CONVERT( varchar,M.DateOfBirth,101) DateOfBirth
		,ME.HEDISMeasureDescription
		,prv.ProviderID
		,prv.NameEntityFullName
		,ME.HEDISMeasure
		

FROM	Member M
JOIN	Pursuit P ON M.MemberID = P.MemberID
JOIN	PursuitEvent PE ON P.PursuitID = PE.PursuitID
JOIN	Measure ME ON PE.MeasureID = ME.MeasureID
JOIN	ProviderSite PR ON P.ProviderSiteID = PR.ProviderSiteID
JOIN	dbo.Providers prv ON p.ProviderID = prv.ProviderID
GO
