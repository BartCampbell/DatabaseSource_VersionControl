SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getRetroProgressDrill '0','0','0','0','0',1,0,'',1
*/
Create PROCEDURE [dbo].[rdb_getRetroProgressDrill]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@User int,
	@DrillType int,
	@Priority varchar(10),
	@Export int
AS
BEGIN
	Declare @Sch_Type AS INT = 99
/*
	if (@DrillType>=10)
	BEGIN
		SET @Sch_Type = @DrillType-10
		SET @DrillType = 1
	END
*/
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
/*
	--Schedule Info
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,Sch_Date DateTime,schedule_type tinyint)
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,S.Provider_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)),IsNull(MIN(PO.sch_type),1)
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK --AND S.Project_PK = PO.Project_PK
	WHERE PO.ProviderOffice_PK IS NOT NULL
	GROUP BY S.Project_PK,S.Provider_PK
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK)
*/
	DECLARE @Records AS INT = 25
	IF (@Export=1)
		SET @Records = 10000000

	SELECT TOP (@Records)
		C.Channel_Name Project,PR.Project_Name LOB,
		S.ChaseID,M.Member_ID,M.HICNumber,M.Lastname+IsNull(', '+M.Firstname,'') Member,
		PM.Provider_ID [Centauri Provider ID],PM.PIN [Plan Provider ID], PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.ProviderGroup [Group Name],
		PO.LocationID [Centauri Location ID],S.PlanLID [Plan Location ID],PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State,
		S.Scanned_Date Extracted,
		CASE WHEN S.Scanned_Date IS NULL THEN S.CNA_Date ELSE NULL END CNA,
		Coded_Date Coded,
		S.ChartPriority [Chart Priority],CS.ChaseStatus ChaseStatus,CS.ChartResolutionCode [Chase Resolution Code],S.REN_PROVIDER_SPECIALTY [Provider Specialty]
	INTO #Output
	FROM tblSuspect S WITH (NOLOCK) 
		INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN tblProject PR WITH (NOLOCK) ON PR.Project_PK = S.Project_PK
		INNER JOIN tblChannel C WITH (NOLOCK) ON C.Channel_PK = S.Channel_PK
--		LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		LEFT JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
		LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
		WHERE (
				(@DrillType=0)
			OR (@DrillType=1 AND (CS.IsNotContacted=1 OR CS.IsSchedulingInProgress=1))					--S.IsScanned=0 AND S.IsCNA=0 AND T.Provider_PK IS NULL)						--Not Yet Scheduled = total number of charts in offices not yet contacted (this number will initially be high but then will go down as the number of charts scheduled goes up)
			OR (@DrillType=2 AND CS.IsScheduled=1)														--S.IsScanned=0 AND S.IsCNA=0 AND T.Provider_PK IS NOT NULL)					--Scheduled for Extraction = total number of charts in offices that have been scheduled, but not yet extracted (this number will go down as the number of charts extracted goes up)
			OR (@DrillType=3 AND CS.IsExtracted=1)														--S.IsScanned=1 AND S.IsCoded=0)												--Extracted Not Yet Coded [with option to hide the words “not yet coded” if we’re not coding for that project] = total number of charts extracted by Scan Techs (this number will go down as the number of charts coded goes up) but not yet coded OR just the number of charts extracted by Scan Techs if we are not coding
			OR (@DrillType=4 AND CS.IsCNA=1)															--S.IsCNA=1 AND S.IsScanned=0)												--CNA = total number of charts not available
			OR (@DrillType=5 AND CS.IsCoded=1)															--S.IsCoded=1 AND S.IsScanned=1)												--Coded = total number of charts coded
			OR (@DrillType=101 AND (CS.IsScheduled=1 OR CS.IsExtracted=1 OR CS.IsCNA=1 OR CS.IsCoded=1))	--(T.Sch_Date IS NOT NULL OR S.IsScanned=1 OR S.IsCNA=1 OR S.IsCoded=1))	--In Progress = CNA + Scheduled for Extraction + Extracted Not Yet Coded + Coded
			OR (@DrillType=102 AND (CS.IsExtracted=1 OR CS.IsCNA=1 OR CS.IsCoded=1))						--(S.IsScanned=1 OR S.IsCNA=1 OR S.IsCoded=1))								--Outreach Complete = CNA + Extracted Not Yet Coded + Coded
			OR (@DrillType=103 AND (CS.IsExtracted=1 OR CS.IsCoded=1))									--(S.IsScanned=1 OR S.IsCoded=1))											--Charts Extracted = Extracted Not Yet Coded + Coded
			OR (@DrillType=104 AND CS.IsCoded=1)														--(S.IsCoded=1))															--Coded = coded
		) 
		AND (@Priority='' OR S.ChartPriority=@Priority)
		--AND (@Sch_Type=99 OR T.schedule_type=@Sch_Type)

	IF (@Export=0)
		SELECT * FROM #Output
	ELSE
	BEGIN
		SELECT 'Summary' Project,0 SOrder UNION SELECT DISTINCT Project,1 SOrder FROM #Output ORDER BY SOrder,Project 

		SELECT Project,LOB,State,COUNT(*) Chases
			--,SUM(CASE WHEN Extracted IS NULL AND CNA IS NULL AND Scheduled IS NULL				THEN 1 ELSE 0 END) NotScheduled 
			--,SUM(CASE WHEN Extracted IS NULL AND CNA IS NULL AND Scheduled IS NOT NULL			THEN 1 ELSE 0 END) Scheduled
			,SUM(CASE WHEN Extracted IS NOT NULL AND Coded IS NULL								THEN 1 ELSE 0 END) Extracted
			,SUM(CASE WHEN Extracted IS NULL AND CNA IS NOT NULL								THEN 1 ELSE 0 END) CNA
			,SUM(CASE WHEN Coded IS NOT NULL AND Extracted IS NOT NULL							THEN 1 ELSE 0 END) Coded
		FROM #Output
		GROUP BY Project,LOB,State
		ORDER BY Project,LOB,State

		DECLARE @ProjectChannel VARCHAR(200)
		DECLARE db_cursor CURSOR FOR  
			SELECT DISTINCT Project FROM #Output ORDER BY Project  

		OPEN db_cursor   
		FETCH NEXT FROM db_cursor INTO @ProjectChannel   

		WHILE @@FETCH_STATUS = 0   
		BEGIN   
			   SELECT * FROM #Output WHERE Project=@ProjectChannel

			   FETCH NEXT FROM db_cursor INTO @ProjectChannel   
		END   

		CLOSE db_cursor   
		DEALLOCATE db_cursor
	END
END
GO
