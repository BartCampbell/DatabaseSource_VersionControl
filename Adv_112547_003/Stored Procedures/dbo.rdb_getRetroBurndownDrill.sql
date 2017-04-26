SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getRetroBurndownDrill 0,1,'0',1,'08/26/2015',0
*/
CREATE PROCEDURE [dbo].[rdb_getRetroBurndownDrill]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@User int,
	@DrillType int,
	@Dt date, 
	@Export int
AS
BEGIN
	SET @Dt = DateAdd(day,1,@Dt);
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
	CREATE TABLE #tmp(Suspect_PK [bigint] NOT NULL primary key,Sch_Date date)
	INSERT INTO #tmp
	SELECT DISTINCT S.Suspect_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)) Sch_Date--, MIN(PO.sch_type)
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE (PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL)
	GROUP BY S.Suspect_PK;

	--Overall Progress for All Projects
	/*
	IF (SELECT COUNT(*) FROM #tmpProject)>1
	BEGIN
		SELECT 
			S.Project_PK,Pr.Project_Name Project,
			COUNT(CASE WHEN IsNull(T.Sch_Date,S.Scanned_Date) IS NOT NULL THEN S.Suspect_PK ELSE NULL END) Scheduled,
			COUNT(CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Extracted,
			COUNT(CASE WHEN S.IsScanned=0 AND S.IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA,
			COUNT(CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) Coded
		FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
			LEFT JOIN #tmp T ON T.Suspect_PK = S.Suspect_PK
				WHERE ( 
					(@DrillType=1 AND IsNull(IsNull(T.Sch_Date,S.Scanned_Date),S.CNA_Date)<@Dt)
					OR (@DrillType=2 AND S.Scanned_Date<@Dt)
					OR (@DrillType=3 AND S.Coded_Date<@Dt)
					)
		GROUP BY S.Project_PK,Pr.Project_Name
		ORDER BY Pr.Project_Name
	END
	ELSE
	BEGIN	
	*/
		With tbl AS(
			SELECT 
				ROW_NUMBER() OVER(ORDER BY M.Lastname ASC) AS [#],
				S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,
				PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
				PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State,
				T.Sch_Date Scheduled,
				S.Scanned_Date Extracted,
				CASE WHEN S.Scanned_Date IS NULL THEN S.CNA_Date ELSE NULL END CNA,
				Coded_Date Coded
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN #tmp T ON T.Suspect_PK = S.Suspect_PK
				WHERE (
					(@DrillType=1 AND IsNull(T.Sch_Date,S.Scanned_Date)<@Dt)
					OR (@DrillType=2 AND S.Scanned_Date<@Dt)
					OR (@DrillType=3 AND S.Coded_Date<@Dt)
					OR (@DrillType=4 AND S.CNA_Date<@Dt)
					)
		)
		SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]

	--	SELECT P.Project_Name FROM tblProject P INNER JOIN #tmpProject tP ON tP.Project_PK=P.Project_PK
	--END
END
GO
