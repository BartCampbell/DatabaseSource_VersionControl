SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
--		1	Pending Feedback
--		2	Awaiting scheduler response
--		3	Scheduled
--		4	Removed from Chase list
-- =============================================
--	oil_getStatus 4,0,0,0,0,1
CREATE PROCEDURE [dbo].[oil_getStatus]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@user int
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
	;
	WITH Offices AS (
	SELECT PO.ProviderOffice_PK,CASE WHEN S.FollowUp IS NULL THEN 0 ELSE 1 END AwaitingScheduler 
			FROM tblProviderOffice PO WITH (NOLOCK) 
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON S.ChaseStatus_PK = CS.ChaseStatus_PK
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	WHERE CS.ProviderOfficeBucket_PK=5 AND (PO.ProviderOfficeSubBucket_PK IS NULL OR PO.ProviderOfficeSubBucket_PK<>3)
	GROUP BY PO.ProviderOffice_PK,CASE WHEN S.FollowUp IS NULL THEN 0 ELSE 1 END
	Having COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END)>0
	)
	SELECT COUNT(1) IssueOffices, 'Pending Feedback' Bucket FROM Offices WHERE AwaitingScheduler=0
	UNION
	SELECT COUNT(1) IssueOffices, 'Awaiting Scheduler' Bucket FROM Offices WHERE AwaitingScheduler=1 ORDER BY Bucket
END
GO
