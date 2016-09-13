SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- sr_searchMember 1,'A',1
CREATE PROCEDURE [dbo].[sr_searchMember] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@search varchar(200),
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	
	CREATE NONCLUSTERED INDEX IDX_Project_PK
	ON #tmpProject (Project_PK)

	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WITH(NOLOCK) WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WITH(NOLOCK) WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P WITH(NOLOCK) LEFT JOIN tblUserProject UP WITH(NOLOCK) ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WITH(NOLOCK) WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION
	

	SELECT TOP 50 M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'')+' ['+PM.Lastname+IsNull(', '+PM.Firstname,'')+' - ('+PM.Provider_ID+')]' MemberName,M.Member_PK--,Count(S.Suspect_PK) Charts
	FROM tblMember M WITH(NOLOCK) 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
		INNER JOIN #tmpProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON P.ProviderMaster_PK = PM.ProviderMaster_PK
	WHERE M.Member_ID+' '+M.Lastname+' '+IsNull(M.Firstname,'') LIKE '%'+@search+'%'
	--GROUP BY M.Member_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'')
END
GO
