SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--		rdb_getList 1
CREATE PROCEDURE [dbo].[rdb_getList]
	@User int
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User
	END
	-- PROJECT/Channel

	SELECT DISTINCT S.Channel_PK,S.Project_PK INTO #tmpChannelProject FROM tblSuspect S WITH (NOLOCK)
	CREATE INDEX idxChannelProjectPK ON #tmpChannelProject (Channel_PK,Project_PK)

	SELECT P.* FROM tblProject P WITH (NOLOCK) 
		INNER JOIN #tmpProject tP ON tP.Project_PK = P.Project_PK 
	ORDER BY P.PROJECT_NAME;
	
	SELECT DISTINCT ProjectGroup,ProjectGroup_PK FROM tblProject P WITH (NOLOCK) 
		INNER JOIN #tmpProject tP ON tP.Project_PK = P.Project_PK 
	ORDER BY ProjectGroup;

	SELECT DISTINCT C.Channel_PK, C.Channel_Name,S.Project_PK,Pr.ProjectGroup_PK FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN tblChannel C ON C.Channel_PK = S.Channel_PK
		INNER JOIN tblProject Pr ON Pr.Project_PK = S.Project_PK
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel tC ON tC.Channel_PK = S.Channel_PK
	ORDER BY C.Channel_Name

	SELECT DISTINCT CS.ChaseStatusGroup_PK, CS.ChaseStatus, CS.ChaseStatus_PK,CS.ChartResolutionCode FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN tblChaseStatus CS ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel tC ON tC.Channel_PK = S.Channel_PK
	ORDER BY CS.ChaseStatus,CS.ChartResolutionCode
END
GO
