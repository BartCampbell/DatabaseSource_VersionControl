CREATE TABLE [dbo].[tblClaimData]
(
[ClaimData_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Member_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [smalldatetime] NULL,
[DOS_Thru] [smalldatetime] NULL,
[CPT] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[IsICD10] [bit] NULL,
[Claim_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimData] ADD CONSTRAINT [PK_tblClaimData] PRIMARY KEY CLUSTERED  ([ClaimData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblClaimDataICD9] ON [dbo].[tblClaimData] ([DiagnosisCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ClaimDataPK_Cols] ON [dbo].[tblClaimData] ([DOS_Thru]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblClaimDataMember] ON [dbo].[tblClaimData] ([Member_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblClaimDataProvider] ON [dbo].[tblClaimData] ([ProviderMaster_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK] ON [dbo].[tblClaimData] ([Suspect_PK]) INCLUDE ([DiagnosisCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimData] ADD CONSTRAINT [FK_tblClaimData_tblSuspect] FOREIGN KEY ([Suspect_PK]) REFERENCES [dbo].[tblSuspect] ([Suspect_PK])
GO
