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
rdb_getRetroProgressDrill 0,1,0,1,'',''
rdb_getRetroProgressDrill '0',1,'0',0,'A',0
*/
Create PROCEDURE [dbo].[rdb_getRetroProgressDrill]
	@Projects varchar(20),
	@User int,
	@ProjectGroup varchar(10),
	@DrillType int,
	@Priority varchar(10),
	@Export int
AS
BEGIN
	Declare @Sch_Type AS INT = 99
	if (@DrillType>=10)
	BEGIN
		SET @Sch_Type = @DrillType-10
		SET @DrillType = 1
	END
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

	--Schedule Info
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,Sch_Date DateTime,schedule_type tinyint)
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,S.Provider_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)),IsNull(MIN(PO.sch_type),1)
	FROM tblSuspect S WITH (NOLOCK)
			--INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL
	GROUP BY S.Project_PK,S.Provider_PK
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmp (Project_PK,Provider_PK)

	--Overall Progress for All Projects
	IF (SELECT COUNT(*) FROM #tmpProject)>1
	BEGIN
		IF @DrillType=1 AND @Priority=''
		BEGIN
			SELECT P.Project_PK,Project_Name + IsNull(' '+P.ProjectGroup,'') [Project]
				,SUM(1) [Total Chases]
				,SUM(CASE WHEN cPO.schedule_type=0 THEN 1 ELSE 0 END) [On Site]
				,SUM(CASE WHEN cPO.schedule_type=1 THEN 1 ELSE 0 END) [Fax In]
				,SUM(CASE WHEN cPO.schedule_type=2 THEN 1 ELSE 0 END) [Email/FTP]
				,SUM(CASE WHEN cPO.schedule_type=3 THEN 1 ELSE 0 END) [Post]
				,SUM(CASE WHEN cPO.schedule_type=4 THEN 1 ELSE 0 END) [Invoice]
				,SUM(CASE WHEN cPO.schedule_type=5 THEN 1 ELSE 0 END) [EMR/Remote]
			INTO #tbl
			FROM #tmp cPO INNER JOIN tblProject P WITH (NOLOCK) ON P.Project_PK=cPO.Project_PK 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND S.Provider_PK = cPO.Provider_PK
			GROUP BY P.Project_PK,Project_Name,P.ProjectGroup

			SELECT Project_PK,[Project],[Total Chases]
				,[On Site],CAST(ROUND((CAST([On Site] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [On Site %]
				,[Fax In],CAST(ROUND((CAST([Fax In] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [Fax In %]
				,[Email/FTP],CAST(ROUND((CAST([Email/FTP] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [Email/FTP %]
				,[Post],CAST(ROUND((CAST([Post] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [Post %]
				,[Invoice],CAST(ROUND((CAST([Invoice] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [Invoice %]
				,[EMR/Remote],CAST(ROUND((CAST([EMR/Remote] AS Float)*100)/[Total Chases],2) AS VARCHAR)+'%' [EMR/Remote %] FROM #tbl
			UNION
			SELECT 99999 Project_PK,'Total' [Project],SUM([Total Chases])
				,SUM([On Site]),CAST(ROUND((CAST(SUM([On Site]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [On Site %]
				,SUM([Fax In]),CAST(ROUND((CAST(SUM([Fax In]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [Fax In %]
				,SUM([Email/FTP]),CAST(ROUND((CAST(SUM([Email/FTP]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [Email/FTP %]
				,SUM([Post]),CAST(ROUND((CAST(SUM([Post]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [Post %]
				,SUM([Invoice]),CAST(ROUND((CAST(SUM([Invoice]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [Invoice %]
				,SUM([EMR/Remote]),CAST(ROUND((CAST(SUM([EMR/Remote]) AS Float)*100)/SUM([Total Chases]),2) AS VARCHAR)+'%' [EMR/Remote %] FROM #tbl
			ORDER BY Project_PK
		END
		ELSE
		BEGIN
			SELECT 
				S.Project_PK,Pr.Project_Name + IsNull(' '+Pr.ProjectGroup,'') Project,
				COUNT(*) Chases,
				COUNT(CASE WHEN IsNull(IsNull(T.Sch_Date,S.Scanned_Date),S.CNA_Date) IS NOT NULL THEN S.Suspect_PK ELSE NULL END) Scheduled,
				COUNT(CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Extracted,
				COUNT(CASE WHEN S.IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA,
				COUNT(CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) Coded
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
				INNER JOIN tblProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
				LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
			WHERE @Priority='' OR S.ChartPriority=@Priority
			GROUP BY S.Project_PK,Pr.Project_Name,Pr.ProjectGroup
			ORDER BY Pr.Project_Name
		END
	END
	ELSE
	BEGIN
		SELECT MAX(CN.ContactNote_Text) CNA_Note,CNO.Project_PK,CNO.Office_PK INTO #OfficeCNA FROM tblContactNote CN WITH (NOLOCK) INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON CNO.ContactNote_PK = CN.ContactNote_PK INNER JOIN #tmpProject P ON P.Project_PK = CNO.Project_PK WHERE CN.IsCNA=1 GROUP BY CNO.Project_PK,CNO.Office_PK;

		With tbl AS(
			SELECT 
				ROW_NUMBER() OVER(ORDER BY M.Lastname ASC) AS [#],
				S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,
				PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,
				PO.Address,ZC.ZipCode [Zip Code],ZC.City,ZC.State,
				POB.Bucket [Office Status],
				CASE T.schedule_type
					WHEN 0 THEN 'On Site' 
					WHEN 1 THEN 'Fax In' 
					WHEN 2 THEN 'Email/FTP' 
					WHEN 3 THEN 'Post' 
					WHEN 4 THEN 'Invoice' 
					WHEN 5 THEN 'EMR/Remote' 
				END [Scheduled],
				S.Scanned_Date Extracted,
				CNA_Date CNA,
				IsNull(IsNull(SN.Note_Text+' by Scan Tech',OCNA.CNA_Note+' by Scheduler'),'') [CNA Note],
				Coded_Date Coded,
				S.ChartPriority [Chart Priority]
			FROM tblSuspect S WITH (NOLOCK) 
				INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK
				LEFT JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
				LEFT JOIN tblProviderOfficeBucket POB WITH (NOLOCK) ON PO.ProviderOfficeBucket_PK = POB.ProviderOfficeBucket_PK
				LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
				LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SSN.ScanningNote_PK = SN.ScanningNote_PK
				LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
				LEFT JOIN #OfficeCNA OCNA WITH (NOLOCK) ON OCNA.Project_PK = S.Project_PK AND OCNA.Office_PK = P.ProviderOffice_PK
				WHERE (
					(@DrillType=0)
					OR (@DrillType=1 AND T.Sch_Date IS NOT NULL)
					OR (@DrillType=2 AND S.IsCNA=1)
					OR (@DrillType=3 AND S.IsScanned=1)
					OR (@DrillType=4 AND S.IsCoded=1)
			    ) 
				AND (@Priority='' OR S.ChartPriority=@Priority)
				AND (@Sch_Type=99 OR T.schedule_type=@Sch_Type)
		)
		SELECT * FROM tbl WHERE [#]<=25 OR @Export=1 ORDER BY [#]

		SELECT P.Project_Name + IsNull(' '+P.ProjectGroup,'') FROM tblProject P INNER JOIN #tmpProject tP ON tP.Project_PK=P.Project_PK
	END
END
GO
