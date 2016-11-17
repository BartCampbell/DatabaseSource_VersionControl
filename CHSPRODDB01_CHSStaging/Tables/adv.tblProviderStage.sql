CREATE TABLE [adv].[tblProviderStage]
(
[Provider_PK] [bigint] NOT NULL,
[ProviderMaster_PK] [bigint] NULL,
[ProviderOffice_PK] [bigint] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblProvid__LoadD__745BB106] DEFAULT (getdate()),
[CPI] [bigint] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderStage] ADD CONSTRAINT [PK_tblProviderStage] PRIMARY KEY CLUSTERED  ([Provider_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
