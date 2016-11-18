CREATE TABLE [dim].[ProviderClient]
(
[ProviderClientID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[ClientID] [int] NOT NULL,
[ClientProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordStartDate] [datetime] NULL CONSTRAINT [DF_ProviderClient_RecordStartDate] DEFAULT (getdate()),
[RecordEndDate] [datetime] NULL CONSTRAINT [DF_ProviderClient_RecordEndDate] DEFAULT ('2999-12-31')
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderClient] ADD CONSTRAINT [PK_ProviderClient] PRIMARY KEY CLUSTERED  ([ProviderClientID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ClientID_ProviderID] ON [dim].[ProviderClient] ([ProviderID], [ClientID]) INCLUDE ([ClientProviderID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_532196946_4_3] ON [dim].[ProviderClient] ([ClientProviderID], [ClientID])
GO
ALTER TABLE [dim].[ProviderClient] ADD CONSTRAINT [FK_ProviderClient_Client] FOREIGN KEY ([ClientID]) REFERENCES [dim].[Client] ([ClientID])
GO
ALTER TABLE [dim].[ProviderClient] ADD CONSTRAINT [FK_ProviderClient_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
