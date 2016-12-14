CREATE TABLE [adv].[tblProviderOfficeStatusStage]
(
[Project_PK] [smallint] NOT NULL,
[ProviderOffice_PK] [bigint] NOT NULL,
[OfficeIssueStatus] [tinyint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblProvid__LoadD__1FBA4500] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderOfficeStatusStage] ADD CONSTRAINT [PK_tblProviderOfficeStatus] PRIMARY KEY CLUSTERED  ([Project_PK], [ProviderOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
