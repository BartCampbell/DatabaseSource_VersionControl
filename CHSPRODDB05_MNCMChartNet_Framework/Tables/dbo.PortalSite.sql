CREATE TABLE [dbo].[PortalSite]
(
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSite_PortalSiteID] DEFAULT (newid()),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsRootSite] [bit] NOT NULL CONSTRAINT [DF_PortalSite_IsRootSite] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSite] ADD CONSTRAINT [PK_PortalSite] PRIMARY KEY CLUSTERED  ([PortalSiteID]) ON [PRIMARY]
GO
