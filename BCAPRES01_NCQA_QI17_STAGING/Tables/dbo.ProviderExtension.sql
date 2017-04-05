CREATE TABLE [dbo].[ProviderExtension]
(
[ProviderID] [int] NOT NULL,
[ExtensionData] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderExtension] ADD CONSTRAINT [actProviderExtension_PK] PRIMARY KEY CLUSTERED  ([ProviderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProviderExtension] ADD CONSTRAINT [actProvider_ProviderExtension_FK1] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
GO
ALTER TABLE [dbo].[ProviderExtension] ADD CONSTRAINT [FK_ProviderExtension_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]) ON DELETE CASCADE
GO
