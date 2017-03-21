/*
Use this migration script to make data changes only. You must commit any additive schema changes first.
Schema changes and migration scripts are deployed in the order they're committed.
*/
/*
This migration script replaces uncommitted changes made to these objects:
ChaseFiles
StagingHash
YHA_20151218_RAPS
tblClaimData
tblCodedData
tblExtractionQueue
tblHccCategory
tblMember
tblModelCode
tblNPL2Validate
tblNoteText
tblNoteType
tblProject
tblRAPSData
tblSuspect
tmpChartLog
tmpDeletesAnalysis
tmpExportAtenaNoClaimID
tmpExportAtenaNoClaimID_bak_500
tmpExportAtenaNoClaimID_bak_Catchup
tmpExportAtenaNoClaimID_bak_Prod
tmpExportAtenaProvMemb
tmpExportAtenaProvMemb_bak_500
tmpExportAtenaProvMemb_bak_Catchup
tmpExportAtenaProvMemb_bak_Prod
tmpExportAtena
tmpExportAtena_bak_500
tmpExportAtena_bak_Catchup
tmpExportAtena_bak_Prod
tmpExportChartStaging
tmpExportChases
tmpExport
tmpInvoices1
tmpInvoices2
tmpInvoices3
Chases13Add
Chases20Add
Chases35Add
Chases
ClaimLineDetail
MHHS-HIX1603 move to CHASE LIST 02 - DNC (002)
MemberHCC
MemorialHermann436NewHighPriorityCharts
MemorialHermann_152 Charts in Issue Log
MemorialHermann_27 Charts - Sent not in Issue
MemorialHermann_CommercialClaimRiskAdj20170214
MemorilaHermannChaseCommerical2016_12_15
ProviderMasterConsolidated
badProviders
tblClaimData
tblMember
tblProject
tblProviderMaster
tblProviderOffice
tblSuspectDOS
tblSuspect
CaptureOutputLog
Private_Configurations
Run_LastExecution
TestMessage
TestResult
qa_getMemberDetail
sr_getExportSummary

Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [dbo].[tblClaimData]'
GO
ALTER TABLE [dbo].[tblClaimData] DROP CONSTRAINT [FK_tblClaimData_tblSuspect]
GO
PRINT N'Dropping foreign keys from [dbo].[tblSuspect]'
GO
ALTER TABLE [dbo].[tblSuspect] DROP CONSTRAINT [FK_tblSuspect_tblChannel]
GO
PRINT N'Dropping constraints from [dbo].[StagingHash]'
GO
ALTER TABLE [dbo].[StagingHash] DROP CONSTRAINT [PK_StagingHash]
GO
PRINT N'Dropping constraints from [dbo].[StagingHash]'
GO
ALTER TABLE [dbo].[StagingHash] DROP CONSTRAINT [DF__StagingHa__Creat__239E4DCF]
GO
PRINT N'Dropping constraints from [dbo].[tblClaimData]'
GO
ALTER TABLE [dbo].[tblClaimData] DROP CONSTRAINT [PK_tblClaimData]
GO
PRINT N'Dropping constraints from [dbo].[tblCodedData]'
GO
ALTER TABLE [dbo].[tblCodedData] DROP CONSTRAINT [PK_tblCodedData]
GO
PRINT N'Dropping constraints from [dbo].[tblExtractionQueue]'
GO
ALTER TABLE [dbo].[tblExtractionQueue] DROP CONSTRAINT [PK_tblExtractionQueue]
GO
PRINT N'Dropping constraints from [dbo].[tblHccCategory]'
GO
ALTER TABLE [dbo].[tblHccCategory] DROP CONSTRAINT [PK_tblHccCategory]
GO
PRINT N'Dropping constraints from [dbo].[tblMember]'
GO
ALTER TABLE [dbo].[tblMember] DROP CONSTRAINT [PK_tblMember]
GO
PRINT N'Dropping constraints from [dbo].[tblNoteText]'
GO
ALTER TABLE [dbo].[tblNoteText] DROP CONSTRAINT [PK_tblNoteText]
GO
PRINT N'Dropping constraints from [dbo].[tblProject]'
GO
ALTER TABLE [dbo].[tblProject] DROP CONSTRAINT [PK_tblProject]
GO
PRINT N'Dropping constraints from [dbo].[tblRAPSData]'
GO
ALTER TABLE [dbo].[tblRAPSData] DROP CONSTRAINT [PK_tblRAPSData]
GO
PRINT N'Dropping constraints from [tSQLt].[Private_Configurations]'
GO
ALTER TABLE [tSQLt].[Private_Configurations] DROP CONSTRAINT [PK__Private___737584F7AEC3D058]
GO
PRINT N'Dropping constraints from [tSQLt].[TestResult]'
GO
ALTER TABLE [tSQLt].[TestResult] DROP CONSTRAINT [PK__TestResu__3214EC07BB8C5B5A]
GO
PRINT N'Dropping index [IX_tblClaimDataICD9] from [dbo].[tblClaimData]'
GO
DROP INDEX [IX_tblClaimDataICD9] ON [dbo].[tblClaimData]
GO
PRINT N'Dropping index [IDX_SuspectPK] from [dbo].[tblClaimData]'
GO
DROP INDEX [IDX_SuspectPK] ON [dbo].[tblClaimData]
GO
PRINT N'Dropping index [IDX_ClaimDataPK_Cols] from [dbo].[tblClaimData]'
GO
DROP INDEX [IDX_ClaimDataPK_Cols] ON [dbo].[tblClaimData]
GO
PRINT N'Dropping index [IX_tblClaimDataMember] from [dbo].[tblClaimData]'
GO
DROP INDEX [IX_tblClaimDataMember] ON [dbo].[tblClaimData]
GO
PRINT N'Dropping index [IX_tblClaimDataProvider] from [dbo].[tblClaimData]'
GO
DROP INDEX [IX_tblClaimDataProvider] ON [dbo].[tblClaimData]
GO
PRINT N'Dropping index [IDX_CodeData_PK] from [dbo].[tblCodedData]'
GO
DROP INDEX [IDX_CodeData_PK] ON [dbo].[tblCodedData]
GO
PRINT N'Dropping index [IX_tblCodedDataICD9] from [dbo].[tblCodedData]'
GO
DROP INDEX [IX_tblCodedDataICD9] ON [dbo].[tblCodedData]
GO
PRINT N'Dropping index [IDX_OfficeExtractUploadDate] from [dbo].[tblExtractionQueue]'
GO
DROP INDEX [IDX_OfficeExtractUploadDate] ON [dbo].[tblExtractionQueue]
GO
PRINT N'Dropping index [IX_ALL] from [dbo].[tblHccCategory]'
GO
DROP INDEX [IX_ALL] ON [dbo].[tblHccCategory]
GO
PRINT N'Dropping index [IDX_MemberPK] from [dbo].[tblMember]'
GO
DROP INDEX [IDX_MemberPK] ON [dbo].[tblMember]
GO
PRINT N'Dropping index [IDX_V12HCC] from [dbo].[tblModelCode]'
GO
DROP INDEX [IDX_V12HCC] ON [dbo].[tblModelCode]
GO
PRINT N'Dropping index [IDX_IsChartNote] from [dbo].[tblNoteText]'
GO
DROP INDEX [IDX_IsChartNote] ON [dbo].[tblNoteText]
GO
PRINT N'Dropping index [IX_IsDiagNote] from [dbo].[tblNoteText]'
GO
DROP INDEX [IX_IsDiagNote] ON [dbo].[tblNoteText]
GO
PRINT N'Dropping index [IDX_NoteType] from [dbo].[tblNoteType]'
GO
DROP INDEX [IDX_NoteType] ON [dbo].[tblNoteType]
GO
PRINT N'Dropping index [IX_Project_PK] from [dbo].[tblProject]'
GO
DROP INDEX [IX_Project_PK] ON [dbo].[tblProject]
GO
PRINT N'Dropping index [IX_tblRAPSDataICD9] from [dbo].[tblRAPSData]'
GO
DROP INDEX [IX_tblRAPSDataICD9] ON [dbo].[tblRAPSData]
GO
PRINT N'Dropping index [IDX_ChartPriority] from [dbo].[tblSuspect]'
GO
DROP INDEX [IDX_ChartPriority] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_tblSuspectChaseStatus] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_tblSuspectChaseStatus] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IDX_IsCoded] from [dbo].[tblSuspect]'
GO
DROP INDEX [IDX_IsCoded] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IDX_MemberSuspect_PK] from [dbo].[tblSuspect]'
GO
DROP INDEX [IDX_MemberSuspect_PK] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_tblSuspectMember] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_tblSuspectMember] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_tblSuspectProject] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_tblSuspectProject] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_ProjectPk_CodedUserPK] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_ProjectPk_CodedUserPK] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_ProjectPKProviderPK] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_ProjectPKProviderPK] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_tblSuspectProvider] from [dbo].[tblSuspect]'
GO
DROP INDEX [IX_tblSuspectProvider] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IDX_SuspectPK_ScanDate] from [dbo].[tblSuspect]'
GO
DROP INDEX [IDX_SuspectPK_ScanDate] ON [dbo].[tblSuspect]
GO
PRINT N'Dropping index [IX_tblModelCode] from [dbo].[tblModelCode]'
GO
DROP INDEX [IX_tblModelCode] ON [dbo].[tblModelCode]
GO
PRINT N'Altering [tSQLt].[TestResult]'
GO
ALTER TABLE [tSQLt].[TestResult] DROP
COLUMN [Name]
GO
ALTER TABLE [tSQLt].[TestResult] ALTER COLUMN [Class] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [tSQLt].[TestResult] ALTER COLUMN [TestCase] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [tSQLt].[TestResult] ALTER COLUMN [TranName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [tSQLt].[TestResult] ALTER COLUMN [Result] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [tSQLt].[TestResult] ALTER COLUMN [Msg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [tSQLt].[TestResult] ADD
[Name] AS ((quotename([Class])+'.')+quotename([TestCase]))
GO
PRINT N'Creating primary key [PK__TestResu__3214EC07771081EA] on [tSQLt].[TestResult]'
GO
ALTER TABLE [tSQLt].[TestResult] ADD CONSTRAINT [PK__TestResu__3214EC07771081EA] PRIMARY KEY CLUSTERED  ([Id]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
PRINT N'Altering [tSQLt].[TestMessage]'
GO
ALTER TABLE [tSQLt].[TestMessage] ALTER COLUMN [Msg] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblProject]'
GO
ALTER TABLE [dbo].[tblProject] ALTER COLUMN [Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tblProject] ALTER COLUMN [ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [tSQLt].[CaptureOutputLog]'
GO
ALTER TABLE [tSQLt].[CaptureOutputLog] ALTER COLUMN [OutputText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblMember]'
GO
ALTER TABLE [dbo].[tblMember] ALTER COLUMN [Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tblMember] ALTER COLUMN [Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tblMember] ALTER COLUMN [Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblModelCode]'
GO
ALTER TABLE [dbo].[tblModelCode] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tblModelCode] ALTER COLUMN [Code_Description] [varchar] (230) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblClaimData]'
GO
ALTER TABLE [dbo].[tblClaimData] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblExtractionQueue]'
GO
ALTER TABLE [dbo].[tblExtractionQueue] ALTER COLUMN [OfficeFaxOrID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblNoteText]'
GO
ALTER TABLE [dbo].[tblNoteText] ALTER COLUMN [NoteText] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblHccCategory]'
GO
ALTER TABLE [dbo].[tblHccCategory] ALTER COLUMN [Disease] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [tSQLt].[Run_LastExecution]'
GO
ALTER TABLE [tSQLt].[Run_LastExecution] ALTER COLUMN [TestName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [tSQLt].[Private_Configurations]'
GO
ALTER TABLE [tSQLt].[Private_Configurations] ALTER COLUMN [Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
PRINT N'Creating primary key [PK__Private___737584F740BA1C0F] on [tSQLt].[Private_Configurations]'
GO
ALTER TABLE [tSQLt].[Private_Configurations] ADD CONSTRAINT [PK__Private___737584F740BA1C0F] PRIMARY KEY CLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
PRINT N'Altering [dbo].[tblCodedData]'
GO
ALTER TABLE [dbo].[tblCodedData] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportChases]'
GO
ALTER TABLE [dbo].[tmpExportChases] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChases] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChases] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChases] ALTER COLUMN [CHART NAME] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportChartStaging]'
GO
ALTER TABLE [dbo].[tmpExportChartStaging] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChartStaging] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChartStaging] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportChartStaging] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblRAPSData]'
GO
ALTER TABLE [dbo].[tblRAPSData] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tblNoteType]'
GO
ALTER TABLE [dbo].[tblNoteType] ALTER COLUMN [NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[qa_getMemberDetail]'
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-14-2014
-- Description:	RA Coder will use this sp to pull list of members details in a project
-- =============================================
--	qa_getMemberDetail 13129,15620,0,0
ALTER PROCEDURE [dbo].[qa_getMemberDetail]  
	@Member BigInt,
	@Suspect BigInt,
	@DetailType tinyint,
	@DetailInfo smallint
AS
BEGIN

	SELECT DISTINCT Provider_PK,ProviderMaster_PK INTO #Prv FROM tblProvider WHERE ProviderMaster_PK IN (SELECT DISTINCT ProviderMaster_PK FROM tblProvider P INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK WHERE S.Suspect_PK = @Suspect)
	/*
	--Diagnosis Data without Historical Data - Start

		SELECT CD.CodedData_PK Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,1 DataType,Year(DOS_Thru) DOS_Year, NoteType
			,V12HCC,V21HCC,V22HCC,RxHCC,C.IsICD10,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM tblCodedData CD WITH (NOLOCK)  
			LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.CodedData_PK
			LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = CD.DiagnosisCode
		WHERE Suspect_PK=@Suspect 
			AND IsNull(CD.Is_Deleted,0)=0
		ORDER BY DOS_Thru DESC

	--Diagnosis Data without Historical Data - End
	*/
	--Diagnosis Data with Historical Data - Start	
		SELECT MAX(Data_PK) Data_PK,DiagnosisCode,DOS_From DOS_From,DOS_Thru,MIN(DataType) DataType,Year(DOS_Thru) DOS_Year,MAX(CodedSource_PK) CodedSource_PK INTO #tmpData FROM (
			SELECT CD.CodedData_PK Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,1 DataType,Year(DOS_Thru) DOS_Year,CD.CodedSource_PK
				FROM tblCodedData CD WITH (NOLOCK)
					LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.CodedData_PK
				WHERE Suspect_PK=@Suspect AND (CD.Is_Deleted IS NULL OR CD.Is_Deleted=0 OR QA.IsRemoved=1)
