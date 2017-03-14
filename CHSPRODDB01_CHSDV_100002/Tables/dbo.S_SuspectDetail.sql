CREATE TABLE [dbo].[S_SuspectDetail]
(
[S_SuspectDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[ChaseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContractCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartPriority] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartRec_Date] [smalldatetime] NULL,
[InvoiceExt_Date] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL,
[Channel_PK] [int] NULL,
[EDGEMemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastContacted] [smalldatetime] NULL,
[FollowUp] [smalldatetime] NULL,
[Provider_PK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectDetail] ADD CONSTRAINT [PK_S_SuspectDetail] PRIMARY KEY CLUSTERED  ([S_SuspectDetail_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-080743] ON [dbo].[S_SuspectDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_SuspectDetail] ADD CONSTRAINT [FK_H_Suspect_RK5] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
