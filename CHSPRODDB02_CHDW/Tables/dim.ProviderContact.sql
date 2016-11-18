CREATE TABLE [dim].[ProviderContact]
(
[ProviderContactID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[Phone] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvancePhone] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceFax] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderContact_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderContact_LastUpdate] DEFAULT (getdate()),
[EmailAddress] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderContact] ADD CONSTRAINT [PK_ProviderContact] PRIMARY KEY CLUSTERED  ([ProviderContactID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_ProviderContact_17_1012198656__K3_K4_K2_1] ON [dim].[ProviderContact] ([Phone], [Fax], [ProviderID]) INCLUDE ([ProviderContactID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1012198656_2_3] ON [dim].[ProviderContact] ([ProviderID], [Phone])
GO
ALTER TABLE [dim].[ProviderContact] ADD CONSTRAINT [FK_ProviderContact_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
