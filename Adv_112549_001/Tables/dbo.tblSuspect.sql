CREATE TABLE [dbo].[tblSuspect]
(
[Project_PK] [int] NULL,
[Provider_PK] [int] NULL,
[Member_PK] [int] NULL,
[Suspect_PK] [bigint] NOT NULL IDENTITY(1, 1),
[IsScanned] [bit] NULL,
[IsCNA] [bit] NULL,
[IsCoded] [bit] NULL,
[IsQA] [bit] NULL,
[Scanned_User_PK] [int] NULL,
[CNA_User_PK] [int] NULL,
[Coded_User_PK] [int] NULL,
[QA_User_PK] [int] NULL,
[Scanned_Date] [smalldatetime] NULL,
[CNA_Date] [smalldatetime] NULL,
[Coded_Date] [smalldatetime] NULL,
[QA_Date] [smalldatetime] NULL,
[IsDiagnosisCoded] [bit] NULL,
[IsNotesCoded] [bit] NULL,
[LastAccessed_Date] [smalldatetime] NULL,
[LastUpdated] [smalldatetime] NULL,
[dtCreated] [smalldatetime] NULL,
[IsInvoiced] [bit] NULL,
[MemberStatus] [tinyint] NULL,
[ProspectiveFormStatus] [tinyint] NULL,
[InvoiceRec_Date] [smalldatetime] NULL,
[ChartRec_FaxIn_Date] [smalldatetime] NULL,
[ChartRec_MailIn_Date] [smalldatetime] NULL,
[ChartRec_InComp_Date] [smalldatetime] NULL,
[IsHighPriority] [bit] NULL,
[IsInComp_Replied] [bit] NULL,
[ChaseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartPriority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartRec_Date] [smalldatetime] NULL,
[InvoiceExt_Date] [smalldatetime] NULL,
[ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Channel_PK] [int] NULL,
[EDGEMemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[upd_tblSuspect] 
   ON  [dbo].[tblSuspect]
   AFTER UPDATE
AS
BEGIN
	SELECT DISTINCT IsNull(P.ProviderOffice_PK,0) ProviderOffice_PK,S.Project_PK INTO #tmp FROM inserted S INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK

	SELECT P.ProviderOffice_PK,S.Project_PK
		,Count(1) Charts
		,Count(Scanned_User_PK) Scanned
		,Count(Coded_User_PK) Coded
		,SUM(CASE WHEN IsScanned=0 AND IsCNA=1 THEN 1 ELSE 0 END) CNA INTO #tmp2
		FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN #tmp T ON T.Project_PK = S.Project_PK AND T.ProviderOffice_PK = P.ProviderOffice_PK
		GROUP BY P.ProviderOffice_PK,S.Project_PK

	Update C SET Charts=T.Charts,cna_count=T.CNA, extracted_count=t.Scanned,coded_count=t.Coded
		FROM cacheProviderOffice C WITH (ROWLock) 
		INNER JOIN #tmp2 T ON T.Project_PK = C.Project_PK AND T.ProviderOffice_PK = C.ProviderOffice_PK

	SELECT SUM(Charts) Charts, SUM(Charts-Scanned-CNA) Remaining, ProviderOffice_PK INTO #tmp3 FROM #tmp2 GROUP BY ProviderOffice_PK

	IF EXISTS (SELECT * FROM #tmp3 WHERE Remaining=0)
		Update C SET C.ProviderOfficeBucket_PK=0
		FROM tblProviderOffice C WITH (ROWLock) 
			INNER JOIN #tmp3 T ON T.ProviderOffice_PK = C.ProviderOffice_PK AND T.Remaining=0

	IF EXISTS (SELECT * FROM #tmp3 WHERE Remaining>0 AND Charts>Remaining)
		Update C SET C.ProviderOfficeBucket_PK=6
		FROM tblProviderOffice C WITH (ROWLock) 
			INNER JOIN #tmp3 T ON T.ProviderOffice_PK = C.ProviderOffice_PK AND T.Remaining>0 AND T.Charts>T.Remaining

	DROP TABLE #tmp3
	DROP TABLE #tmp2
	DROP TABLE #tmp
END
GO
ALTER TABLE [dbo].[tblSuspect] ADD CONSTRAINT [PK_tblSuspect] PRIMARY KEY CLUSTERED  ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsCoded] ON [dbo].[tblSuspect] ([IsCoded]) INCLUDE ([Coded_Date], [Coded_User_PK], [Member_PK], [Project_PK], [Provider_PK], [QA_Date], [QA_User_PK], [Scanned_User_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberSuspect_PK] ON [dbo].[tblSuspect] ([IsScanned], [IsCoded]) INCLUDE ([Member_PK], [Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectMember] ON [dbo].[tblSuspect] ([Member_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectProject] ON [dbo].[tblSuspect] ([Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProjectPk_CodedUserPK] ON [dbo].[tblSuspect] ([Project_PK], [Coded_User_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProjectPKProviderPK] ON [dbo].[tblSuspect] ([Project_PK], [Provider_PK]) INCLUDE ([CNA_User_PK], [Coded_User_PK], [LastAccessed_Date], [Member_PK], [Scanned_User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectProvider] ON [dbo].[tblSuspect] ([Provider_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK_ScanDate] ON [dbo].[tblSuspect] ([Suspect_PK]) INCLUDE ([Scanned_Date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspect] ADD CONSTRAINT [FK_tblSuspect_tblChannel] FOREIGN KEY ([Channel_PK]) REFERENCES [dbo].[tblChannel] ([Channel_PK])
GO
