SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getQAStatus 0,1
*/
CREATE PROCEDURE [dbo].[rdb_getQAStatus]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Channel int
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

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK<>@ProjectGroup
		
	IF (@Channel<>0)
		DELETE T FROM #tmpChannel T WHERE Channel_PK<>@Channel				 
	-- PROJECT/Channel SELECTION
		
	SELECT COUNT(CD.CodedData_PK) [Total Coded Diagnosis]
		,COUNT(QA.CodedData_PK) [QA Sample]
		,SUM(CAST(IsConfirmed AS TinyInt)) Confirmed 
		,SUM(CAST(IsChanged AS TinyInt)) Changed 
		,SUM(CAST(IsAdded AS TinyInt)) Added 
		,SUM(CAST(IsRemoved AS TinyInt)) Removed 
	FROM tblCodedData CD  WITH (NOLOCK) 
		INNER JOIN tblSuspect S  WITH (NOLOCK) ON S.Suspect_PK = CD.Suspect_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		LEFT JOIN tblCodedDataQA QA  WITH (NOLOCK) ON CD.CodedData_PK = QA.CodedData_PK	
END
GO
