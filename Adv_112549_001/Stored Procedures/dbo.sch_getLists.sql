SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_getLists 1,1,1,1
CREATE PROCEDURE [dbo].[sch_getLists] 
	@user smallint,
	@isScheduler bit,
	@isSchedulerSV bit,
	@isSchedulerManager bit
AS
BEGIN
	--Office Contact Notes
	SELECT ContactNote_PK,ContactNote_Text,sortOrder,IsIssue,IsCopyCenter,IsCNA,IsFollowup,Followup_days 
		FROM tblContactNote WITH (NOLOCK) 
		WHERE IsSystem=0 AND IsRetro=1 AND IsActive=1 
		ORDER BY sortOrder;

	--Incomplete Chart Notes
    SELECT * FROM tblIncompleteNote 
		WHERE IncompleteNote_PK<>1 AND IsSchedulerNote=1 
		ORDER BY IncompleteNote

	--Users
	--Locations
	--Pools
	IF (@isSchedulerSV=1 AND @isSchedulerManager=0) --For Supervisors
	BEGIN
		--List of Supervisor's Team of Scheduler
		SELECT DISTINCT U.Lastname+', '+U.Firstname Scheduler,U.User_PK,U.Location_PK 
			FROM tblSchedulerTeam ST WITH (NOLOCK) 
				INNER JOIN tblSchedulerTeamDetail STD WITH (NOLOCK) ON STD.SchedulerTeam_PK = ST.SchedulerTeam_PK
				INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = STD.Scheduler_User_PK
			WHERE IsNull(IsActive,0)=1 AND IsScheduler=1 
				AND ST.Supervisor_User_PK = @user
			ORDER BY U.Lastname+', '+U.Firstname;	

		--List of Locations for Supervisor's Team of Scheduler
		SELECT DISTINCT L.Location_PK, L.Location
			FROM tblSchedulerTeam ST WITH (NOLOCK) 
				INNER JOIN tblSchedulerTeamDetail STD WITH (NOLOCK) ON STD.SchedulerTeam_PK = ST.SchedulerTeam_PK
				INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = STD.Scheduler_User_PK
				INNER JOIN tblLocation L WITH (NOLOCK) ON L.Location_PK = U.Location_PK
			WHERE IsNull(IsActive,0)=1 AND IsScheduler=1 
				AND ST.Supervisor_User_PK = @user
			ORDER BY L.Location
			
		--List of Pool for Supervisor
		SELECT DISTINCT P.Pool_PK,P.Pool_Name
			FROM tblSchedulerTeam ST WITH (NOLOCK) 
				INNER JOIN tblPool P WITH (NOLOCK) ON P.SchedulerTeam_PK = ST.SchedulerTeam_PK
			WHERE ST.Supervisor_User_PK = @user
			ORDER BY P.Pool_Name

		--List of Status Buckets
		SELECT ProviderOfficeBucket_PK,Bucket FROM tblProviderOfficeBucket ORDER BY sortOrder
	END
	ELSE	--For Managers and Schedulers
	BEGIN
		--List of all Scheduler for Manager and If not Manager only one scheduler 
		SELECT DISTINCT Lastname+', '+Firstname Scheduler,User_PK,Location_PK 
			FROM tblUser WITH (NOLOCK) 
			WHERE IsNull(IsActive,0)=1 AND IsScheduler=1 
				AND (@isSchedulerManager=1 OR User_PK = @user)
			ORDER BY Lastname+', '+Firstname;

		--List of all locations for Manager only
		SELECT DISTINCT L.Location_PK, L.Location FROM tblLocation L WHERE @isSchedulerManager=1 Order By Location;

		--List of all pools for Manager only
		SELECT DISTINCT P.Pool_PK,P.Pool_Name
			FROM tblPool P WITH (NOLOCK)
			WHERE @isSchedulerManager=1
			ORDER BY P.Pool_Name

		--List of Status Buckets
		SELECT ProviderOfficeBucket_PK,Bucket FROM tblProviderOfficeBucket ORDER BY sortOrder
	END

	SELECT Zone_PK,Zone_Name FROM tblZone ORDER BY Zone_Name
/*
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT Project_PK FROM tblProject P WITH (NOLOCK) WHERE P.IsRetrospective=1
	ELSE
		INSERT INTO #tmpProject(Project_PK)
		SELECT DISTINCT P.Project_PK FROM tblProject P WITH (NOLOCK) LEFT JOIN tblUserProject UP WITH (NOLOCK) ON UP.Project_PK = P.Project_PK
		WHERE P.IsRetrospective=1 AND UP.User_PK=@User
	-- PROJECT SELECTION

	SELECT P.Project_PK, Project_Name, ProjectGroup_PK FROM tblProject P  WITH (NOLOCK) INNER JOIN #tmpProject T ON T.Project_PK=P.Project_PK WHERE IsRetrospective=1 ORDER BY PROJECT_NAME
		
	SELECT DISTINCT ProjectGroup,ProjectGroup_PK FROM tblProject P  WITH (NOLOCK) INNER JOIN #tmpProject T ON T.Project_PK=P.Project_PK WHERE IsRetrospective=1 ORDER BY ProjectGroup
*/
END
GO
