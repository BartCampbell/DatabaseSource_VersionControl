SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getOfficeStatus_Issues 0,1,0,0
*/
CREATE PROCEDURE [dbo].[rdb_getOfficeStatus_Issues]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Channel int
AS
BEGIN
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

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

	IF (@Projects<>'0')
		EXEC ('DELETE FROM #tmpProject WHERE Project_PK NOT IN ('+@Projects+')')
		
	IF (@ProjectGroup<>'0')
		DELETE T FROM #tmpProject T INNER JOIN tblProject P ON P.Project_PK = T.Project_PK WHERE ProjectGroup_PK<>@ProjectGroup
		
	IF (@Channel<>0)
		DELETE T FROM #tmpChannel T WHERE Channel_PK<>@Channel				 
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