/*
			UNION
			SELECT -1 Data_PK,DiagnosisCode,DOS_From,DOS_Thru,3 DataType,Year(DOS_Thru) DOS_Year,0 CodedSource_PK
				FROM tblClaimData CD WITH (NOLOCK) 
				INNER JOIN #Prv P ON P.ProviderMaster_PK = CD.ProviderMaster_PK 
				WHERE Member_PK=@Member AND Year(DOS_Thru)>=Year(GetDate())-2 AND DiagnosisCode<>''
				*/
		) T GROUP BY DiagnosisCode,DOS_From,DOS_Thru

		SELECT CD.Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,DataType,Year(DOS_Thru) DOS_Year, NoteType
			,V12HCC,V21HCC,V22HCC,RxHCC,C.IsICD10,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM #tmpData CD   
			LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.Data_PK
			LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = CD.DiagnosisCode
		ORDER BY DOS_Thru DESC
		--Diagnosis Data with Historical Data - Ends
		

	IF (@DetailType=1)
		RETURN;
	--Captured Source
	SELECT * FROM tblCodedSource WITH (NOLOCK) ORDER BY sortOrder
	
	SELECT TOP 1 * FROM tblScannedData WITH (NOLOCK) WHERE Suspect_PK=@Suspect
	
	SELECT NoteText_PK FROM tblSuspectNote WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	SELECT Note_Text FROM tblSuspectNoteText WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	
	SELECT NoteType_PK CodedSource_PK, NoteType CodedSource FROM tblNoteType WITH (NOLOCK)
