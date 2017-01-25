SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[prBuildStFranDataMarts]

AS

-- Key population



IF OBJECT_ID('tempdb..#KeyPop') IS NOT NULL 
	DROP TABLE #KeyPop


IF OBJECT_ID('tempdb..#mbrmth') IS NOT NULL 
	DROP TABLE #MbrMth

SELECT mm.Client, 
		YearMonth = LEFT(mm.MonthDate,6), 
		MemberMonths = SUM(mm.member_month_first)
	INTO #mbrMth
	FROM brxref_MemberMonth mm
		INNER JOIN member m
			ON mm.MemberID= m.MemberID
	GROUP BY mm.Client, 
		LEFT(mm.MonthDate,6)

IF OBJECT_ID('tempdb..#ClaimStats') IS not NULL 
	DROP TABLE #ClaimStats

SELECT Payer = cli.Client, 
		ServiceYear = YEAR(cli.DateServiceBegin),
		ServiceYearMonth = LEFT(CONVERT(VARCHAR(8),cli.DateServiceBegin,112),6),
		ServicingProviderName = p.ProviderFullName,
		AsthmaFlag = MAX(CASE WHEN x_m.AsthmaFlag = 1 THEN 'Asthma Member' ELSE '' END),
		DiabetesFlag = MAX(CASE WHEN x_m.DiabetesFlag =1 THEN 'Diabetic Member' ELSE '' END),
		IPDays = SUM(x_cli.IPDays),
		IPAdmits = SUM(x_cli.IPAdmit),
		ALOS = SUM(x_cli.IPDays)/SUM(x_cli.IPAdmit),
		EDVisit = SUM(x_cli.EDVisit)
	INTO #ClaimStats
	FROM dbo.ClaimLineItem cli
		INNER JOIN claim c
			ON c.ClaimID = cli.ClaimID
		INNER JOIN dbo.BrXref_ClaimLineItem x_cli
			ON x_cli.ClaimLineItemID = cli.ClaimLineItemID
		INNER JOIN dbo.BrXref_Claim x_c
			ON x_c.ClaimID = cli.ClaimID
		LEFT JOIN provider p
			ON c.ihds_prov_id_servicing = p.ihds_prov_id
		LEFT JOIN brxref_member x_m
			ON c.MemberID = x_m.MemberID
	GROUP BY cli.Client, 
		YEAR(cli.DateServiceBegin),
		LEFT(CONVERT(VARCHAR(8),cli.DateServiceBegin,112),6),
		p.ProviderFullName


GO
