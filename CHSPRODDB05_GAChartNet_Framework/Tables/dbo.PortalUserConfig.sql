CREATE TABLE [dbo].[PortalUserConfig]
(
[PortalUserConfigID] [uniqueidentifier] NOT NULL,
[PortalUserID] [uniqueidentifier] NOT NULL,
[PropertyKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PropertyValue] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserConfig] ADD CONSTRAINT [PK_PortalUserConfig] PRIMARY KEY CLUSTERED  ([PortalUserConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserConfig] WITH NOCHECK ADD CONSTRAINT [FK_PortalUserConfig_PortalUser] FOREIGN KEY ([PortalUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
