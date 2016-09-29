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
			
	SELECT COUNT(CD.CodedData_PK) [Total Coded Diagnosis]
		,COUNT(QA.CodedData_PK) [QA Sample]
		,SUM(CAST(IsConfirmed AS TinyInt)) Confirmed 
		,SUM(CAST(IsChanged AS TinyInt)) Changed 
		,SUM(CAST(IsAdded AS TinyInt)) Added 
		,SUM(CAST(IsRemoved AS TinyInt)) Removed 
	FROM tblCodedData CD  WITH (NOLOCK) 
		INNER JOIN tblSuspect S  WITH (NOLOCK) ON S.Suspect_PK = CD.Suspect_PK
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
		LEFT JOIN tblCodedDataQA QA  WITH (NOLOCK) ON CD.CodedData_PK = QA.CodedData_PK	
	WHERE (@Channel=0 OR S.Channel_PK=@Channel)
END
GO
