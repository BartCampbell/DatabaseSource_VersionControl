SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getOfficeStatus_Issues_Drill 0,1,0,-1,0
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
	/*
	Status Values
		Issue - 0
		Copy Center - 5
		Coded - 1
		Extracted - 2
		Scheduled - 3
		Contacted - 4
		Not Contacted - 5
	*/
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
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
	CREATE TABLE #tmpOffice(ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK TinyInt NOT NULL PRIMARY KEY CLUSTERED (ProviderOffice_PK ASC,ContactNote_PK ASC)) ON [PRIMARY]

	If @Status IN (0,7)
	BEGIN
		--Issues
		Insert Into #tmpOffice
		SELECT DISTINCT PO.ProviderOffice_PK,T.ContactNote_PK
		FROM  tblProviderOfficeStatus PO
			INNER JOIN cacheProviderOffice cPO ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK --cPO.Project_PK = PO.Project_PK AND 
			CROSS Apply (
				SELECT TOP 1 CNO.ContactNote_PK 
					FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN 
						ON CN.ContactNote_PK = CNO.ContactNote_PK
					WHERE PO.ProviderOffice_PK = CNO.Office_PK AND CN.IsIssue=1 --PO.Project_PK = CNO.Project_PK AND 
					ORDER BY CNO.LastUpdated_Date DESC) T
			WHERE (PO.OfficeIssueStatus IN (1,2,5,6) AND @Status=0 AND @Issue<>0)
			OR (PO.OfficeIssueStatus IN (1,2,5) AND @Status=0 AND @Issue=0)
			OR (PO.OfficeIssueStatus IN (6) AND @Status=7)
	END
	ELSE IF @Status=5
	BEGIN
	--Copy Center
		Insert Into #tmpOffice
		SELECT DISTINCT PO.ProviderOffice_PK,T.ContactNote_PK 
		FROM  cacheProviderOffice PO
			CROSS Apply (
				SELECT TOP 1 CNO.ContactNote_PK 
					FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN 
						ON CN.ContactNote_PK = CNO.ContactNote_PK
					WHERE PO.ProviderOffice_PK = CNO.Office_PK AND CN.IsCopyCenter=1 --PO.Project_PK = CNO.Project_PK AND 
					ORDER BY CNO.LastUpdated_Date DESC) T
	END

	IF (@Status=0) 
	BEGIN
		SELECT ContactNote_PK,COUNT(*) Cnt INTO #tmp FROM #tmpOffice GROUP BY ContactNote_PK 
		IF (@Issue=-1)
			DELETE FROM #tmpOffice WHERE ContactNote_PK IN (SELECT TOP 7 ContactNote_PK FROM #tmp ORDER BY Cnt DESC)
		ELSE IF (@Issue>0)
			DELETE FROM #tmpOffice WHERE ContactNote_PK<>@Issue
	END
--rdb_getOfficeStatus_Issues_Drill 0,1,7,0,0
		;With tbl AS(
			SELECT ROW_NUMBER() OVER(ORDER BY PO.Address ASC) AS [#],
			PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State
			,Count(DISTINCT S.Provider_PK) Providers, Count(DISTINCT S.Suspect_PK) Charts,'' Project,CN.ContactNote_Text [Issue]
			,CASE WHEN @Status IN (0,7) THEN CASE MIN(POS.OfficeIssueStatus) WHEN 1 THEN 'Pending' WHEN 2 THEN 'Awaiting Scheduler' WHEN 5 THEN 'Contacted' WHEN 6 THEN 'Data Issue' ELSE '' END ELSE '' END [Issue Status]
			FROM tblSuspect S WITH (NOLOCK)
				INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
				INNER JOIN tblProvider PP ON PP.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = PP.ProviderOffice_PK				
				INNER JOIN tblProject P ON P.Project_PK = Pr.Project_PK
				LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN #tmpOffice T ON PP.ProviderOffice_PK = T.ProviderOffice_PK --cPO.Project_PK = T.Project_PK AND 
				LEFT JOIN tblContactNote CN ON CN.ContactNote_PK = T.ContactNote_PK
				LEFT JOIN tblProviderOfficeStatus POS WITH (NOLOCK) ON POS.ProviderOffice_PK = PO.ProviderOffice_PK
			WHERE (@Channel=0 OR S.Channel_PK=@Channel)
				AND (
				(@Issue=0 AND @Status=0 AND T.ProviderOffice_PK IS NOT NULL) --'Issue'
				--OR (@Status=5 AND T.ProviderOffice_PK IS NOT NULL) --'Copy Center'  
				OR (@Status=1 AND office_status=1) --'Coded'
				OR (@Status=2 AND office_status=2) --'Extracted'
				OR (@Status=3 AND office_status=3) --'Scheduled'
				OR (@Status=4 AND office_status=4) --'Contacted'
				OR (@Status=6 AND office_status=5) -- Not Contacted
				OR (@Status IN (0,7,5) AND T.ProviderOffice_PK IS NOT NULL) --'Issue Chart'
				)
			GROUP BY PO.ProviderOffice_PK,PO.Address,ZC.ZipCode,ZC.City,ZC.State,CN.ContactNote_Text
		)
		SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]
	
	IF @Issue=0 
	BEGIN
		SELECT CASE @Status 
			WHEN 0 THEN 'Issue'
			WHEN 5 THEN 'Copy Center'
			WHEN 1 THEN 'Coded'
			WHEN 2 THEN 'Extracted'
			WHEN 3 THEN 'Scheduled'
			WHEN 4 THEN 'Contacted'
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
