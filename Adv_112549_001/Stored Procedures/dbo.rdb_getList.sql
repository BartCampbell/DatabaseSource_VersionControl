SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--		rdb_getList 1
CREATE PROCEDURE [dbo].[rdb_getList]
	@User int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
	ELSE
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
		WHERE P.IsRetrospective=1 AND UP.User_PK=@User
	-- PROJECT SELECTION

	SELECT P.* FROM tblProject P WITH (NOLOCK) 
		INNER JOIN #tmpProject tP ON tP.Project_PK = P.Project_PK 
	ORDER BY P.PROJECT_NAME;
	
	SELECT DISTINCT ProjectGroup,ProjectGroup_PK FROM tblProject P WITH (NOLOCK) 
		INNER JOIN #tmpProject tP ON tP.Project_PK = P.Project_PK 
	ORDER BY ProjectGroup;

	SELECT DISTINCT C.Channel_PK, C.Channel_Name FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
		INNER JOIN tblChannel C ON C.Channel_PK = S.Channel_PK
	ORDER BY C.Channel_Name
END
GO
