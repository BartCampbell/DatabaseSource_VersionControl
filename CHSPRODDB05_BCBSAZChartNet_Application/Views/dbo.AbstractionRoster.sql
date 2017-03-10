SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AbstractionRoster]

AS


SELECT	DISTINCT
		M.MemberID 
		,PR.CustomerProviderID
		,M.NameLast
		,M.NameFirst
		,M.NameLast + ', ' + M.NameFirst FullName
		,M.Gender
		,DATEDIFF( yy, M.DateOfBirth, CAST( '12/31/' + CAST( YEAR(getdate()) AS varchar) AS DateTime) ) Age
		,CONVERT( varchar,M.DateOfBirth,101) DateOfBirth
		,ME.HEDISMeasureDescription

FROM	Member M
JOIN	Pursuit P ON M.MemberID = P.MemberID
JOIN	PursuitEvent PE ON P.PursuitID = PE.PursuitID
JOIN	Measure ME ON PE.MeasureID = ME.MeasureID
JOIN	Providers PR ON P.ProviderID = PR.ProviderID


GO
