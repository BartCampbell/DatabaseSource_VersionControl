CREATE TABLE [dim].[ProviderOffice]
(
[ProviderOfficeID] [int] NOT NULL IDENTITY(1, 1),
[ProviderID] [int] NOT NULL,
[CentauriProviderOfficeID] [int] NOT NULL,
[CentauriProviderID] [int] NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderOffice_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderOffice_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [PK_ProviderOffice] PRIMARY KEY CLUSTERED  ([ProviderOfficeID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[ProviderOffice] ADD CONSTRAINT [FK_ProviderOffice_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dim].[Provider] ([ProviderID])
GO
