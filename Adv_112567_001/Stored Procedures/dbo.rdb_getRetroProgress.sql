SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions 
rdb_getRetroProgress '0','0','0','0','0',1 
*/ 
CREATE PROCEDURE [dbo].[rdb_getRetroProgress] 
	@Channel VARCHAR(1000), 
	@Projects varchar(1000), 
	@ProjectGroup varchar(1000), 
	@Status1 varchar(1000), 
	@Status2 varchar(1000), 
	@User int 
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
 
	--Schedule Info 
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL) --,Sch_Date DateTime 
	--PRINT 'INSERT INTO #tmp' 
	INSERT INTO #tmp 
	SELECT DISTINCT S.Project_PK,S.Provider_PK 
	FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK 
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK-- AND S.Project_PK = PO.Project_PK 
	WHERE PO.ProviderOffice_PK IS NOT NULL 
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK) 
 
	--Overall Progress 
	SELECT IsNULL(S.ChartPriority,'X') ChartPriority, COUNT(*) Chases 
		,COUNT(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 AND T.Provider_PK IS NULL		THEN S.Suspect_PK ELSE NULL END) NotScheduled  
		,COUNT(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 AND T.Provider_PK IS NOT NULL	THEN S.Suspect_PK ELSE NULL END) Scheduled 
		,COUNT(CASE WHEN S.IsScanned=1 AND S.IsCoded=0								THEN S.Suspect_PK ELSE NULL END) Extracted 
		,COUNT(CASE WHEN S.IsScanned=0 AND S.IsCNA=1								THEN S.Suspect_PK ELSE NULL END) CNA 
		,COUNT(CASE WHEN S.IsCoded=1 AND S.IsScanned=1								THEN S.Suspect_PK ELSE NULL END) Coded 
	INTO #tmpX 
	FROM tblSuspect S WITH (NOLOCK)  
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK 
		LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK 
	GROUP BY S.ChartPriority --ORDER BY ChartPriority 
	UNION 
	SELECT '' ChartPriority, 0 Chases 
		,0 NotScheduled 
		,0 Scheduled 
		,0 Extracted 
		,0 CNA 
		,0 Coded 
 
	SELECT * FROM #tmpX ORDER BY CASE WHEN ChartPriority='' THEN 'ZZZZZZ' ELSE ChartPriority END 
 
	SELECT IsNULL(S.ChartPriority,'X') ChartPriority, SLC.CoderLevel, COUNT(*) Chases 
	FROM tblSuspectLevelCoded SLC WITH (NOLOCK)  
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = SLC.Suspect_PK 
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
	WHERE SLC.IsCompleted=1 
	GROUP BY S.ChartPriority, SLC.CoderLevel 
	ORDER BY S.ChartPriority 
END 
GO
