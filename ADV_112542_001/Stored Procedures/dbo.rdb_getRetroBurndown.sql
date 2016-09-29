SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getRetroBurndown 0,1,1
*/
CREATE PROCEDURE [dbo].[rdb_getRetroBurndown]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Channel int
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

	--Schedule Info
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,Sch_Date DateTime)
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,S.Provider_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)) Sch_Date	
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE (PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL) AND (@Channel=0 OR S.Channel_PK=@Channel)
	GROUP BY S.Project_PK,S.Provider_PK
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK)

	--Print '--BURN DOWN'
	SELECT DYear,DWeek,MAX(Scheduled) Scheduled, MAX(Extracted) Extracted, MAX(Coded) Coded,MAX(ScheduledGoal) ScheduledGoal, MAX(ExtractedGoal) ExtractedGoal, MAX(CodedGoal) CodedGoal,MAX(CAST(Dt AS DATE)) Dt FROM (
		SELECT Year(T.Sch_Date) DYear,DATEPART(WK,T.Sch_Date) DWeek,COUNT(DISTINCT S.Suspect_PK) Scheduled, NULL Extracted, NULL Coded, MAX(T.Sch_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK	
		WHERE T.Sch_Date IS NOT NULL AND (@Channel=0 OR S.Channel_PK=@Channel)
		GROUP BY Year(T.Sch_Date),DATEPART(WK,T.Sch_Date)
		UNION
		SELECT Year(Scanned_Date) DYear,DATEPART(WK,Scanned_Date) DWeek,NULL Scheduled, COUNT(DISTINCT S.Suspect_PK) Extracted, NULL Coded, MAX(Scanned_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		WHERE Scanned_Date IS NOT NULL AND (@Channel=0 OR S.Channel_PK=@Channel)
		GROUP BY Year(Scanned_Date),DATEPART(WK,Scanned_Date)
		UNION
		SELECT Year(Coded_Date) DYear,DATEPART(WK,Coded_Date) DWeek,NULL Scheduled, NULL Extracted, COUNT(DISTINCT S.Suspect_PK) Coded, MAX(Coded_Date) Dt,NULL ScheduledGoal, NULL ExtractedGoal, NULL CodedGoal
		FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		WHERE Coded_Date IS NOT NULL AND (@Channel=0 OR S.Channel_PK=@Channel)
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
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
	WHERE (@Channel=0 OR S.Channel_PK=@Channel)
--PRINT 'DONE'
END
GO
