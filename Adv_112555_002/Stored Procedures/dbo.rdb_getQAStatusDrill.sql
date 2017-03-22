SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getQAStatusDrill @Channel='0',	@Projects='0',	@ProjectGroup ='0',	@Status1 ='0',	@Status2 ='0',	@User =1,	@DrillType =1,	@Export =0
*/
CREATE PROCEDURE [dbo].[rdb_getQAStatusDrill]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@User int,
	@DrillType int,
	@Export int
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	CREATE TABLE #tmpChaseStatus (ChaseStatus_PK INT, ChaseStatusGroup_PK INT)
	CREATE INDEX idxChaseStatusPK ON #tmpChaseStatus (ChaseStatus_PK)

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
	INSERT INTO #tmpChaseStatus(ChaseStatus_PK,ChaseStatusGroup_PK) SELECT DISTINCT ChaseStatus_PK,ChaseStatusGroup_PK FROM tblChaseStatus

	

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		EXEC ('DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK NOT IN ('+@ProjectGroup+')')
		
	IF (@Channel<>'0')
		EXEC ('DELETE T FROM #tmpChannel T WHERE Channel_PK NOT IN ('+@Channel+')')	
		
	IF (@Status1<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatusGroup_PK NOT IN ('+@Status1+')')	
		
	IF (@Status2<>'0')
		EXEC ('DELETE T FROM #tmpChaseStatus T WHERE ChaseStatus_PK NOT IN ('+@Status2+')')						 
	-- PROJECT/Channel SELECTION


	;With tbl AS(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY M.Lastname ASC) AS [#],
			S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,
			PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
			S.Scanned_Date Extracted,
			CD.Coded_Date Coded,
			CD.DOS_Thru DOS,
			CD.DiagnosisCode [Diag Code],
			QA.dtInsert [QA],
			CASE 
				WHEN IsConfirmed=1 THEN 'Confirmed'
				WHEN IsChanged=1 THEN 'Changed'
				WHEN IsAdded=1 THEN 'Added'
				WHEN IsRemoved=1 THEN 'Removed'
			END [QA Response],
			U_CD.Lastname+', '+U_CD.Firstname [Coded By],
			U_QA.Lastname+', '+U_QA.Firstname [QAed By]
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblCodedData CD WITH (NOLOCK) ON S.Suspect_PK = CD.Suspect_PK
			LEFT JOIN tblUser U_CD WITH (NOLOCK) ON U_CD.User_PK = CD.Coded_User_PK
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON CD.CodedData_PK = QA.CodedData_PK
			LEFT JOIN tblUser U_QA WITH (NOLOCK) ON U_QA.User_PK = QA.QA_User_PK
			WHERE (
				(@DrillType=0) --Total Coded Diagnosis
				OR (@DrillType=1 AND QA.CodedData_PK IS NOT NULL) --QA Sample
				OR (@DrillType=2 AND IsConfirmed=1) --Confirmed 
				OR (@DrillType=3 AND IsChanged=1) --Changed 
				OR (@DrillType=4 AND IsAdded=1) --Added 
				OR (@DrillType=5 AND IsRemoved=1) --Removed 
			) 
	)
	SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]
	/*
	IF (SELECT COUNT(*) FROM #tmpProject)>1
		SELECT '';
	ELSE
		SELECT P.Project_Name FROM tblProject P INNER JOIN #tmpProject tP ON tP.Project_PK=P.Project_PK
	*/
END
GO
