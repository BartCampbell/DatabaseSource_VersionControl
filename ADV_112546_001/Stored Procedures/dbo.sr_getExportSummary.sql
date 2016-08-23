SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sr_getExportSummary 1,1,0,1
CREATE PROCEDURE [dbo].[sr_getExportSummary] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@segment int,
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION

	--Schedule Info
	CREATE TABLE #tmpSch(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,Schedule DateTime) --,
	--PRINT 'INSERT INTO #tmp'
	INSERT INTO #tmpSch
	SELECT DISTINCT S.Project_PK,S.Provider_PK,MIN(IsNull(PO.LastUpdated_Date,S.Scanned_Date)) Schedule
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject AP ON AP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	WHERE PO.ProviderOffice_PK IS NOT NULL OR S.Scanned_Date IS NOT NULL
	GROUP BY S.Project_PK,S.Provider_PK
	CREATE CLUSTERED INDEX  idxTProjectPK ON #tmpSch (Project_PK,Provider_PK)
;
    
	--Project Summary
	SELECT 
		(SELECT COUNT(*) FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK WHERE (@segment=0 OR M.Segment_PK=@segment)) TotalCharts,
		(SELECT COUNT(DISTINCT S.Suspect_PK)
			FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK 
			INNER JOIN #tmpSch Sch ON Sch.Project_PK = S.Project_PK AND Sch.Provider_PK = S.Provider_PK
			WHERE (@segment=0 OR M.Segment_PK=@segment)
		) ScheduledCharts,
		(SELECT COUNT(*) FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK WHERE S.IsScanned=1 AND (@segment=0 OR M.Segment_PK=@segment)) ScannedCharts,
		(SELECT COUNT(*) FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK WHERE S.IsCNA=1 AND S.IsScanned=0 AND (@segment=0 OR M.Segment_PK=@segment)) CNACharts,
		(SELECT COUNT(*) FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK WHERE S.IsCoded=1 AND (@segment=0 OR M.Segment_PK=@segment)) AuditedCharts,
		(SELECT COUNT(DISTINCT S.Suspect_PK) FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK 
			INNER JOIN tblProviderOfficeStatus cPO WITH (NOLOCK)  ON P.ProviderOffice_PK = cPO.ProviderOffice_PK
			WHERE cPO.OfficeIssueStatus IN (1,6) AND (@segment=0 OR M.Segment_PK=@segment)
		) OfficeWithNotesCharts,
		(SELECT COUNT(DISTINCT cPO.ProviderOffice_PK) FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN #tmpProject tP ON tP.Project_PK = S.Project_PK
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK 
			INNER JOIN tblProviderOfficeStatus cPO WITH (NOLOCK)  ON P.ProviderOffice_PK = cPO.ProviderOffice_PK
			WHERE cPO.OfficeIssueStatus IN (1,6) AND (@segment=0 OR M.Segment_PK=@segment)
		) OfficeWithNotes    

    --Scheduled Providers
	SELECT 
		PM.Provider_ID [Provider ID]
		,PM.Lastname+IsNull(', '+PM.Firstname,'') [Provider Name]
		,PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
		,Sch.Schedule
		,CASE WHEN DATEDIFF(day,Sch.Schedule,GetDate())>0 AND (Count(DISTINCT S.Suspect_PK)-COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END)-COUNT(DISTINCT CASE WHEN CNA_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END))>0 THEN CAST(DATEDIFF(day,Sch.Schedule,GetDate()) AS VARCHAR(10)) ELSE '' END [Days Overdue]
		--Alex Palomino for 10/24/2013 1300-1800 Hrs
    	,Count(DISTINCT S.Suspect_PK) Charts
    	,COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) Scanned
    	,COUNT(DISTINCT CASE WHEN CNA_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) CNA 
		,Count(DISTINCT S.Suspect_PK)-COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END)-COUNT(DISTINCT CASE WHEN CNA_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) Remaining
		,PM.TIN		
    	FROM tblSuspect S
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN #tmpSch Sch ON Sch.Project_PK = S.Project_PK AND Sch.Provider_PK = S.Provider_PK    	
    	INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
    	INNER JOIN tblProviderOffice PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN cacheProviderOffice cPO ON cPO.Project_PK = S.Project_PK AND cPO.ProviderOffice_PK = PO.ProviderOffice_PK
    	LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK=PO.ZipCode_PK
		/*
    	OUTER APPLY (
    					--SELECT TOP 1 IsNull(U.Firstname+' '+U.Lastname+' for ','')+CAST(Month(Sch_Start) AS VARCHAR)+'/'+CAST(Day(Sch_Start) AS VARCHAR)+'/'+CAST(Year(Sch_Start) AS VARCHAR)+' '+Right(0+CAST(DatePart(Hour,Sch_Start) AS VARCHAR),2)+Right(0+CAST(DatePart(Minute,Sch_Start) AS VARCHAR),2)+'-'+Right(0+CAST(DatePart(Hour,Sch_End) AS VARCHAR),2)+Right(0+CAST(DatePart(Minute,Sch_End) AS VARCHAR),2)+' Hrs' Schedule
						SELECT TOP 1 Sch_Start Schedule
    					FROM tblProviderOfficeSchedule POS
    					LEFT JOIN tblUser U ON POS.Sch_User_PK = U.User_PK 
    					WHERE POS.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = POS.Project_PK 
    					ORDER BY Sch_Start DESC
    				) T
					*/
    WHERE (@segment=0 OR M.Segment_PK=@segment)
    GROUP BY PM.Provider_ID,PM.Lastname,PM.Firstname,PO.Address,ZC.City,ZC.State,ZC.ZipCode,PM.TIN,PO.GroupName,PO.ContactPerson,PO.ContactNumber,Sch.Schedule
    ORDER BY PM.Lastname,PM.Firstname
    
    --Not Scheduled Providers
	SELECT 
		PM.Provider_ID [Provider ID]
		,PM.Lastname+IsNull(', '+PM.Firstname,'') [Provider Name]
		,PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
    	,Count(DISTINCT S.Suspect_PK) Charts ,PM.TIN	
    	FROM tblSuspect S
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
    	INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
    	INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
    	LEFT JOIN tblProviderOffice PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK
    	LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK=PO.ZipCode_PK
		LEFT JOIN #tmpSch Sch ON Sch.Project_PK = S.Project_PK AND Sch.Provider_PK = S.Provider_PK
    WHERE Sch.Provider_PK IS NULL AND (@segment=0 OR M.Segment_PK=@segment)
    GROUP BY PM.Provider_ID,PM.Lastname,PM.Firstname,PO.Address,ZC.City,ZC.State,ZC.ZipCode,PM.TIN,PO.GroupName,PO.ContactPerson,PO.ContactNumber
    ORDER BY PM.Lastname,PM.Firstname    
 
    --Issue Details Providers
	CREATE TABLE #tmpIssueOffice(Project_PK [int] NOT NULL,ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK TinyInt NOT NULL PRIMARY KEY CLUSTERED (Project_PK ASC,ProviderOffice_PK ASC,ContactNote_PK ASC)) ON [PRIMARY]

	Insert Into #tmpIssueOffice
	SELECT DISTINCT 0 Project_PK,PO.ProviderOffice_PK,T.ContactNote_PK
	FROM  tblProviderOfficeStatus PO
		CROSS Apply (
			SELECT TOP 1 CNO.ContactNote_PK 
				FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN 
					ON CN.ContactNote_PK = CNO.ContactNote_PK
				WHERE PO.ProviderOffice_PK = CNO.Office_PK AND CN.IsIssue=1 --PO.Project_PK = CNO.Project_PK AND 
				ORDER BY CNO.LastUpdated_Date DESC) T
		WHERE PO.OfficeIssueStatus IN (1,2,5,6) 

	SELECT 
		PM.Provider_ID [Provider ID]
		,PM.Lastname+IsNull(', '+PM.Firstname,'') [Provider Name]
		,PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
    	,Count(DISTINCT S.Suspect_PK) Charts
		,Count(DISTINCT CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Scanned
		,MAX(CN.ContactNote_Text) [Notes],PM.TIN  	
    	FROM tblSuspect S
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
    	INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
    	INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
    	INNER JOIN tblProviderOffice PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK
		INNER JOIN #tmpIssueOffice tIO ON tIO.ProviderOffice_PK = PO.ProviderOffice_PK --AND S.Project_PK = tIO.Project_PK
		INNER JOIN tblContactNote CN ON CN.ContactNote_PK = tIO.ContactNote_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK=PO.ZipCode_PK
    WHERE (@segment=0 OR M.Segment_PK=@segment)
    GROUP BY S.Project_PK,PO.ProviderOffice_PK,PM.Provider_ID,PM.Lastname,PM.Firstname,PO.Address,ZC.City,ZC.State,ZC.ZipCode,PM.TIN,PO.GroupName,PO.ContactPerson,PO.ContactNumber
    ORDER BY PM.Lastname,PM.Firstname

    --CNA Providers
    --If all provider charts are CNA then we count is as removed
	SELECT 
		PM.Provider_ID [Provider ID]
		,PM.Lastname+IsNull(', '+PM.Firstname,'') [Provider Name]
		,PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
		,'All charts are CNA' Notes
    	,Count(DISTINCT S.Suspect_PK) Charts,PM.TIN
    	FROM tblSuspect S
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
    	INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
    	INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
    	INNER JOIN tblProviderOffice PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK
    	LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK=PO.ZipCode_PK
	WHERE @segment=0 OR M.Segment_PK=@segment
    GROUP BY PM.Provider_ID,PM.Lastname,PM.Firstname,PO.Address,ZC.City,ZC.State,ZC.ZipCode,PM.TIN,PO.GroupName,PO.ContactPerson,PO.ContactNumber
    Having Count(DISTINCT S.Suspect_PK) = COUNT(DISTINCT CASE WHEN CNA_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END)
    ORDER BY PM.Lastname,PM.Firstname    

    -- Scanned
 	SELECT 
		PM.Provider_ID [Provider ID]
		,PM.Lastname+', '+PM.Firstname [Provider Name]
		,PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
		--Alex Palomino for 10/24/2013 1300-1800 Hrs
    	,Count(DISTINCT S.Suspect_PK) Charts
    	,COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) Scanned
    	,COUNT(DISTINCT CASE WHEN Coded_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) Coded
    	,COUNT(DISTINCT CASE WHEN CNA_User_PK IS NULL THEN NULL ELSE S.Suspect_PK END) CNA    ,PM.TIN	
    	FROM tblSuspect S
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
		INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK    	
    	INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
    	INNER JOIN tblProviderOffice PO ON P.ProviderOffice_PK = PO.ProviderOffice_PK
    	LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK=PO.ZipCode_PK
    	    WHERE S.Scanned_User_PK IS NOT NULL AND (@segment=0 OR M.Segment_PK=@segment)
    GROUP BY PM.Provider_ID,PM.Lastname,PM.Firstname,PO.Address,ZC.City,ZC.State,ZC.ZipCode,PM.TIN,PO.GroupName,PO.ContactPerson,PO.ContactNumber
    ORDER BY PM.Lastname,PM.Firstname

	EXEC ('SELECT * FROM tblProject WHERE Project_PK IN ('+@Projects+')')
	SELECT * FROM tblSegment WHERE Segment_PK = @segment

	--Turnaround Time Report
	SELECT T.Project_PK,T.Office_PK ProviderOffice_PK,contact_num,MIN(CAST(LastUpdated_Date AS DATE)) ContactDate 
		INTO #tmpContact FROM tblContactNotesOffice T INNER JOIN #tmpProject Pr ON Pr.Project_PK = T.Project_PK
			GROUP BY T.Project_PK,T.Office_PK,contact_num 
	SELECT T.Project_PK,ProviderOffice_PK,MIN(CAST(Sch_Start AS DATE)) SchedulerDate 
		INTO #tmpSchedule FROM tblProviderOfficeSchedule T INNER JOIN #tmpProject Pr ON Pr.Project_PK = T.Project_PK
			GROUP BY T.Project_PK,ProviderOffice_PK

	SELECT Project_PK, ProviderOffice_PK
			,MIN([1st Contact]) [1st Contact] ,MIN([2nd Contact]) [2nd Contact] ,MIN([3rd Contact]) [3rd Contact] ,MIN([4th Contact]) [4th Contact] ,MIN([Schedule]) [Schedule]
			,MIN([Invoice Rec Start]) [Invoice Rec Start] ,MAX([Invoice Rec End]) [Invoice Rec End] ,MIN([Chart Rec Start]) [Chart Rec Start] ,MAX([Chart Rec End]) [Chart Rec End] ,MIN([Chart Extraction Start]) [Chart Extraction Start] ,MAX([Chart Extraction End]) [Chart Extraction End] ,MAX(TotalCharts) TotalCharts ,MAX(Extracted) Extracted ,MAX(CNA) CNA
	INTO #tmpTurnaround FROM (
		SELECT S.Project_PK,PO.ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact]
				,NULL [Schedule]
				,MIN(CAST(InvoiceRec_Date AS DATE)) [Invoice Rec Start]
				,MAX(CAST(InvoiceRec_Date AS DATE)) [Invoice Rec End]
				,MIN(CAST(IsNull(ChartRec_MailIn_Date,ChartRec_FaxIn_Date) AS DATE)) [Chart Rec Start]
				,MAX(CAST(IsNull(ChartRec_MailIn_Date,ChartRec_FaxIn_Date) AS DATE)) [Chart Rec End]
				,MIN(CAST(Scanned_Date AS DATE)) [Chart Extraction Start]
				,MAX(CAST(Scanned_Date AS DATE)) [Chart Extraction End]
				,COUNT(*) TotalCharts
				,COUNT(CASE WHEN IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Extracted
				,COUNT(CASE WHEN IsScanned=0 AND IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA
			FROM tblSuspect S
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
		GROUP BY S.Project_PK,PO.ProviderOffice_PK
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,ContactDate [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA
			FROM #tmpContact WHERE contact_num=1
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,ContactDate [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA
			FROM #tmpContact WHERE contact_num=2
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,ContactDate [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA
			FROM #tmpContact WHERE contact_num=3
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,ContactDate [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA
			FROM #tmpContact WHERE contact_num=4
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,SchedulerDate [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA
			FROM #tmpSchedule
	) T GROUP BY Project_PK, ProviderOffice_PK

	SELECT PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
		,[1st Contact],[2nd Contact],[3rd Contact],[4th Contact],IsNull(IsNull([Schedule],[Invoice Rec Start]),[Chart Rec Start]) Schedule
		,[Invoice Rec Start] ,CASE WHEN [Invoice Rec End] = [Invoice Rec Start] THEN NULL ELSE [Invoice Rec End] END [Invoice Rec End]
		,[Chart Rec Start] , CASE WHEN [Chart Rec End]=[Chart Rec Start] THEN NULL ELSE [Chart Rec End] END [Chart Rec End]
		,[Chart Extraction Start] , CASE WHEN [Chart Extraction End]=[Chart Extraction Start] THEN NULL ELSE [Chart Extraction END] END [Chart Extraction End]
		,TotalCharts ,Extracted ,CNA, TotalCharts-Extracted-CNA Remaining
	FROM #tmpTurnaround T
		INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK =  T.ProviderOffice_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
	--WHERE TotalCharts=Extracted+CNA
END
GO
