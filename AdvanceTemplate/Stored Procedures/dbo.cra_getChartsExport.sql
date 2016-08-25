SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	cra_getChartsExport 0,1
CREATE PROCEDURE [dbo].[cra_getChartsExport] 
	@project int,
	@user int
AS
BEGIN
--SET @PageSize=1000
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @project=0 
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@user
	END
	ELSE
		INSERT INTO #tmpProject(Project_PK) VALUES(@project)

	SELECT [Report Date],SUM([Recieved Invoices]) [Recieved Invoices],SUM([Recieved Chart By Fax]) [Recieved Chart By Fax],SUM([Recieved Chart By Mail]) [Recieved Chart By Mail],SUM([CNA]) [CNA],SUM([Recieved Incomplete Chart]) [Recieved Incomplete Chart],SUM([Scanned]) [Scanned] FROM
	(
		SELECT CAST(InvoiceRec_Date AS DATE) [Report Date],Count(*) [Recieved Invoices],0 [Recieved Chart By Fax],0 [Recieved Chart By Mail],0 [CNA],0 [Recieved Incomplete Chart],0 [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE InvoiceRec_Date IS NOT NULL GROUP BY CAST(InvoiceRec_Date AS DATE)
		UNION
		SELECT CAST(ChartRec_FaxIn_Date AS DATE) [Report Date],0 [Recieved Invoices],Count(*) [Recieved Chart By Fax],0 [Recieved Chart By Mail],0 [CNA],0 [Recieved Incomplete Chart],0 [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE ChartRec_FaxIn_Date IS NOT NULL GROUP BY CAST(ChartRec_FaxIn_Date AS DATE)
		UNION
		SELECT CAST(ChartRec_MailIn_Date AS DATE) [Report Date],0 [Recieved Invoices],0 [Recieved Chart By Fax],Count(*) [Recieved Chart By Mail],0 [CNA],0 [Recieved Incomplete Chart],0 [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE ChartRec_MailIn_Date IS NOT NULL GROUP BY CAST(ChartRec_MailIn_Date AS DATE)
		UNION
		SELECT CAST(CNA_Date AS DATE) [Report Date],0 [Recieved Invoices],0 [Recieved Chart By Fax],0 [Recieved Chart By Mail],Count(*) [CNA],0 [Recieved Incomplete Chart],0 [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE CNA_Date IS NOT NULL GROUP BY CAST(CNA_Date AS DATE)
		UNION
		SELECT CAST(ChartRec_InComp_Date AS DATE) [Report Date],0 [Recieved Invoices],0 [Recieved Chart By Fax],0 [Recieved Chart By Mail],0 [CNA],Count(*) [Recieved Incomplete Chart],0 [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE ChartRec_InComp_Date IS NOT NULL GROUP BY CAST(ChartRec_InComp_Date AS DATE)
		UNION
		SELECT CAST(Scanned_Date AS DATE) [Report Date],0 [Recieved Invoices],0 [Recieved Chart By Fax],0 [Recieved Chart By Mail],0 [CNA],0 [Recieved Incomplete Chart],Count(*) [Scanned] FROM tblSuspect S INNER JOIN #tmpProject P ON P.Project_PK=S.Project_PK WHERE Scanned_Date IS NOT NULL GROUP BY CAST(Scanned_Date AS DATE)
	) T GROUP BY [Report Date] ORDER BY [Report Date]

END
GO
