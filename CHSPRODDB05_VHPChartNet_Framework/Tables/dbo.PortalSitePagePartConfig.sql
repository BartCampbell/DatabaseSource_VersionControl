CREATE TABLE [dbo].[PortalSitePagePartConfig]
(
[PortalSitePagePartConfigID] [uniqueidentifier] NOT NULL,
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[PropertyKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PropertyValue] [varchar] (7000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartConfig] ADD CONSTRAINT [PK_PortalSitePagePartConfig] PRIMARY KEY CLUSTERED  ([PortalSitePagePartConfigID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartConfig] WITH NOCHECK ADD CONSTRAINT [FK_PortalSitePagePartConfig_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
