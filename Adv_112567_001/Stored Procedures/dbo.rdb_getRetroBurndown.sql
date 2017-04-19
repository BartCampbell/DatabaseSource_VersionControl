SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getRetroBurndown 0,1,1 
*/
CREATE PROCEDURE [dbo].[rdb_getRetroBurndown]
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
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,Sch_Date DateTime)
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmp
	SELECT DISTINCT 0 Project_PK,S.Provider_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)) Sch_Date	
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN tblChaseStatus CS ON CS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK --AND S.Project_PK = PO.Project_PK
	WHERE (CS.IsScheduled=1 OR S.Scanned_Date IS NOT NULL)
	GROUP BY S.Provider_PK --S.Project_PK,
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK)

	--Print '--BURN DOWN'
	SELECT DYear,DWeek,MAX(Scheduled) Scheduled, MAX(Extracted) Extracted, MAX(Coded) Coded,MAX(ScheduledGoal) ScheduledGoal, MAX(ExtractedGoal) ExtractedGoal, MAX(CodedGoal) CodedGoal,MAX(CAST(Dt AS DATE)) Dt FROM (
		SELECT Year(T.Sch_Date) DYear,DATEPART(WK,T.Sch_Date) DWeek,COUNT(DISTINCT S.Suspect_PK) Scheduled, NULL Extracted, NULL Coded, MAX(T.Sch_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN #tmp T ON S.Provider_PK = T.Provider_PK	--S.Project_PK = T.Project_PK AND 
		WHERE T.Sch_Date IS NOT NULL
		GROUP BY Year(T.Sch_Date),DATEPART(WK,T.Sch_Date)
		UNION
		SELECT Year(Scanned_Date) DYear,DATEPART(WK,Scanned_Date) DWeek,NULL Scheduled, COUNT(DISTINCT S.Suspect_PK) Extracted, NULL Coded, MAX(Scanned_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN #tmp T ON S.Provider_PK = T.Provider_PK --S.Project_PK = T.Project_PK AND 
		WHERE Scanned_Date IS NOT NULL
		GROUP BY Year(Scanned_Date),DATEPART(WK,Scanned_Date)
		UNION
		SELECT Year(Coded_Date) DYear,DATEPART(WK,Coded_Date) DWeek,NULL Scheduled, NULL Extracted, COUNT(DISTINCT S.Suspect_PK) Coded, MAX(Coded_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN #tmp T ON S.Provider_PK = T.Provider_PK -- S.Project_PK = T.Project_PK AND 
		WHERE Coded_Date IS NOT NULL
		GROUP BY Year(Coded_Date),DATEPART(WK,Coded_Date)
		UNION
		SELECT Year(dtGoal) DYear,DATEPART(WK,dtGoal) DWeek,NULL Scheduled, NULL Extracted, NULL Coded, MAX(dtGoal) Dt
			,SUM(CASE WHEN M.MilestoneType_PK=1 THEN GOAL ELSE 0 END) ScheduledGoal
			,SUM(CASE WHEN M.MilestoneType_PK=2 THEN GOAL ELSE 0 END) ExtractedGoal
			,SUM(CASE WHEN M.MilestoneType_PK=3 THEN GOAL ELSE 0 END) CodedGoal
		FROM tblMilestone M WITH (NOLOCK) 
			INNER JOIN tblMilestoneDetail D WITH (NOLOCK) ON M.Milestone_PK = D.Milestone_PK
			INNER JOIN #tmpProject P ON P.Project_PK = M.Project_PK	
		GROUP BY Year(dtGoal),DATEPART(WK,dtGoal)		
	) T GROUP BY DYear,DWeek ORDER BY DYear,DWeek

--PRINT 'COUNT'
	SELECT COUNT(SUSPECT_PK) FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
--PRINT 'DONE'
END
GO
