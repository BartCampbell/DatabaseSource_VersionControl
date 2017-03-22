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

	--Overall Progress
	SELECT IsNULL(S.ChartPriority,'X') ChartPriority, COUNT(*) Chases
		,SUM(CS.IsNotContacted + CS.IsSchedulingInProgress) NotScheduled 
		,SUM(CS.IsScheduled) Scheduled
		,SUM(CS.IsExtracted) Extracted
		,SUM(CS.IsCNA) CNA
		,SUM(CS.IsCoded) Coded
	INTO #tmpX
	FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
		INNER JOIN tblChaseStatus CS ON CS.ChaseStatus_PK = S.ChaseStatus_PK
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
