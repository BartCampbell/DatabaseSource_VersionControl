SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getOfficeStatus_Issues_Drill 0,1,0,0,0,1,0
*/
CREATE PROCEDURE [dbo].[rdb_getOfficeStatus_Issues_Drill]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@Status int,
	@Issue int,
	@Export int,
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
	WHERE PO.ProviderOfficeBucket_PK = CASE WHEN @Status = 22 THEN 2 ELSE @Status END

	IF (@Status=7)
	BEGIN
		Update T SET ContactNote_PK = CNO.ContactNote_PK FROM #tmpOffice T 
		INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON T.ProviderOffice_PK = CNO.Office_PK
		INNER JOIN tblContactNote CN ON CN.ContactNote_PK = CNO.ContactNote_PK AND CN.IsIssue=1

		IF (@Issue=-1)
		BEGIN
			SELECT TOP 4 ContactNote_Text,COUNT(DISTINCT T.ProviderOffice_PK) Offices,CN.ContactNote_PK INTO #TOP4
			FROM #tmpOffice T 
			INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = T.ContactNote_PK 
			WHERE ProviderOfficeBucket_PK IN (7) 
			GROUP BY CN.ContactNote_PK,ContactNote_Text ORDER BY COUNT(DISTINCT T.ProviderOffice_PK) DESC

			DELETE O FROM #tmpOffice O INNER JOIN #TOP4 T ON T.ContactNote_PK = O.ContactNote_PK
		END
		ELSE IF (@Issue>0)
		BEGIN
			DELETE O FROM #tmpOffice O WHERE O.ContactNote_PK NOT IN (@Issue)
		END
	END

	;With tbl AS(
		SELECT ROW_NUMBER() OVER(ORDER BY PO.Address ASC) AS [#],
		PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State
		,Count(DISTINCT S.Provider_PK) Providers, Count(DISTINCT S.Suspect_PK) Charts,'' Project,CN.ContactNote_Text [Issue]
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN tblProvider PP ON PP.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = PP.ProviderOffice_PK				
			INNER JOIN tblProject P ON P.Project_PK = FP.Project_PK
			INNER JOIN #tmpOffice T ON PP.ProviderOffice_PK = T.ProviderOffice_PK
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			LEFT JOIN tblContactNote CN ON CN.ContactNote_PK = T.ContactNote_PK
			LEFT JOIN tblProviderOfficeStatus POS WITH (NOLOCK) ON POS.ProviderOffice_PK = PO.ProviderOffice_PK
			GROUP BY PO.ProviderOffice_PK,PO.Address,ZC.ZipCode,ZC.City,ZC.State,CN.ContactNote_Text
		)
		SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]
	
	IF @Issue=0
	BEGIN
		SELECT CASE @Status 
			WHEN 1 THEN 'Not Contacted'
			WHEN 2 THEN 'Scheduling in Progress'
			WHEN 3 THEN 'Scheduled'
			WHEN 0 THEN 'Outreach Completed'
			WHEN 7 THEN 'Contacted with Issue'
			WHEN 8 THEN 'Offices with Data Issue'
			WHEN 10 THEN 'Offices with Copy Center'
			WHEN 22 THEN 'Unsuccessful Contact'
			ELSE 'Not Contacted'
			END OfficeStatus
	END
	ELSE
	BEGIN
		IF (@Issue=-1)
			SELECT 'Other Issue' ContactNote_Text
		ELSE
			SELECT ContactNote_Text FROM tblContactNote WHERE ContactNote_PK=@Issue
	END
END
GO
