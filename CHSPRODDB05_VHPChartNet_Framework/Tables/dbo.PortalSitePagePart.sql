CREATE TABLE [dbo].[PortalSitePagePart]
(
[PortalSitePagePartID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSitePagePart_ID] DEFAULT (newid()),
[PortalSitePageID] [uniqueidentifier] NOT NULL,
[PortalModuleID] [uniqueidentifier] NOT NULL,
[PortalSharedContentID] [uniqueidentifier] NULL,
[Container] [smallint] NOT NULL CONSTRAINT [DF_PortalSitePagePart_Container] DEFAULT ((0)),
[LoadOrder] [smallint] NOT NULL CONSTRAINT [DF_PortalSitePagePart_LoadOrder] DEFAULT ((0)),
[Style] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePagePart_Style] DEFAULT (''),
[CssClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePagePart_CssClass] DEFAULT (''),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PortalSitePagePart_IsDeleted] DEFAULT ((0)),
[PublishedStatus] [tinyint] NOT NULL CONSTRAINT [DF_PortalSitePagePart_PublishedStatus] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePart] ADD CONSTRAINT [PK_PortalSitePagePart] PRIMARY KEY CLUSTERED  ([PortalSitePagePartID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePart] ADD CONSTRAINT [FK_PortalSitePagePart_PortalModule] FOREIGN KEY ([PortalModuleID]) REFERENCES [dbo].[PortalModule] ([PortalModuleID])
GO
ALTER TABLE [dbo].[PortalSitePagePart] ADD CONSTRAINT [FK_PortalSitePagePart_PortalSharedContent] FOREIGN KEY ([PortalSharedContentID]) REFERENCES [dbo].[PortalSharedContent] ([PortalSharedContentID])
GO
ALTER TABLE [dbo].[PortalSitePagePart] WITH NOCHECK ADD CONSTRAINT [FK_PortalSitePagePart_PortalSitePage] FOREIGN KEY ([PortalSitePageID]) REFERENCES [dbo].[PortalSitePage] ([PortalSitePageID])
GO
