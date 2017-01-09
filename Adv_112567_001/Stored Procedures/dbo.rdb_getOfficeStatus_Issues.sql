SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions 
rdb_getOfficeStatus_Issues 0,1,0,0 
*/ 
CREATE PROCEDURE [dbo].[rdb_getOfficeStatus_Issues] 
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
 
	--Office Status 
	CREATE TABLE #tmpOffice(ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK INT NOT NULL,ProviderOfficeBucket_PK TinyInt NOT NULL) ON [PRIMARY]	 
	CREATE INDEX idxIOProviderOffice_PK ON #tmpOffice (ProviderOffice_PK) 
	CREATE INDEX idxIOContactNote_PK ON #tmpOffice (ContactNote_PK) 
 
	Insert Into #tmpOffice 
	SELECT DISTINCT PO.ProviderOffice_PK,0 ContactNote_PK,PO.ProviderOfficeBucket_PK  
	FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK 
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK 
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK 
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK 
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK 
 
	Update T SET ContactNote_PK = CNO.ContactNote_PK FROM #tmpOffice T  
		INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON T.ProviderOffice_PK = CNO.Office_PK 
		INNER JOIN tblContactNote CN ON CN.ContactNote_PK = CNO.ContactNote_PK AND CN.IsIssue=1 
		 
	SELECT Bucket [Status],COUNT(DISTINCT O.ProviderOffice_PK) [Count],POB.ProviderOfficeBucket_PK 
		FROM #tmpOffice O WITH (NOLOCK) 
			INNER JOIN tblProviderOfficeBucket POB ON POB.ProviderOfficeBucket_PK = O.ProviderOfficeBucket_PK 
		WHERE POB.ProviderOfficeBucket_PK IN (0,1,2,3)  
		GROUP BY Bucket,POB.ProviderOfficeBucket_PK,POB.SortOrder 
		ORDER BY POB.SortOrder 
 
	SELECT Bucket [Status],COUNT(DISTINCT O.ProviderOffice_PK) [Count],POB.ProviderOfficeBucket_PK 
		FROM #tmpOffice O WITH (NOLOCK) 
			INNER JOIN tblProviderOfficeBucket POB ON POB.ProviderOfficeBucket_PK = O.ProviderOfficeBucket_PK 
		WHERE POB.ProviderOfficeBucket_PK IN (7,8,10,2) 
		GROUP BY Bucket,POB.ProviderOfficeBucket_PK,POB.SortOrder 
		ORDER BY POB.SortOrder 
 
	SELECT ContactNote_Text,COUNT(DISTINCT T.ProviderOffice_PK) Offices,CN.ContactNote_PK  
	FROM #tmpOffice T  
		INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = T.ContactNote_PK  
		WHERE ProviderOfficeBucket_PK IN (7)  
		GROUP BY CN.ContactNote_PK,ContactNote_Text ORDER BY COUNT(DISTINCT T.ProviderOffice_PK) DESC 
END 
GO
