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
[ChaseStatus_PK] [int] NULL,
[PlanLID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastContacted] [smalldatetime] NULL,
[FollowUp] [smalldatetime] NULL,
[LinkedSuspect_PK] [bigint] NULL,
[Session_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspect] ADD CONSTRAINT [PK_tblSuspect] PRIMARY KEY CLUSTERED  ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblSuspectChaseStatus] ON [dbo].[tblSuspect] ([ChaseStatus_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CodedDate] ON [dbo].[tblSuspect] ([Coded_Date]) INCLUDE ([Channel_PK], [ChaseStatus_PK], [Project_PK], [Provider_PK], [Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsCoded] ON [dbo].[tblSuspect] ([IsCoded]) INCLUDE ([Coded_Date], [Coded_User_PK], [Member_PK], [Project_PK], [Provider_PK], [QA_Date], [QA_User_PK], [Scanned_User_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsScannedChannelPK] ON [dbo].[tblSuspect] ([IsScanned], [Channel_PK]) INCLUDE ([ChaseID], [dtCreated], [Member_PK], [Provider_PK], [Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsScannedChaseID] ON [dbo].[tblSuspect] ([IsScanned], [ChaseID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_MemberSuspect_PK] ON [dbo].[tblSuspect] ([IsScanned], [IsCoded]) INCLUDE ([Member_PK], [Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxLinkedSuspect_PK] ON [dbo].[tblSuspect] ([LinkedSuspect_PK]) ON [PRIMARY]
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
CREATE NONCLUSTERED INDEX [IDX_ScannedDate] ON [dbo].[tblSuspect] ([Scanned_Date]) INCLUDE ([Channel_PK], [ChaseStatus_PK], [Project_PK], [Provider_PK], [Suspect_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK_ScanDate] ON [dbo].[tblSuspect] ([Suspect_PK]) INCLUDE ([Scanned_Date]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspect] ADD CONSTRAINT [FK_tblSuspect_tblChannel] FOREIGN KEY ([Channel_PK]) REFERENCES [dbo].[tblChannel] ([Channel_PK])
GO
