SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOfficeProvider 1,1
CREATE PROCEDURE [dbo].[sch_getOfficeProvider] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Office bigint,
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION

	SELECT PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') ProviderName,P.Provider_PK,Count(S.Member_PK) Charts,SUM(CASE WHEN IsScanned=0 AND IsCNA=0 THEN 1 ELSE 0 END) Remaining
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK 
	WHERE P.ProviderOffice_PK=@Office
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname

	--Office location is scheduled for total xx charts. 31 charts recieved correctly. 10 charts recieved incomplete. 5 charts invoices recieved
	SELECT COUNT(S.Suspect_PK) Charts
		,SUM(CASE WHEN Scanned_Date IS NOT NULL OR ChartRec_Date IS NOT NULL THEN 1 ELSE 0 END) ChartRec
		,SUM(CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND ChartRec_InComp_Date IS NOT NULL THEN 1 ELSE 0 END) ChartRec_InComp
		,SUM(CASE WHEN Scanned_Date IS NULL AND ChartRec_Date IS NULL AND InvoiceRec_Date IS NOT NULL THEN 1 ELSE 0 END) InvoiceRec
		,SUM(CASE WHEN Scanned_Date IS NULL AND InvoiceRec_Date IS NULL AND ChartRec_Date IS NULL AND IsCNA=1 THEN 1 ELSE 0 END) CNA
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK 
	WHERE P.ProviderOffice_PK=@Office
END
GO
