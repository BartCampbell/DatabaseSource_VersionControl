SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--UPDAtE tblProviderOffice SET AssignedUser_PK=NULL, AssignedDate=NULL wHERE AssignedUser_PK IS NOT NULL
--SELECT * FROM tblProviderOffice wHERE AssignedUser_PK IS NOT NULL ORDER BY AssignedDate DESC
--SELECT * FRom cacheProviderOffice WHERE ProviderOffice_PK IN (1,107)
--sELEcT * from tblPool
--SELECT * FROM cacheProviderOffice cPO WHERE cPO.charts-cPO.extracted_count-cPO.cna_count>0
--	sch_getNext 1
CREATE PROCEDURE [dbo].[sch_getNext] 
	@user smallint
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@user
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@user
	END
	-- PROJECT/Channel SELECTION

	--Getting List of Assigned Pools
	SELECT DISTINCT P.Pool_PK,P.Pool_Priority,0 UnassignedOffices,P.PriorityWithinPool INTO #tmpPool
		FROM tblPool P WITH (NOLOCK) 
			INNER JOIN tblSchedulerTeam ST WITH (NOLOCK) ON P.SchedulerTeam_PK = ST.SchedulerTeam_PK	
			INNER JOIN tblSchedulerTeamDetail STD WITH (NOLOCK) ON STD.SchedulerTeam_PK = ST.SchedulerTeam_PK
		WHERE STD.Scheduler_User_PK = @user
		Order By Pool_Priority ASC

	CREATE INDEX idxPoolPK ON #tmpPool (Pool_PK)

	SELECT P.ProviderOffice_PK,PO.Pool_PK
		,CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END ProviderOfficeBucket_PK
		,MIN(S.FollowUp) FollowUpDate, SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END) RemainingCharts
	INTO #EligibleOffices
	FROM tblProviderOffice PO WITH (NOLOCK)
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
	WHERE PO.Pool_PK IS NOT NULL AND PO.AssignedUser_PK IS NULL
	GROUP BY P.ProviderOffice_PK,PO.Pool_PK		
	CREATE INDEX idxElgProviderOffice_PK ON #EligibleOffices (ProviderOffice_PK)

	--Setting Remaining Offices for Each Pool
	Update P SET UnassignedOffices = Offices
		FROM #tmpPool P
			Outer Apply (					
					SELECT COUNT(DISTINCT EO.ProviderOffice_PK) Offices 
					FROM #EligibleOffices EO
					WHERE EO.Pool_PK=P.Pool_PK AND EO.ProviderOfficeBucket_PK NOT IN (5,6) AND (FollowUpDate IS NULL OR FollowUpDate<=GetDate()) 	
			) X

	DELETE FROM #tmpPool WHERE UnassignedOffices=0

	IF NOT EXISTS (SELECT * FROM #tmpPool)
	BEGIN
		SELECT top 0 * FROM #tmpPool
		Return ;
	END

	DELETE FROM #tmpPool WHERE Pool_Priority<>(SELECT TOP 1 Pool_Priority FROM #tmpPool ORDER BY Pool_Priority ASC)

	DECLARE @ProviderOffice_PK AS BIGINT
	IF (SELECT TOP 1 PriorityWithinPool FROM #tmpPool)=0
	BEGIN	--WHEN Priority Within Pool is Older Follow up date
		SELECT TOP 1 @ProviderOffice_PK=EO.ProviderOffice_PK
			FROM #tmpPool P
				INNER JOIN #EligibleOffices EO WITH (NOLOCK) ON EO.Pool_PK=P.Pool_PK
		WHERE EO.ProviderOfficeBucket_PK NOT IN (5,6) AND (FollowUpDate IS NULL OR FollowUpDate<=GetDate()) 
		ORDER BY IsNull(FollowUpDate,'2014-1-1') ASC
	END
	ELSE ----WHEN Priority Within Pool is higher number of remaining charts
	BEGIN
		SELECT TOP 1 @ProviderOffice_PK=EO.ProviderOffice_PK
			FROM #tmpPool P
				INNER JOIN #EligibleOffices EO WITH (NOLOCK) ON EO.Pool_PK=P.Pool_PK
		WHERE EO.ProviderOfficeBucket_PK NOT IN (5,6) AND (FollowUpDate IS NULL OR FollowUpDate<=GetDate()) 
		ORDER BY RemainingCharts DESC				
	END
	DROP TABLE #EligibleOffices

	IF (@ProviderOffice_PK IS NULL)
	BEGIN
		SELECT TOP 0 * FROM #tmpPool
		Return ;		
	END

	UPDATE tblProviderOffice SET AssignedUser_PK=@user,AssignedDate=GetDate() WHERE ProviderOffice_PK=@ProviderOffice_PK

	EXEC sch_getOffice @channel=0, @Projects='0', @ProjectGroup='0', @Page=1, @PageSize=1, @Alpha='', @Sort='', @Order='', @bucket=-1, @sub_bucket=0, @user=@user, @scheduler=0, @PoolPK=0, @ZonePK=0, @OFFICE=@ProviderOffice_PK,@search_type=0,@search_value=''
END
GO
