SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	mlcr_getReport 0,0,3,1,1,5
CREATE PROCEDURE [dbo].[mlcr_getReport] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@View int,
	@Filter int,
	@User int,
	@CodingLevel smallint,
	@allLevelCompleted tinyint
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION
	
	CREATE TABLE #tmpSuspect (Suspect_PK BigINT,Member_PK BigINT)
	CREATE INDEX idxSuspectPK ON #tmpSuspect (Suspect_PK)

	INSERT INTO #tmpSuspect (Suspect_PK,Member_PK)
	SELECT S.Suspect_PK,S.Member_PK FROM tblSuspectLevelCoded SLC WITH (NOLOCK)
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = SLC.Suspect_PK
		INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
	GROUP BY S.Suspect_PK,S.Member_PK
	--To include chases where all levels are completed
	HAVING COUNT(1)=@CodingLevel OR @allLevelCompleted=0
	
	CREATE TABLE #tmpMemberCoding (Member_PK BigINT,Code Varchar(10),Levels tinyint,Level1 tinyint,Level2 tinyint,Level3 tinyint,Level4 tinyint,Level5 tinyint)
	CREATE INDEX idxMemberPK ON #tmpMemberCoding (Member_PK)
	
	IF @View IN (1,3) --HCC
	BEGIN
		INSERT INTO #tmpMemberCoding (Member_PK,Code,Levels,Level1,Level2,Level3,Level4,Level5)
		SELECT S.Member_PK,MC.V22HCC,COUNT(DISTINCT CD.CoderLevel) Levels
			,MAX(CASE WHEN CD.CoderLevel=1 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=2 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=3 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=4 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=5 THEN 1 ELSE 0 END)
		FROM tblCodedData CD WITH (NOLOCK) INNER JOIN #tmpSuspect S ON S.Suspect_PK = CD.Suspect_PK INNER JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode
		WHERE IsNull(CD.Is_Deleted,0)=0
		GROUP BY S.Member_PK,MC.V22HCC
	END
	ELSE IF @View IN (2,4) --Diagnosis
	BEGIN
		INSERT INTO #tmpMemberCoding (Member_PK,Code,Levels,Level1,Level2,Level3,Level4,Level5)
		SELECT S.Member_PK,CD.DiagnosisCode,COUNT(DISTINCT CD.CoderLevel) Levels
			,MAX(CASE WHEN CD.CoderLevel=1 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=2 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=3 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=4 THEN 1 ELSE 0 END)
			,MAX(CASE WHEN CD.CoderLevel=5 THEN 1 ELSE 0 END)
		FROM tblCodedData CD WITH (NOLOCK) INNER JOIN #tmpSuspect S ON S.Suspect_PK = CD.Suspect_PK
		WHERE IsNull(CD.Is_Deleted,0)=0
		GROUP BY S.Member_PK,CD.DiagnosisCode
	END

	IF @Filter=1 --Only Discrepancies
	BEGIN
		--Removing all where all level varified
		DELETE #tmpMemberCoding WHERE Levels=@CodingLevel
	END
	ELSE IF @Filter=2 --No Discrepancies
	BEGIN
		--Removing all where all level not varified
		DELETE #tmpMemberCoding WHERE Levels<@CodingLevel
	END

	IF @View = 1 --HCC Score
	BEGIN
		SELECT M.Member_ID [Member ID],M.Lastname+IsNull(', '+M.Firstname,'') [Member Name]
			,SUM(CASE WHEN Levels=1 THEN 1 ELSE 0 END) [HCCs Coded By 1 Level]
			,SUM(CASE WHEN Levels=2 THEN 1 ELSE 0 END) [HCCs Coded By 2 Levels]
			,SUM(CASE WHEN Levels=3 THEN 1 ELSE 0 END) [HCCs Coded By 3 Levels]
			,SUM(CASE WHEN Levels=4 THEN 1 ELSE 0 END) [HCCs Coded By 4 Levels]
			,SUM(CASE WHEN Levels=5 THEN 1 ELSE 0 END) [HCCs Coded By 5 Levels]
		FROM #tmpMemberCoding SC 
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = SC.Member_PK
		GROUP BY M.Member_ID, M.Lastname, M.Firstname
		ORDER BY [Member Name]
	END
	ELSE IF @View = 2 --Diagnosis Score
	BEGIN
		SELECT M.Member_ID [Member ID],M.Lastname+IsNull(', '+M.Firstname,'') [Member Name]
			,SUM(CASE WHEN Levels=1 THEN 1 ELSE 0 END) [Diagnosis' Coded By 1 Level]
			,SUM(CASE WHEN Levels=2 THEN 1 ELSE 0 END) [Diagnosis' Coded By 2 Levels]
			,SUM(CASE WHEN Levels=3 THEN 1 ELSE 0 END) [Diagnosis' Coded By 3 Levels]
			,SUM(CASE WHEN Levels=4 THEN 1 ELSE 0 END) [Diagnosis' Coded By 4 Levels]
			,SUM(CASE WHEN Levels=5 THEN 1 ELSE 0 END) [Diagnosis' Coded By 5 Levels]
		FROM #tmpMemberCoding SC 
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = SC.Member_PK
		GROUP BY M.Member_ID, M.Lastname, M.Firstname
		ORDER BY [Member Name]
	END
	ELSE IF @View = 3 --HCC Report
	BEGIN
		SELECT M.Member_ID [Member ID],M.Lastname+IsNull(', '+M.Firstname,'') [Member Name]
			,Code HCC,Level1 [Level 1],Level2 [Level 2],Level3 [Level 3],Level4 [Level 4],Level5 [Level 5]
		FROM #tmpMemberCoding SC 
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = SC.Member_PK
		ORDER BY [Member Name]
	END
	ELSE IF @View = 4 --Diagnosis Report
	BEGIN
		SELECT M.Member_ID [Member ID],M.Lastname+IsNull(', '+M.Firstname,'') [Member Name]
			,Code Diagnosis,Level1 [Level 1],Level2 [Level 2],Level3 [Level 3],Level4 [Level 4],Level5 [Level 5]
		FROM #tmpMemberCoding SC 
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = SC.Member_PK
		ORDER BY [Member Name]
	END
END
GO
