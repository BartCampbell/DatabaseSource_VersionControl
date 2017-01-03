SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report Summary for Dashboad
-- =============================================
/* Sample Executions
sr_getSummary 0,0,'1,7,8,9'
PrepareCacheProviderOffice
*/
CREATE PROCEDURE [dbo].[sr_getSummary]
	@Project int,
	@IsValidation bit,
	@allowed_projects varchar(500)
AS
BEGIN
	CREATE TABLE #tmpProj(Proj_PK [int] NOT NULL PRIMARY KEY CLUSTERED (Proj_PK ASC)) ON [PRIMARY]
	--INSERT INTO #tmpProj SELECT Project_PK FROM tblProject

	--SELECT TOP 0 1000 Proj_PK INTO #tmpProj
	If @Project=0
		EXEC ('INSERT INTO #tmpProj SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+ @allowed_projects +')');
	else 
		INSERT INTO #tmpProj SELECT @Project Project_PK
	--DROP TABLE #tmp
	CREATE TABLE #tmp(Project_PK [int] NOT NULL,Provider_PK bigint NOT NULL,ProviderOffice_PK BigInt,Sch_Date DateTime PRIMARY KEY CLUSTERED (Project_PK ASC,Provider_PK ASC)) ON [PRIMARY]

	INSERT INTO #tmp
	SELECT DISTINCT S.Project_PK,S.Provider_PK,PO.ProviderOffice_PK,MIN(PO.LastUpdated_Date) Sch_Date	
	FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProj AP ON AP.Proj_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblProviderOfficeSchedule PO WITH (NOLOCK) ON P.ProviderOffice_PK = PO.ProviderOffice_PK AND S.Project_PK = PO.Project_PK
	GROUP BY S.Project_PK,S.Provider_PK,PO.ProviderOffice_PK

	--Overall Progress
	SELECT COUNT(Suspect_PK) Charts,
		COUNT(T.ProviderOffice_PK) Scheduled,
		COUNT(S.Scanned_User_PK) Extracted,
		COUNT(S.CNA_User_PK) CNA,
		COUNT(S.Coded_User_PK) Coded
	FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
	
	--BURN DOWN
	SELECT DYear,DWeek,MAX(Scheduled) Scheduled, MAX(Extracted) Extracted, MAX(CNA) CNA, MAX(Coded) Coded,MAX(CAST(Dt AS DATE)) Dt FROM (
		SELECT Year(Sch_Date) DYear,DATEPART(WK,Sch_Date) DWeek,COUNT(DISTINCT S.Suspect_PK) Scheduled, NULL Extracted, NULL CNA, NULL Coded, MAX(Sch_Date) Dt
		FROM tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK	
		WHERE Sch_Date IS NOT NULL
		GROUP BY Year(Sch_Date),DATEPART(WK,Sch_Date)
		UNION
		SELECT Year(Scanned_Date) DYear,DATEPART(WK,Scanned_Date) DWeek,NULL Scheduled, COUNT(DISTINCT S.Suspect_PK) Extracted, NULL CNA, NULL Coded, MAX(Scanned_Date) Dt
		FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		WHERE Scanned_Date IS NOT NULL
		GROUP BY Year(Scanned_Date),DATEPART(WK,Scanned_Date)
		UNION
		SELECT Year(CNA_Date) DYear,DATEPART(WK,CNA_Date) DWeek,NULL Scheduled, NULL Extracted, COUNT(DISTINCT S.Suspect_PK) CNA, NULL Coded, MAX(CNA_Date) Dt
		FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		WHERE CNA_Date IS NOT NULL
		GROUP BY Year(CNA_Date),DATEPART(WK,CNA_Date)
		UNION
		SELECT Year(Coded_Date) DYear,DATEPART(WK,Coded_Date) DWeek,NULL Scheduled, NULL Extracted, NULL CNA, COUNT(DISTINCT S.Suspect_PK) Coded, MAX(Coded_Date) Dt
		FROM tblSuspect S WITH (NOLOCK)
		INNER JOIN #tmp T ON S.Project_PK = T.Project_PK AND S.Provider_PK = T.Provider_PK
		WHERE Coded_Date IS NOT NULL
		GROUP BY Year(Coded_Date),DATEPART(WK,Coded_Date)	
	) T GROUP BY DYear,DWeek ORDER BY DYear,DWeek

	--TOP 15 HCC
	SELECT TOP 15 H.HCC,H.HCC_Desc,COUNT(DISTINCT CD.Suspect_PK) HCCs FROM tblModelCode MC
		INNER JOIN tblCodedData CD ON CD.DiagnosisCode = MC.DiagnosisCode AND MC.V12HCC IS NOT NULL
		INNER JOIN tblSuspect S ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblHCC H ON H.HCC = MC.V12HCC AND H.PaymentModel=12
		INNER JOIN #tmpProj AP ON AP.Proj_PK = S.Project_PK
	GROUP BY H.HCC,H.HCC_Desc ORDER BY COUNT(DISTINCT CD.Suspect_PK) DESC	

	--Office Status
	CREATE TABLE #tmpIssueOffice(Project_PK [int] NOT NULL,ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK TinyInt NOT NULL PRIMARY KEY CLUSTERED (Project_PK ASC,ProviderOffice_PK ASC,ContactNote_PK ASC)) ON [PRIMARY]

	Insert Into #tmpIssueOffice
	SELECT DISTINCT PO.Project_PK,PO.ProviderOffice_PK,T.ContactNote_PK
	FROM  tblProviderOfficeStatus PO
		CROSS Apply (
			SELECT TOP 1 CNO.ContactNote_PK 
				FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN 
					ON CN.ContactNote_PK = CNO.ContactNote_PK
				WHERE PO.Project_PK = CNO.Project_PK AND PO.ProviderOffice_PK = CNO.Office_PK AND CN.IsIssue=1
				ORDER BY CNO.LastUpdated_Date DESC) T
		WHERE PO.OfficeIssueStatus IN (1,2) 

	--Copy Center
	CREATE TABLE #tmpCopyCenterOffice(Project_PK [int] NOT NULL,ProviderOffice_PK BIGINT NOT NULL,ContactNote_PK TinyInt NOT NULL PRIMARY KEY CLUSTERED (Project_PK ASC,ProviderOffice_PK ASC,ContactNote_PK ASC)) ON [PRIMARY]
	Insert Into #tmpCopyCenterOffice
	SELECT DISTINCT PO.Project_PK,PO.ProviderOffice_PK,T.ContactNote_PK
	FROM  cacheProviderOffice PO
		CROSS Apply (
			SELECT TOP 1 CNO.ContactNote_PK 
				FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN 
					ON CN.ContactNote_PK = CNO.ContactNote_PK
				WHERE PO.Project_PK = CNO.Project_PK AND PO.ProviderOffice_PK = CNO.Office_PK AND CN.IsCopyCenter=1
				ORDER BY CNO.LastUpdated_Date DESC) T


