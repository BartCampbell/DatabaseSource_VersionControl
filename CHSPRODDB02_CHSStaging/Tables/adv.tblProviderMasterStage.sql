CREATE TABLE [adv].[tblProviderMasterStage]
(
[ProviderMaster_PK] [bigint] NOT NULL,
[Provider_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [smalldatetime] NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblProvid__LoadD__56365142] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderMasterHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblProviderMasterStage] ADD CONSTRAINT [PK_tblProviderMasterStage] PRIMARY KEY CLUSTERED  ([ProviderMaster_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
