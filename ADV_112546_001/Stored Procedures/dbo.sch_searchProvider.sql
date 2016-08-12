SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- sch_searchProvider 1,'123',1
CREATE PROCEDURE [dbo].[sch_searchProvider] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@provider varchar(200),
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
	
	SELECT TOP 15 PM.Provider_ID,PM.Lastname+', '+PM.Firstname ProviderName,P.Provider_PK,Count(S.Member_PK) Charts
	FROM tblProvider P
		INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK 
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
	WHERE PM.Provider_ID+' '+PM.Lastname+' '+PM.Firstname LIKE '%'+@provider+'%'
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname+', '+PM.Firstname
END
GO
