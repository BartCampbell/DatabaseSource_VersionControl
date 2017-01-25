CREATE TABLE [dbo].[PortalRole]
(
[PortalRoleID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalRole_PortalRoleID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalRole_SiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalRole] ADD CONSTRAINT [PK_PortalRole] PRIMARY KEY CLUSTERED  ([PortalRoleID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalRole] ADD CONSTRAINT [FK_PortalRole_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