END
GO
PRINT N'Altering [dbo].[tblNPL2Validate]'
GO
ALTER TABLE [dbo].[tblNPL2Validate] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[sr_getExportSummary]'
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sr_getExportSummary 1,1,0,1
ALTER PROCEDURE [dbo].[sr_getExportSummary] 
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
		--INNER JOIN cacheProviderOffice cPO ON cPO.Project_PK = S.Project_PK AND cPO.ProviderOffice_PK = PO.ProviderOffice_PK
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
	SELECT T.Project_PK,ProviderOffice_PK,MIN(CAST(Sch_Start AS DATE)) SchedulerDate, MAX(ST.ScheduleType) ScheduleType 
		INTO #tmpSchedule FROM tblProviderOfficeSchedule T INNER JOIN #tmpProject Pr ON Pr.Project_PK = T.Project_PK
			LEFT JOIN tblScheduleType ST ON ST.ScheduleType_PK = T.sch_type
			GROUP BY T.Project_PK,ProviderOffice_PK

	SELECT Project_PK, ProviderOffice_PK
			,MIN([1st Contact]) [1st Contact] ,MIN([2nd Contact]) [2nd Contact] ,MIN([3rd Contact]) [3rd Contact] ,MIN([4th Contact]) [4th Contact] ,MIN([Schedule]) [Schedule], MAX(ScheduleType) ScheduleType 
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
				,NULL ScheduleType
			FROM tblSuspect S
			INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
		GROUP BY S.Project_PK,PO.ProviderOffice_PK
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,ContactDate [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA,NULL ScheduleType
			FROM #tmpContact WHERE contact_num=1
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,ContactDate [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA,NULL ScheduleType
			FROM #tmpContact WHERE contact_num=2
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,ContactDate [3rd Contact] ,NULL [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA,NULL ScheduleType
			FROM #tmpContact WHERE contact_num=3
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,ContactDate [4th Contact] ,NULL [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA,NULL ScheduleType
			FROM #tmpContact WHERE contact_num=4
		UNION
		SELECT Project_PK, ProviderOffice_PK
				,NULL [1st Contact] ,NULL [2nd Contact] ,NULL [3rd Contact] ,NULL [4th Contact] ,SchedulerDate [Schedule]
				,NULL [Invoice Rec Start] ,NULL [Invoice Rec End] ,NULL [Chart Rec Start] ,NULL [Chart Rec End] ,NULL [Chart Extraction Start] ,NULL [Chart Extraction End] ,NULL TotalCharts ,NULL Extracted ,NULL CNA, ScheduleType
			FROM #tmpSchedule
	) T GROUP BY Project_PK, ProviderOffice_PK

	SELECT PO.Address [Address Line 1],ZC.City,ZC.ZipCode,ZC.State
		,PO.GroupName [Group Name],PO.ContactPerson [Contact Name],PO.ContactNumber [Phone Number]
		,[1st Contact],[2nd Contact],[3rd Contact],[4th Contact],IsNull(IsNull([Schedule],[Invoice Rec Start]),[Chart Rec Start]) Schedule,ScheduleType
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
PRINT N'Altering [dbo].[StagingHash]'
GO
ALTER TABLE [dbo].[StagingHash] ALTER COLUMN [HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
PRINT N'Altering [dbo].[ChaseFiles]'
GO
ALTER TABLE [dbo].[ChaseFiles] ALTER COLUMN [ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[ChaseFiles] ALTER COLUMN [Chart_File_Name] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[YHA_20151218_RAPS]'
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [MEMBER ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [Member Individual ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [SERVICE FROM DT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [SERVICE TO DT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [Page From] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [Page To] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[YHA_20151218_RAPS] ALTER COLUMN [CHART NAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpChartLog]'
GO
ALTER TABLE [dbo].[tmpChartLog] ALTER COLUMN [ZIP File] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaNoClaimID]'
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID] ALTER COLUMN [CHART NAME] [varchar] (82) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaNoClaimID_bak_500]'
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_500] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaNoClaimID_bak_Catchup]'
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Catchup] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaNoClaimID_bak_Prod]'
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaNoClaimID_bak_Prod] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaProvMemb]'
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaProvMemb_bak_500]'
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_500] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_500] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_500] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_500] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaProvMemb_bak_Catchup]'
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Catchup] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Catchup] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Catchup] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Catchup] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtenaProvMemb_bak_Prod]'
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Prod] ALTER COLUMN [Member ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Prod] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Prod] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtenaProvMemb_bak_Prod] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtena]'
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena] ALTER COLUMN [CHART NAME] [varchar] (82) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtena_bak_500]'
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_500] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtena_bak_Catchup]'
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Catchup] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExportAtena_bak_Prod]'
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExportAtena_bak_Prod] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpExport]'
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [MEMBER ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [Member Individual ID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [Claim ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [PROVIDER TYPE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [DX CODE CATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [ICD CODE DISPOSITION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [ICD CODE DISPOSITION REASON] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [dbo].[tmpExport] ALTER COLUMN [CHART NAME] [varchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpInvoices1]'
GO
ALTER TABLE [dbo].[tmpInvoices1] ALTER COLUMN [Confirmation #] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices1] ALTER COLUMN [Payment Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpInvoices2]'
GO
ALTER TABLE [dbo].[tmpInvoices2] ALTER COLUMN [ State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices2] ALTER COLUMN [ AmountPaid ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices2] ALTER COLUMN [Confirmation #] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices2] ALTER COLUMN [Payment Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [dbo].[tmpInvoices3]'
GO
ALTER TABLE [dbo].[tmpInvoices3] ALTER COLUMN [Patient Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices3] ALTER COLUMN [Site Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices3] ALTER COLUMN [Site Address] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices3] ALTER COLUMN [Confirmation # ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [dbo].[tmpInvoices3] ALTER COLUMN [Payment Type ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[Chases13Add]'
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MedicalRecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [PRICING_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [SVC_TAX_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [NetworkIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [CentauriChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases13Add] ALTER COLUMN [ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[Chases20Add]'
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MedicalRecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [PRICING_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [SVC_TAX_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [NetworkIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [CentauriChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases20Add] ALTER COLUMN [ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[Chases35Add]'
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MedicalRecordID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [PRICING_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [SVC_TAX_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [NetworkIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [CentauriChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases35Add] ALTER COLUMN [ProjectName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[Chases]'
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [FileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ClientID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MemberGender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderNPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderLastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderFirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderSpecialty] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderZip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ICD9_ICD10_Ind] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [PRICING_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [SVC_TAX_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [MHFacilityFlag] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [NetworkIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [CentauriChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[Chases] ALTER COLUMN [ProjectName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[ClaimLineDetail]'
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ClientMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ServiceLine] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [RevenueCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ServiceCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ServiceModifierCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [BillTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [FacilityTypeCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderSpecialty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderCity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderState] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderZip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderPhone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [ProviderFax] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ClaimLineDetail] ALTER COLUMN [EmployeeYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[MHHS-HIX1603 move to CHASE LIST 02 - DNC (002)]'
GO
ALTER TABLE [stage].[MHHS-HIX1603 move to CHASE LIST 02 - DNC (002)] ALTER COLUMN [MHHS-HIX1603 Chase ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[MHHS-HIX1603 move to CHASE LIST 02 - DNC (002)] ALTER COLUMN [MHMD] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[MemberHCC]'
GO
ALTER TABLE [stage].[MemberHCC] ALTER COLUMN [ClientMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[MemberHCC] ALTER COLUMN [HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[MemorialHermann_CommercialClaimRiskAdj20170214]'
GO
ALTER TABLE [stage].[MemorialHermann_CommercialClaimRiskAdj20170214] ALTER COLUMN [clcl_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[MemorialHermann_CommercialClaimRiskAdj20170214] ALTER COLUMN [LowDateOfService] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[MemorialHermann_CommercialClaimRiskAdj20170214] ALTER COLUMN [MemberNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[ProviderMasterConsolidated]'
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[ProviderMasterConsolidated] ALTER COLUMN [FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblClaimData]'
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblClaimData] ALTER COLUMN [ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblMember]'
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [HICNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblMember] ALTER COLUMN [PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblProject]'
GO
ALTER TABLE [stage].[tblProject] ALTER COLUMN [Project_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblProviderMaster]'
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderMaster] ALTER COLUMN [ConsolidatedProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblProviderOffice]'
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [ContactPerson] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [EMR_Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblProviderOffice] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblSuspectDOS]'
GO
ALTER TABLE [stage].[tblSuspectDOS] ALTER COLUMN [ChaseID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspectDOS] ALTER COLUMN [DOS_FromDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspectDOS] ALTER COLUMN [DOS_ToDate] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Altering [stage].[tblSuspect]'
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [Project_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ChasePriority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
ALTER TABLE [stage].[tblSuspect] ALTER COLUMN [ConsolidatedProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
PRINT N'Creating [stage].[MemorialHermann436NewHighPriorityCharts]'
GO
CREATE TABLE [stage].[MemorialHermann436NewHighPriorityCharts]
(
[MemberNumber] [sys].[sysname] NULL,
[clcl_id] [sys].[sysname] NULL,
[LowDateOfService] [sys].[sysname] NULL,
[Paid_Dt] [sys].[sysname] NULL,
[BIRTH_DT] [sys].[sysname] NULL,
[SEX_CD] [sys].[sysname] NULL,
[PRODUCTPLAN] [sys].[sysname] NULL,
[PRODUCTNAME] [sys].[sysname] NULL,
[ADM_DT] [sys].[sysname] NULL,
[DISCH_DT] [sys].[sysname] NULL,
[CLASS_PLAN_ID] [sys].[sysname] NULL,
[MemberFullName] [sys].[sysname] NULL,
[MemberFirstName] [sys].[sysname] NULL,
[MemberLastName] [sys].[sysname] NULL,
[DxCodesBillTypeCd] [sys].[sysname] NULL,
[BillingProviderName] [sys].[sysname] NULL,
[BillingProviderNPI] [sys].[sysname] NULL,
[BillingProviderUniqueID] [sys].[sysname] NULL,
[BillingProviderTIN] [sys].[sysname] NULL,
[BillingProviderTinName] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PAYEE_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PAYEE_PRIM_STATE_CD] [sys].[sysname] NULL,
[PAYEE_PRIM_POSTAL] [sys].[sysname] NULL,
[PAYEE_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PAYEE_PRIM_FAX_NUM] [sys].[sysname] NULL,
[ServiceProviderName] [sys].[sysname] NULL,
[ServiceProviderNPI] [sys].[sysname] NULL,
[ServiceProviderUniqueID] [sys].[sysname] NULL,
[ServiceProviderTIN] [sys].[sysname] NULL,
[ServiceProviderTinName] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[SVC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[SVC_PRIM_STATE_CD] [sys].[sysname] NULL,
[SVC_PRIM_POSTAL] [sys].[sysname] NULL,
[SVC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[SVC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[FAC_ProviderName] [sys].[sysname] NULL,
[FAC_ProviderNPI] [sys].[sysname] NULL,
[FAC_UniqueID] [sys].[sysname] NULL,
[FAC_ProviderTIN] [sys].[sysname] NULL,
[FAC_ProviderTinName] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[FAC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[FAC_PRIM_STATE_CD] [sys].[sysname] NULL,
[FAC_PRIM_POSTAL] [sys].[sysname] NULL,
[FAC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[FAC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Claim_Category_Primary1] [sys].[sysname] NULL,
[Claim_Category_Primary2] [sys].[sysname] NULL,
[Claim_Category_Primary3] [sys].[sysname] NULL,
[Claim_Category_Secondary1] [sys].[sysname] NULL,
[Claim_Category_Secondary2] [sys].[sysname] NULL,
[Claim_Category_Secondary3] [sys].[sysname] NULL,
[Provider_Specialty_Desc1] [sys].[sysname] NULL,
[Provider_Specialty_Desc2] [sys].[sysname] NULL,
[Provider_Specialty_Desc3] [sys].[sysname] NULL,
[PRIM_ProviderName] [sys].[sysname] NULL,
[PRIM_ProviderNPI] [sys].[sysname] NULL,
[PRIM_UniqueID] [sys].[sysname] NULL,
[PRIM_ProviderTIN] [sys].[sysname] NULL,
[PRIM_ProviderTinName] [sys].[sysname] NULL,
[PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PRIM_ADDR_LN_2] [float] NULL,
[PRIM_ADDR_LN_3] [float] NULL,
[PRIM_CITY_NAME] [sys].[sysname] NULL,
[PRIM_STATE_CD] [sys].[sysname] NULL,
[PRIM_POSTAL] [sys].[sysname] NULL,
[PRIM_PHONE_NUM] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIM_FAX_NUM] [sys].[sysname] NULL,
[Unique Chart ID] [sys].[sysname] NULL,
[ExistingProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExistingProviderAdd] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawAddresstoUse] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawZIPtoUse] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAXUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPIUsed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentuariProviderID] [bigint] NULL,
[Member_PK] [bigint] NULL,
[Provider_PK] [bigint] NULL,
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[UniqueChart] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
PRINT N'Rebuilding [dbo].[tmpDeletesAnalysis]'
GO
CREATE TABLE [dbo].[RG_Recovery_1_tmpDeletesAnalysis]
(
[MEMBER ID] [sys].[sysname] NULL,
[Member Individual ID] [sys].[sysname] NULL,
[Claim ID] [sys].[sysname] NULL,
[PROVIDER TYPE] [sys].[sysname] NULL,
[SERVICE FROM DT] [sys].[sysname] NULL,
[SERVICE TO DT] [sys].[sysname] NULL,
[REN Provider ID] [sys].[sysname] NULL,
[ICD Code] [sys].[sysname] NULL,
[DX CODE CATEGORY] [sys].[sysname] NULL,
[ICD CODE DISPOSITION] [sys].[sysname] NULL,
[ICD CODE DISPOSITION REASON] [sys].[sysname] NULL,
[Page From] [float] NULL,
[Page To] [float] NULL,
[REN_TIN] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [sys].[sysname] NULL,
[Visionary Comments] [sys].[sysname] NULL,
[Login] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column1] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Column12] [nvarchar] (510) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visionary Final Comments] [sys].[sysname] NULL
) ON [PRIMARY]
GO
INSERT INTO [dbo].[RG_Recovery_1_tmpDeletesAnalysis]([MEMBER ID], [Member Individual ID], [Claim ID], [PROVIDER TYPE], [SERVICE FROM DT], [SERVICE TO DT], [REN Provider ID], [ICD Code], [DX CODE CATEGORY], [ICD CODE DISPOSITION], [ICD CODE DISPOSITION REASON], [Page From], [Page To], [REN_TIN], [REN_PIN], [PID], [CHART NAME], [Visionary Comments], [Login], [Column1], [Column12], [Visionary Final Comments]) SELECT [MEMBER ID], [Member Individual ID], [Claim ID], [PROVIDER TYPE], [SERVICE FROM DT], [SERVICE TO DT], [REN Provider ID], [ICD Code], [DX CODE CATEGORY], [ICD CODE DISPOSITION], [ICD CODE DISPOSITION REASON], [Page From], [Page To], [REN_TIN], [REN_PIN], [PID], [CHART NAME], [Visionary Comments], [Login], [Column1], [Column12], [Visionary Final Comments] FROM [dbo].[tmpDeletesAnalysis]
GO
DROP TABLE [dbo].[tmpDeletesAnalysis]
GO
EXEC sp_rename N'[dbo].[RG_Recovery_1_tmpDeletesAnalysis]', N'tmpDeletesAnalysis', N'OBJECT'
GO
PRINT N'Rebuilding [stage].[MemorialHermann_152 Charts in Issue Log]'
GO
CREATE TABLE [stage].[RG_Recovery_2_MemorialHermann_152 Charts in Issue Log]
(
[clcl_id] [sys].[sysname] NULL,
[MemberNumber] [sys].[sysname] NULL,
[LowDateOfService] [sys].[sysname] NULL,
[Paid_Dt] [sys].[sysname] NULL,
[BIRTH_DT] [sys].[sysname] NULL,
[SEX_CD] [sys].[sysname] NULL,
[PRODUCTPLAN] [sys].[sysname] NULL,
[PRODUCTNAME] [sys].[sysname] NULL,
[Admit Date] [sys].[sysname] NULL,
[Discharge Date] [sys].[sysname] NULL,
[CLASS_PLAN_ID] [sys].[sysname] NULL,
[MemberFullName] [sys].[sysname] NULL,
[MemberFirstName] [sys].[sysname] NULL,
[MemberLastName] [sys].[sysname] NULL,
[BillingProviderName] [sys].[sysname] NULL,
[BillingProviderNPI] [sys].[sysname] NULL,
[BillingProviderUniqueID] [sys].[sysname] NULL,
[BillingProviderTIN] [sys].[sysname] NULL,
[BillingProviderTinName] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PAYEE_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PAYEE_PRIM_STATE_CD] [sys].[sysname] NULL,
[PAYEE_PRIM_POSTAL] [sys].[sysname] NULL,
[PAYEE_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PAYEE_PRIM_FAX_NUM] [sys].[sysname] NULL,
[ServiceProviderName] [sys].[sysname] NULL,
[ServiceProviderNPI] [sys].[sysname] NULL,
[ServiceProviderUniqueID] [sys].[sysname] NULL,
[ServiceProviderTIN] [sys].[sysname] NULL,
[ServiceProviderTinName] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[SVC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[SVC_PRIM_STATE_CD] [sys].[sysname] NULL,
[SVC_PRIM_POSTAL] [sys].[sysname] NULL,
[SVC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[SVC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[FAC_ProviderName] [sys].[sysname] NULL,
[FAC_ProviderNPI] [sys].[sysname] NULL,
[FAC_UniqueID] [sys].[sysname] NULL,
[FAC_ProviderTIN] [sys].[sysname] NULL,
[FAC_ProviderTinName] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[FAC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[FAC_PRIM_STATE_CD] [sys].[sysname] NULL,
[FAC_PRIM_POSTAL] [sys].[sysname] NULL,
[FAC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[FAC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Claim_Category_Primary1] [sys].[sysname] NULL,
[Claim_Category_Primary2] [sys].[sysname] NULL,
[Claim_Category_Primary3] [sys].[sysname] NULL,
[Claim_Category_Secondary1] [sys].[sysname] NULL,
[Claim_Category_Secondary2] [sys].[sysname] NULL,
[Claim_Category_Secondary3] [sys].[sysname] NULL,
[Provider_Specialty_Desc1] [sys].[sysname] NULL,
[Provider_Specialty_Desc2] [sys].[sysname] NULL,
[Provider_Specialty_Desc3] [sys].[sysname] NULL,
[Claim Category] [sys].[sysname] NULL,
[MHMD?] [sys].[sysname] NULL,
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[PrimaryProvider_ProviderNPI] [sys].[sysname] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTIN] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTinName] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_STATE_CD] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_POSTAL] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Unique Chart ID] [sys].[sysname] NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
INSERT INTO [stage].[RG_Recovery_2_MemorialHermann_152 Charts in Issue Log]([clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [ChaseID]) SELECT [clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [ChaseID] FROM [stage].[MemorialHermann_152 Charts in Issue Log]
GO
DROP TABLE [stage].[MemorialHermann_152 Charts in Issue Log]
GO
EXEC sp_rename N'[stage].[RG_Recovery_2_MemorialHermann_152 Charts in Issue Log]', N'MemorialHermann_152 Charts in Issue Log', N'OBJECT'
GO
PRINT N'Rebuilding [stage].[MemorialHermann_27 Charts - Sent not in Issue]'
GO
CREATE TABLE [stage].[RG_Recovery_3_MemorialHermann_27 Charts - Sent not in Issue]
(
[clcl_id] [sys].[sysname] NULL,
[MemberNumber] [sys].[sysname] NULL,
[LowDateOfService] [sys].[sysname] NULL,
[Paid_Dt] [sys].[sysname] NULL,
[BIRTH_DT] [sys].[sysname] NULL,
[SEX_CD] [sys].[sysname] NULL,
[PRODUCTPLAN] [sys].[sysname] NULL,
[PRODUCTNAME] [sys].[sysname] NULL,
[Admit Date] [sys].[sysname] NULL,
[Discharge Date] [sys].[sysname] NULL,
[CLASS_PLAN_ID] [sys].[sysname] NULL,
[MemberFullName] [sys].[sysname] NULL,
[MemberFirstName] [sys].[sysname] NULL,
[MemberLastName] [sys].[sysname] NULL,
[BillingProviderName] [sys].[sysname] NULL,
[BillingProviderNPI] [sys].[sysname] NULL,
[BillingProviderUniqueID] [sys].[sysname] NULL,
[BillingProviderTIN] [sys].[sysname] NULL,
[BillingProviderTinName] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PAYEE_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PAYEE_PRIM_STATE_CD] [sys].[sysname] NULL,
[PAYEE_PRIM_POSTAL] [sys].[sysname] NULL,
[PAYEE_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PAYEE_PRIM_FAX_NUM] [sys].[sysname] NULL,
[ServiceProviderName] [sys].[sysname] NULL,
[ServiceProviderNPI] [sys].[sysname] NULL,
[ServiceProviderUniqueID] [sys].[sysname] NULL,
[ServiceProviderTIN] [sys].[sysname] NULL,
[ServiceProviderTinName] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[SVC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[SVC_PRIM_STATE_CD] [sys].[sysname] NULL,
[SVC_PRIM_POSTAL] [sys].[sysname] NULL,
[SVC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[SVC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[FAC_ProviderName] [sys].[sysname] NULL,
[FAC_ProviderNPI] [sys].[sysname] NULL,
[FAC_UniqueID] [sys].[sysname] NULL,
[FAC_ProviderTIN] [sys].[sysname] NULL,
[FAC_ProviderTinName] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[FAC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[FAC_PRIM_STATE_CD] [sys].[sysname] NULL,
[FAC_PRIM_POSTAL] [sys].[sysname] NULL,
[FAC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[FAC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Claim_Category_Primary1] [sys].[sysname] NULL,
[Claim_Category_Primary2] [sys].[sysname] NULL,
[Claim_Category_Primary3] [sys].[sysname] NULL,
[Claim_Category_Secondary1] [sys].[sysname] NULL,
[Claim_Category_Secondary2] [sys].[sysname] NULL,
[Claim_Category_Secondary3] [sys].[sysname] NULL,
[Provider_Specialty_Desc1] [sys].[sysname] NULL,
[Provider_Specialty_Desc2] [sys].[sysname] NULL,
[Provider_Specialty_Desc3] [sys].[sysname] NULL,
[Claim Category] [sys].[sysname] NULL,
[MHMD?] [sys].[sysname] NULL,
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[PrimaryProvider_ProviderNPI] [sys].[sysname] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTIN] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTinName] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_STATE_CD] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_POSTAL] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Unique Chart ID] [sys].[sysname] NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
INSERT INTO [stage].[RG_Recovery_3_MemorialHermann_27 Charts - Sent not in Issue]([clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [ChaseID]) SELECT [clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [ChaseID] FROM [stage].[MemorialHermann_27 Charts - Sent not in Issue]
GO
DROP TABLE [stage].[MemorialHermann_27 Charts - Sent not in Issue]
GO
EXEC sp_rename N'[stage].[RG_Recovery_3_MemorialHermann_27 Charts - Sent not in Issue]', N'MemorialHermann_27 Charts - Sent not in Issue', N'OBJECT'
GO
PRINT N'Rebuilding [stage].[MemorilaHermannChaseCommerical2016_12_15]'
GO
CREATE TABLE [stage].[RG_Recovery_4_MemorilaHermannChaseCommerical2016_12_15]
(
[clcl_id] [sys].[sysname] NULL,
[MemberNumber] [sys].[sysname] NULL,
[LowDateOfService] [sys].[sysname] NULL,
[Paid_Dt] [sys].[sysname] NULL,
[BIRTH_DT] [sys].[sysname] NULL,
[SEX_CD] [sys].[sysname] NULL,
[PRODUCTPLAN] [sys].[sysname] NULL,
[PRODUCTNAME] [sys].[sysname] NULL,
[Admit Date] [sys].[sysname] NULL,
[Discharge Date] [sys].[sysname] NULL,
[CLASS_PLAN_ID] [sys].[sysname] NULL,
[MemberFullName] [sys].[sysname] NULL,
[MemberFirstName] [sys].[sysname] NULL,
[MemberLastName] [sys].[sysname] NULL,
[BillingProviderName] [sys].[sysname] NULL,
[BillingProviderNPI] [sys].[sysname] NULL,
[BillingProviderUniqueID] [sys].[sysname] NULL,
[BillingProviderTIN] [sys].[sysname] NULL,
[BillingProviderTinName] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PAYEE_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PAYEE_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PAYEE_PRIM_STATE_CD] [sys].[sysname] NULL,
[PAYEE_PRIM_POSTAL] [sys].[sysname] NULL,
[PAYEE_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PAYEE_PRIM_FAX_NUM] [sys].[sysname] NULL,
[ServiceProviderName] [sys].[sysname] NULL,
[ServiceProviderNPI] [sys].[sysname] NULL,
[ServiceProviderUniqueID] [sys].[sysname] NULL,
[ServiceProviderTIN] [sys].[sysname] NULL,
[ServiceProviderTinName] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[SVC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[SVC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[SVC_PRIM_STATE_CD] [sys].[sysname] NULL,
[SVC_PRIM_POSTAL] [sys].[sysname] NULL,
[SVC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[SVC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[FAC_ProviderName] [sys].[sysname] NULL,
[FAC_ProviderNPI] [sys].[sysname] NULL,
[FAC_UniqueID] [sys].[sysname] NULL,
[FAC_ProviderTIN] [sys].[sysname] NULL,
[FAC_ProviderTinName] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[FAC_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[FAC_PRIM_CITY_NAME] [sys].[sysname] NULL,
[FAC_PRIM_STATE_CD] [sys].[sysname] NULL,
[FAC_PRIM_POSTAL] [sys].[sysname] NULL,
[FAC_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[FAC_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Claim_Category_Primary1] [sys].[sysname] NULL,
[Claim_Category_Primary2] [sys].[sysname] NULL,
[Claim_Category_Primary3] [sys].[sysname] NULL,
[Claim_Category_Secondary1] [sys].[sysname] NULL,
[Claim_Category_Secondary2] [sys].[sysname] NULL,
[Claim_Category_Secondary3] [sys].[sysname] NULL,
[Provider_Specialty_Desc1] [sys].[sysname] NULL,
[Provider_Specialty_Desc2] [sys].[sysname] NULL,
[Provider_Specialty_Desc3] [sys].[sysname] NULL,
[Claim Category] [sys].[sysname] NULL,
[MHMD?] [sys].[sysname] NULL,
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[PrimaryProvider_ProviderNPI] [sys].[sysname] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTIN] [sys].[sysname] NULL,
[PrimaryProvider_ProviderTinName] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_1] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_2] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_ADDR_LN_3] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_CITY_NAME] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_STATE_CD] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_POSTAL] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_PHONE_NUM] [sys].[sysname] NULL,
[PrimaryProvider_PRIM_FAX_NUM] [sys].[sysname] NULL,
[Unique Chart ID] [sys].[sysname] NULL,
[hash] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZip] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawAddresstoUse] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawZIPtoUse] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAXUSed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPIUsed] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentuariProviderID] [bigint] NULL,
[Member_PK] [bigint] NULL,
[Provider_PK] [bigint] NULL,
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[Omit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UniqueChart] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
INSERT INTO [stage].[RG_Recovery_4_MemorilaHermannChaseCommerical2016_12_15]([clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [hash], [NewAddress], [NewZip], [RawAddresstoUse], [RawZIPtoUse], [PhoneUSed], [FAXUSed], [NPIUsed], [CentuariProviderID], [Member_PK], [Provider_PK], [ProviderMaster_PK], [ProviderOffice_PK], [Omit], [UniqueChart]) SELECT [clcl_id], [MemberNumber], [LowDateOfService], [Paid_Dt], [BIRTH_DT], [SEX_CD], [PRODUCTPLAN], [PRODUCTNAME], [Admit Date], [Discharge Date], [CLASS_PLAN_ID], [MemberFullName], [MemberFirstName], [MemberLastName], [BillingProviderName], [BillingProviderNPI], [BillingProviderUniqueID], [BillingProviderTIN], [BillingProviderTinName], [PAYEE_PRIM_ADDR_LN_1], [PAYEE_PRIM_ADDR_LN_2], [PAYEE_PRIM_ADDR_LN_3], [PAYEE_PRIM_CITY_NAME], [PAYEE_PRIM_STATE_CD], [PAYEE_PRIM_POSTAL], [PAYEE_PRIM_PHONE_NUM], [PAYEE_PRIM_FAX_NUM], [ServiceProviderName], [ServiceProviderNPI], [ServiceProviderUniqueID], [ServiceProviderTIN], [ServiceProviderTinName], [SVC_PRIM_ADDR_LN_1], [SVC_PRIM_ADDR_LN_2], [SVC_PRIM_ADDR_LN_3], [SVC_PRIM_CITY_NAME], [SVC_PRIM_STATE_CD], [SVC_PRIM_POSTAL], [SVC_PRIM_PHONE_NUM], [SVC_PRIM_FAX_NUM], [FAC_ProviderName], [FAC_ProviderNPI], [FAC_UniqueID], [FAC_ProviderTIN], [FAC_ProviderTinName], [FAC_PRIM_ADDR_LN_1], [FAC_PRIM_ADDR_LN_2], [FAC_PRIM_ADDR_LN_3], [FAC_PRIM_CITY_NAME], [FAC_PRIM_STATE_CD], [FAC_PRIM_POSTAL], [FAC_PRIM_PHONE_NUM], [FAC_PRIM_FAX_NUM], [Claim_Category_Primary1], [Claim_Category_Primary2], [Claim_Category_Primary3], [Claim_Category_Secondary1], [Claim_Category_Secondary2], [Claim_Category_Secondary3], [Provider_Specialty_Desc1], [Provider_Specialty_Desc2], [Provider_Specialty_Desc3], [Claim Category], [MHMD?], [PrimaryProvider_ProviderName], [PrimaryProvider_ProviderNPI], [PrimaryProvider_UniqueID], [PrimaryProvider_ProviderTIN], [PrimaryProvider_ProviderTinName], [PrimaryProvider_PRIM_ADDR_LN_1], [PrimaryProvider_PRIM_ADDR_LN_2], [PrimaryProvider_PRIM_ADDR_LN_3], [PrimaryProvider_PRIM_CITY_NAME], [PrimaryProvider_PRIM_STATE_CD], [PrimaryProvider_PRIM_POSTAL], [PrimaryProvider_PRIM_PHONE_NUM], [PrimaryProvider_PRIM_FAX_NUM], [Unique Chart ID], [hash], [NewAddress], [NewZip], [RawAddresstoUse], [RawZIPtoUse], [PhoneUSed], [FAXUSed], [NPIUsed], [CentuariProviderID], [Member_PK], [Provider_PK], [ProviderMaster_PK], [ProviderOffice_PK], [Omit], [UniqueChart] FROM [stage].[MemorilaHermannChaseCommerical2016_12_15]
GO
DROP TABLE [stage].[MemorilaHermannChaseCommerical2016_12_15]
GO
EXEC sp_rename N'[stage].[RG_Recovery_4_MemorilaHermannChaseCommerical2016_12_15]', N'MemorilaHermannChaseCommerical2016_12_15', N'OBJECT'
GO
PRINT N'Rebuilding [stage].[badProviders]'
GO
CREATE TABLE [stage].[RG_Recovery_5_badProviders]
(
[PrimaryProvider_ProviderName] [sys].[sysname] NULL,
[ProviderMaster_PK] [bigint] NULL,
[PrimaryProvider_UniqueID] [sys].[sysname] NULL,
[pin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
INSERT INTO [stage].[RG_Recovery_5_badProviders]([PrimaryProvider_ProviderName], [ProviderMaster_PK], [PrimaryProvider_UniqueID], [pin], [Firstname], [Lastname]) SELECT [PrimaryProvider_ProviderName], [ProviderMaster_PK], [PrimaryProvider_UniqueID], [pin], [Firstname], [Lastname] FROM [stage].[badProviders]
GO
DROP TABLE [stage].[badProviders]
GO
EXEC sp_rename N'[stage].[RG_Recovery_5_badProviders]', N'badProviders', N'OBJECT'
GO
PRINT N'Adding constraints to [dbo].[StagingHash]'
GO
ALTER TABLE [dbo].[StagingHash] ADD CONSTRAINT [DF__StagingHa__Creat__36670980] DEFAULT (getdate()) FOR [CreateDate]
GO

