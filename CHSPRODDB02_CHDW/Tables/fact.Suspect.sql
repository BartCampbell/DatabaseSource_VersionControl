CREATE TABLE [fact].[Suspect]
(
[SuspectID] [int] NOT NULL IDENTITY(1, 1),
[CentauriSuspectID] [int] NOT NULL,
[ProjectID] [int] NULL,
[ProviderID] [int] NULL,
[MemberID] [int] NULL,
[IsScanned] [bit] NULL,
[IsCNA] [bit] NULL,
[IsCoded] [bit] NULL,
[IsQA] [bit] NULL,
[Scanned_UserID] [int] NULL,
[CNA_UserID] [int] NULL,
[Coded_UserID] [int] NULL,
[QA_UserID] [int] NULL,
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
[CreateDate] [datetime] NULL CONSTRAINT [DF_Suspect_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderSuspect_LastUpdate] DEFAULT (getdate()),
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartPriority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartRec_Date] [smalldatetime] NULL,
[InvoiceExt_Date] [smalldatetime] NULL,
[Channel_PK] [int] NULL,
[EDGEMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCentauri] [bit] NULL,
[ProviderOfficeID] [int] NULL,
[ClientID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [PK_Suspect] PRIMARY KEY CLUSTERED  ([SuspectID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsCentauri] ON [fact].[Suspect] ([IsCentauri]) INCLUDE ([ClientID], [ProviderOfficeID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_CNA_User] FOREIGN KEY ([CNA_UserID]) REFERENCES [dim].[User] ([UserID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_Coded_User] FOREIGN KEY ([Coded_UserID]) REFERENCES [dim].[User] ([UserID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_Member] FOREIGN KEY ([MemberID]) REFERENCES [dim].[Member] ([MemberID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_Project] FOREIGN KEY ([ProjectID]) REFERENCES [dim].[ADVProject] ([ProjectID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_QA_User] FOREIGN KEY ([QA_UserID]) REFERENCES [dim].[User] ([UserID])
GO
ALTER TABLE [fact].[Suspect] ADD CONSTRAINT [FK_Suspect_Scanned_User] FOREIGN KEY ([Scanned_UserID]) REFERENCES [dim].[User] ([UserID])
GO