/*
	SELECT DISTINCT PO.Project_PK,PO.ProviderOffice_PK,Max(CNO.ContactNote_PK) ContactNote_PK FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN ON CN.ContactNote_PK = CNO.ContactNote_PK
		INNER JOIN cacheProviderOffice PO ON PO.Project_PK = CNO.Project_PK AND PO.ProviderOffice_PK = CNO.Office_PK
		INNER JOIN #tmpProj Pr ON Pr.Proj_PK = PO.Project_PK
		WHERE PO.office_status>3 AND CN.IsIssue=1
	GROUP BY PO.Project_PK,PO.ProviderOffice_PK
	*/

	PRINT 'Here'
	SELECT Case 
		WHEN tIS.ProviderOffice_PK IS NOT NULL THEN 'Issue'
		WHEN tCS.ProviderOffice_PK IS NOT NULL THEN 'Copy Center'  
		WHEN office_status=1 THEN 'Coded'
		WHEN office_status=2 THEN 'Extracted'
		WHEN office_status=3 THEN 'Scheduled'
		WHEN office_status=4 THEN 'Contacted'
		ELSE 'Not Contacted' END [Status],COUNT(*) [Count] FROM cacheProviderOffice cPO
			INNER JOIN #tmpProj Pr ON Pr.Proj_PK = cPO.Project_PK
			LEFT JOIN #tmpIssueOffice tIS ON cPO.Project_PK = tIS.Project_PK AND cPO.ProviderOffice_PK = tIS.ProviderOffice_PK
			LEFT JOIN #tmpCopyCenterOffice tCS ON cPO.Project_PK = tCS.Project_PK AND cPO.ProviderOffice_PK = tCS.ProviderOffice_PK
		GROUP BY 
	Case 
		WHEN tIS.ProviderOffice_PK IS NOT NULL THEN 'Issue'
		WHEN tCS.ProviderOffice_PK IS NOT NULL THEN 'Copy Center'  
		WHEN office_status=1 THEN 'Coded'
		WHEN office_status=2 THEN 'Extracted'
		WHEN office_status=3 THEN 'Scheduled'
		WHEN office_status=4 THEN 'Contacted'
		ELSE 'Not Contacted' END,
		Case  
		WHEN tIS.ProviderOffice_PK IS NOT NULL THEN 0
		WHEN tCS.ProviderOffice_PK IS NOT NULL THEN 5
		WHEN office_status=1 THEN 1 
		WHEN office_status=2 THEN 2
		WHEN office_status=3 THEN 3
		WHEN office_status=4 THEN 4

		ELSE 6 END
	ORDER BY 
		Case 
		WHEN tIS.ProviderOffice_PK IS NOT NULL THEN 0
		WHEN tCS.ProviderOffice_PK IS NOT NULL THEN 5		 
		WHEN office_status=1 THEN 1 
		WHEN office_status=2 THEN 2
		WHEN office_status=3 THEN 3
		WHEN office_status=4 THEN 4

		ELSE 6 END

	SELECT ContactNote_Text,COUNT(*) Offices FROM #tmpIssueOffice T INNER JOIN tblContactNote CN ON CN.ContactNote_PK = T.ContactNote_PK GROUP BY ContactNote_Text ORDER BY COUNT(*) DESC
	
	IF (@IsValidation=0)
		return;
		
	--Validation Status
	SELECT NT.NoteType_PK,NT.NoteType,COUNT(CD.CodedData_PK) Diags FROM tblNoteType NT
		INNER JOIN tblCodedData CD ON CD.CodedSource_PK = NT.NoteType_PK
		INNER JOIN tblSuspect S ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN #tmpProj AP ON AP.Proj_PK = S.Project_PK
	GROUP BY NT.NoteType_PK,NT.NoteType ORDER BY NT.NoteType
	--Validation Status
	SELECT NT.NoteText_PK,NT.NoteText,COUNT(CD.CodedData_PK) Diags FROM tblCodedDataNote CDN
		INNER JOIN tblCodedData CD ON CD.CodedData_PK = CDN.CodedData_PK
		INNER JOIN tblSuspect S ON CD.Suspect_PK = S.Suspect_PK
		INNER JOIN tblNoteText NT ON NT.NoteText_PK = CDN.NoteText_PK
		INNER JOIN #tmpProj AP ON AP.Proj_PK = S.Project_PK		
	GROUP BY NT.NoteText_PK,NT.NoteText ORDER BY NT.NoteText
	
END
GO
