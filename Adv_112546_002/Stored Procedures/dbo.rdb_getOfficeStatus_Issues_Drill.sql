SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* Sample Executions
rdb_getOfficeStatus_Issues_Drill '0','0','0','0','0',1,7,0,0
*/
CREATE PROCEDURE [dbo].[rdb_getOfficeStatus_Issues_Drill]
	@Channel VARCHAR(1000),
	@Projects varchar(1000),
	@ProjectGroup varchar(1000),
	@Status1 varchar(1000),
	@Status2 varchar(1000),
	@User int,
	@Status int,
	@Issue int,
	@Export int
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
	CREATE TABLE #tmpOffice(ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK INT NOT NULL,ProviderOfficeBucket_PK TinyInt NOT NULL,ProviderOfficeSubBucket_PK TinyInt NULL) ON [PRIMARY]	
	CREATE INDEX idxIOProviderOffice_PK ON #tmpOffice (ProviderOffice_PK)
	CREATE INDEX idxIOContactNote_PK ON #tmpOffice (ContactNote_PK)

	Insert Into #tmpOffice(ProviderOffice_PK,ContactNote_PK,ProviderOfficeBucket_PK,ProviderOfficeSubBucket_PK)
	SELECT P.ProviderOffice_PK,0 ContactNote_PK, CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END ProviderOfficeBucket_PK,PO.ProviderOfficeSubBucket_PK
		FROM tblProviderOffice PO WITH (NOLOCK)
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
	GROUP BY P.ProviderOffice_PK,PO.ProviderOfficeSubBucket_PK

	
	DELETE FROM #tmpOffice
		WHERE NOT (
			(@Status=101 AND ProviderOfficeBucket_PK=2) OR 
			(@Status=102 AND ProviderOfficeBucket_PK=5 AND (ProviderOfficeSubBucket_PK IS NULL OR ProviderOfficeSubBucket_PK<>3)) OR 
			(@Status=103 AND ProviderOfficeBucket_PK=5 AND ProviderOfficeSubBucket_PK IS NOT NULL AND ProviderOfficeSubBucket_PK=3) OR 
			(@Status=1 AND ProviderOfficeBucket_PK=1) OR 
			(@Status=2 AND ProviderOfficeBucket_PK IN (2,5)) OR 
			(@Status=3 AND ProviderOfficeBucket_PK IN (3,4)) OR 
			(@Status=6 AND ProviderOfficeBucket_PK=6)
		)
		--SELECT * FROM #tmpOffice
		--return;
	IF (@Status=102)
	BEGIN
		Update T SET ContactNote_PK = CNO.ContactNote_PK FROM #tmpOffice T 
		INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON T.ProviderOffice_PK = CNO.Office_PK
		INNER JOIN tblContactNote CN ON CN.ContactNote_PK = CNO.ContactNote_PK AND CN.IsIssue=1

		IF (@Issue=-1)
		BEGIN
			SELECT TOP 4 ContactNote_Text,COUNT(DISTINCT T.ProviderOffice_PK) Offices,CN.ContactNote_PK INTO #TOP4
			FROM #tmpOffice T 
			INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = T.ContactNote_PK 
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
			INNER JOIN #tmpChaseStatus FS ON FS.ChaseStatus_PK = S.ChaseStatus_PK
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
			WHEN 1 THEN 'Not Yet Contacted'
			WHEN 2 THEN 'Scheduling in Progress'
			WHEN 3 THEN 'Scheduled'
			WHEN 6 THEN 'Outreach Completed'
			WHEN 102 THEN 'Contacted with Issue'
			WHEN 103 THEN 'Offices with Copy Center'
			WHEN 101 THEN 'Unsuccessful Contact'
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
