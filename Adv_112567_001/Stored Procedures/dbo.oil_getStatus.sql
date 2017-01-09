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
--	oil_getStatus 0,0,0,0,0,1 
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
		 
	--SELECT POS.OfficeIssueStatus [status], COUNT(DISTINCT POS.ProviderOffice_PK) Cnt 
	SELECT POS.OfficeIssueStatus,POS.ProviderOffice_PK INTO #tbl 
			FROM tblProviderOffice PO WITH (NOLOCK)  
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
				INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
				INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
				INNER JOIN tblProviderOfficeStatus POS ON POS.ProviderOffice_PK = PO.ProviderOffice_PK 
				--LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	 
	GROUP BY POS.OfficeIssueStatus,POS.ProviderOffice_PK 
	Having COUNT(DISTINCT CASE WHEN S.IsCNA=0 AND S.IsScanned=0 THEN S.Suspect_PK ELSE NULL END)>0 
 
	SELECT OfficeIssueStatus [status], COUNT(DISTINCT ProviderOffice_PK) Cnt 
	FROM #tbl 
	WHERE OfficeIssueStatus NOT IN (3,5) 
	GROUP BY OfficeIssueStatus 
END 
GO
