SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:	Sajid Ali
-- Create date: Oct-02-2015
-- Description:	
-- =============================================
/* Sample Executions
rdb_getOfficeStatus_Issues 0,1,0
*/
CREATE PROCEDURE [dbo].[rdb_getOfficeStatus_Issues]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10)
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

	--Office Status
	CREATE TABLE #tmpOffice(ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK INT NOT NULL,ProviderOfficeBucket_PK TinyInt NOT NULL) ON [PRIMARY]	
	CREATE INDEX idxIOProviderOffice_PK ON #tmpOffice (ProviderOffice_PK)
	CREATE INDEX idxIOContactNote_PK ON #tmpOffice (ContactNote_PK)

	Insert Into #tmpOffice
	SELECT DISTINCT PO.ProviderOffice_PK,0 ContactNote_PK,PO.ProviderOfficeBucket_PK 
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
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
