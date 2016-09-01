CREATE TABLE [dbo].[tblRAPSData]
(
[RAPSData_PK] [bigint] NOT NULL IDENTITY(1, 1),
[Member_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [date] NULL,
[DOS_Thru] [date] NULL,
[CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[IsICD10] [bit] NULL,
[TransactionDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRAPSData] ADD CONSTRAINT [PK_tblRAPSData] PRIMARY KEY CLUSTERED  ([RAPSData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblRAPSDataICD9] ON [dbo].[tblRAPSData] ([DiagnosisCode]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblRAPSDataMember] ON [dbo].[tblRAPSData] ([Member_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblRAPSDataProvider] ON [dbo].[tblRAPSData] ([ProviderMaster_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
