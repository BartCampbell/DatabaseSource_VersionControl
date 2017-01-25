CREATE TABLE [dbo].[PortalFolder]
(
[PortalFolderID] [uniqueidentifier] NOT NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalFolder_SiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PortalFolderParentID] [uniqueidentifier] NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PortalFolder_IsDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalFolder] ADD CONSTRAINT [PK_PortalFolder] PRIMARY KEY CLUSTERED  ([PortalFolderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalFolder] WITH NOCHECK ADD CONSTRAINT [FK_PortalFolder_PortalFolder] FOREIGN KEY ([PortalFolderParentID]) REFERENCES [dbo].[PortalFolder] ([PortalFolderID])
GO
ALTER TABLE [dbo].[PortalFolder] ADD CONSTRAINT [FK_PortalFolder_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
