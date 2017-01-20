SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of members in a project
-- =============================================
--	qa_getMembers 0,0,100,1,'','','0,1,7,10','6',''
--	qa_searchMembers 0,'45719444','','1,2,3,4,5,6,7,8,9,10'
CREATE PROCEDURE [dbo].[qa_searchMembers] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@member varchar(200), 
	@provider varchar(200),
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
		
	DECLARE @SQL VARCHAR(MAX)	
	SET @SQL = '
	SELECT TOP 500 
			S.Suspect_PK,M.Member_PK,M.Member_ID,M.Lastname+ISNULL('', ''+M.Firstname,'''') Member_Name, M.DOB
			,CASE WHEN Scanned_User_PK IS NULL THEN 0 ELSE 1 END Scanned
			,Coded_Date, U.Lastname+'', ''+U.Firstname Coded_User
			,QA_Date, QA.Lastname+'', ''+QA.Firstname QA_User
			,PM.Provider_ID,PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Provider_Name			
			,P.Project_PK,P.Project_Name
		FROM tblMember M WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProject P WITH (NOLOCK) ON S.Project_PK = P.Project_PK
			INNER JOIN tblProvider PP WITH (NOLOCK) ON PP.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PP.ProviderMaster_PK = PM.ProviderMaster_PK
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.Coded_User_PK
			LEFT JOIN tblUser QA WITH (NOLOCK) ON QA.User_PK = S.QA_User_PK
		WHERE S.IsCoded=1 '
	
	IF @member<>''
	BEGIN
		SET @SQL = @SQL + ' AND M.Member_ID+'' ''+M.Lastname+ISNULL('', ''+M.Firstname,'''') Like ''%'+@member+'%''';
	END
	IF @provider<>''
	BEGIN
		SET @SQL = @SQL + ' AND PM.Provider_ID+'' ''+PM.Lastname+ISNULL('', ''+PM.Firstname,'''') Like ''%'+@provider+'%''';
	END
		
	SET @SQL = @SQL + ' ORDER BY NEWID()'
	
	--PRINT @SQL;
	EXEC (@SQL);
END
GO
