CREATE TABLE [dbo].[PortalMenu]
(
[PortalMenuID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalMenu_MenuID] DEFAULT (newid()),
[PortalMenuGroupID] [uniqueidentifier] NOT NULL,
[PortalMenuParentID] [uniqueidentifier] NULL,
[MenuText] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BreadCrumb] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalSitePageID] [uniqueidentifier] NULL,
[PortalLinkID] [uniqueidentifier] NULL,
[SortOrder] [smallint] NOT NULL CONSTRAINT [DF_PortalMenu_SortOrder] DEFAULT ((0)),
[IsSeparator] [bit] NOT NULL CONSTRAINT [DF_PortalMenu_IsSeparator] DEFAULT ((0)),
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_PortalMenu_Enabled] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMenu] ADD CONSTRAINT [PK_PortalMenu] PRIMARY KEY CLUSTERED  ([PortalMenuID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMenu] WITH NOCHECK ADD CONSTRAINT [FK_PortalMenu_PortalLink] FOREIGN KEY ([PortalLinkID]) REFERENCES [dbo].[PortalLink] ([PortalLinkID])
GO
ALTER TABLE [dbo].[PortalMenu] WITH NOCHECK ADD CONSTRAINT [FK_PortalMenu_PortalMenu] FOREIGN KEY ([PortalMenuParentID]) REFERENCES [dbo].[PortalMenu] ([PortalMenuID])
GO
ALTER TABLE [dbo].[PortalMenu] ADD CONSTRAINT [FK_PortalMenu_PortalMenuGroup] FOREIGN KEY ([PortalMenuGroupID]) REFERENCES [dbo].[PortalMenuGroup] ([PortalMenuGroupID])
GO
ALTER TABLE [dbo].[PortalMenu] WITH NOCHECK ADD CONSTRAINT [FK_PortalMenu_PortalSitePage] FOREIGN KEY ([PortalSitePageID]) REFERENCES [dbo].[PortalSitePage] ([PortalSitePageID])
GO
