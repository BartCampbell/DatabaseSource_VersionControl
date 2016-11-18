CREATE TABLE [dim].[Provider]
(
[ProviderID] [int] NOT NULL IDENTITY(1, 1),
[CentauriProviderID] [int] NOT NULL,
[LastName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prefix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suffix] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TINName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_Provider_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_Provider_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[Provider] ADD CONSTRAINT [PK_Provider] PRIMARY KEY CLUSTERED  ([ProviderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPI] ON [dim].[Provider] ([NPI]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ProviderID] ON [dim].[Provider] ([ProviderID]) INCLUDE ([CentauriProviderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_Provider_17_1534628510__K1_K2] ON [dim].[Provider] ([ProviderID], [CentauriProviderID]) ON [PRIMARY]
GO
