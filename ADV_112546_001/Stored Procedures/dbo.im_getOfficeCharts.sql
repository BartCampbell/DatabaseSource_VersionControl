SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getOfficeCharts 1,1
CREATE PROCEDURE [dbo].[im_getOfficeCharts] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Office int,
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
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

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			M.Lastname+IsNull(', '+M.Firstname,'')
		) AS RowNumber
			,S.Suspect_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,S.IsScanned Scanned,Scanned_Date
			,S.IsCNA CNA,CNA_Date
			,S.IsCoded Coded,Coded_Date
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,IsNull(SI.Invoice_PK,0) Invoice_PK
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK	
			LEFT JOIN tblSuspectInvoiceDetail SI WITH (NOLOCK) ON SI.Suspect_PK = S.Suspect_PK
		WHERE P.ProviderOffice_PK=@Office
END
GO
