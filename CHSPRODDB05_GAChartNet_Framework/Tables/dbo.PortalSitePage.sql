CREATE TABLE [dbo].[PortalSitePage]
(
[PortalSitePageID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSitePage_PortalSitePageID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSitePage_SiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PortalFolderID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Alias] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetUrl] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegExpression] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePage_IsRegEx] DEFAULT ((0)),
[IsSslRequired] [bit] NOT NULL CONSTRAINT [DF_PortalSitePage_IsSslRequired] DEFAULT ((0)),
[IsInMenu] [bit] NOT NULL CONSTRAINT [DF_PortalSitePage_IsInMenu] DEFAULT ((0)),
[IsEditLocked] [bit] NOT NULL CONSTRAINT [DF_PortalSitePage_IsEditLocked] DEFAULT ((0)),
[IsKeepAliveOn] [bit] NOT NULL CONSTRAINT [DF_PortalSitePage_UseKeepAlive] DEFAULT ((0)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PortalSitePage_IsDeleted] DEFAULT ((0)),
[BreadCrumb] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Skin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePage_Skin] DEFAULT ('SiteDefault'),
[Layout] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePage_Layout] DEFAULT ('SiteDefault'),
[Theme] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PortalSitePage_Theme] DEFAULT ('SiteDefault'),
[MetaDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetaKeys] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeftSideWidth] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RightSideWidth] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmartNavigationState] [smallint] NULL CONSTRAINT [DF__Portal__Smart__1FA39FB9] DEFAULT ((0)),
[EncodingType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseSiteHeader] [smallint] NULL CONSTRAINT [DF_PortalSitePage_UseSiteHeader] DEFAULT ((0)),
[UseSiteFooter] [smallint] NULL CONSTRAINT [DF_PortalSitePage_UseSiteFooter] DEFAULT ((0)),
[UseSiteLeftBar] [smallint] NULL CONSTRAINT [DF_PortalSitePage_UseSiteLeftBar] DEFAULT ((0)),
[UseSiteRightBar] [smallint] NULL CONSTRAINT [DF_PortalSitePage_UseSiteRightBar] DEFAULT ((0)),
[UseSiteBreadcrumbs] [smallint] NULL CONSTRAINT [DF_PortalSitePage_UseSiteBreadcrumbs] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePage] ADD CONSTRAINT [PK_PortalSitePage] PRIMARY KEY CLUSTERED  ([PortalSitePageID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePage] WITH NOCHECK ADD CONSTRAINT [FK_PortalSitePage_PortalFolder] FOREIGN KEY ([PortalFolderID]) REFERENCES [dbo].[PortalFolder] ([PortalFolderID])
GO
ALTER TABLE [dbo].[PortalSitePage] WITH NOCHECK ADD CONSTRAINT [FK_PortalSitePage_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
