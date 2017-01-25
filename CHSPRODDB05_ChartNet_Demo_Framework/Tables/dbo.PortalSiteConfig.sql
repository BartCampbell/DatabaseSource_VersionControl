CREATE TABLE [dbo].[PortalSiteConfig]
(
[PortalSiteConfigID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteConfig_PortalSiteConfigID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteConfig_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PropertyKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PropertyValue] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteConfig] ADD CONSTRAINT [PK_PortalSiteConfig] PRIMARY KEY CLUSTERED  ([PortalSiteConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteConfig] ADD CONSTRAINT [FK_PortalSiteConfig_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
