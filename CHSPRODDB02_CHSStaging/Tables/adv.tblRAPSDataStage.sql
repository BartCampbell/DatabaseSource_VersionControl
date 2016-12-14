CREATE TABLE [adv].[tblRAPSDataStage]
(
[RAPSData_PK] [bigint] NOT NULL,
[Member_PK] [bigint] NOT NULL,
[DiagnosisCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOS_From] [date] NULL,
[DOS_Thru] [date] NULL,
[CPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMaster_PK] [bigint] NULL,
[IsICD10] [bit] NULL,
[TransactionDate] [date] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblRAPSDa__LoadD__56F56B51] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblRAPSDataStage] ADD CONSTRAINT [PK_tblRAPSDataStage] PRIMARY KEY CLUSTERED  ([RAPSData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
