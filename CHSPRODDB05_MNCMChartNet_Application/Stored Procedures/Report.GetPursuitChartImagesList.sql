SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetPursuitChartImagesList]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
			R.PursuitNumber AS [Pursuit Number],
			M.CustomerMemberID AS [Customer Member ID],
			M.MemberID AS [IMI Member ID],
			M.ProductLine AS [Product Line],
			M.Product AS [Product],
			M.NameLast AS [Last Name],
			M.NameFirst AS [First Name],
			M.DateOfBirth AS [Date of Birth],
			P.CustomerProviderID AS [Customer Provider ID],
			P.ProviderID AS [IMI Provider ID],
			ISNULL(NULLIF(P.NameEntityFullName, ''), P.NameLast + ISNULL(', ' + NULLIF(P.NameFirst, ''), '')) AS [Provider Name],
			CASE WHEN LEN(M.SSN) = 9 THEN '###-##-' + RIGHT(M.SSN, 4) ELSE '' END AS SSN,
			NULLIF(PS.Address1, '') AS [Provider Site - Address 1],
			NULLIF(PS.Address2, '') AS [Provider Site - Address 2],
			NULLIF(PS.City, '') AS [Provider Site - City],
			NULLIF(PS.State, '') AS [Provider Site - State],
			NULLIF(PS.Zip, '') AS [Provider Site - Zip Code],
			NULLIF(PS.County, '') AS [Provider Site - County],
			A.AbstractorName AS Abstractor,
			ISNULL(V2.ReviewerName, V.ReviewerName) AS Reviewer,
			S.[Description] AS [Abstraction Status],
			LMRC.LastChangedDate AS [Last Abstraction Entry - Date/Time],
			LMRC.LastChangedUser AS [Last Abstraction Entry - User],
			RVCI.ImageName AS [Chart Image - File Name],
			RVCI.MimeType AS [Chart Image - MIME Type],
			RVCI.CreatedDate AS [Chart Image - Load Date]
	FROM	dbo.Pursuit AS R WITH(NOLOCK)
			INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON R.PursuitID = RV.PursuitID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON R.AbstractorID = A.AbstractorID
			LEFT OUTER JOIN dbo.AbstractionStatus AS S WITH(NOLOCK)
					ON RV.AbstractionStatusID = S.AbstractionStatusID
			LEFT OUTER JOIN dbo.Reviewer AS V WITH(NOLOCK)
					ON R.ReviewerID = V.ReviewerID
			OUTER APPLY (	
							SELECT TOP 1 
									tV.ReviewerID, tV.ReviewerName 
							FROM	dbo.AbstractionReview AS tAR WITH(NOLOCK)
									INNER JOIN dbo.Reviewer AS tV WITH(NOLOCK)
											ON tAR.ReviewerID = tV.ReviewerID
							WHERE 	(tAR.PursuitEventID = RV.PursuitEventID)
							ORDER BY tAR.ReviewDate DESC
						) AS V2
			OUTER APPLY (
							SELECT TOP 1
									*
							FROM	dbo.MedicalRecordComposite AS tMRC WITH(NOLOCK)
							WHERE	tMRC.PursuitEventID = RV.PursuitEventID
							ORDER BY tMRC.LastChangedDate DESC
						) AS LMRC
			LEFT OUTER JOIN dbo.PursuitEventChartImage AS RVCI WITH(NOLOCK)
					ON RV.PursuitEventID = RVCI.PursuitEventID
			INNER JOIN dbo.Member AS M WITH(NOLOCK)
					ON R.MemberID = M.MemberID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON R.ProviderSiteID = PS.ProviderSiteID
			INNER JOIN dbo.Providers AS P WITH(NOLOCK)
					ON R.ProviderID = P.ProviderID
	ORDER BY M.NameLast, M.NameFirst, M.CustomerMemberID, RVCI.ImageName;
	
END
GO
GRANT EXECUTE ON  [Report].[GetPursuitChartImagesList] TO [Reporting]
GO
