CREATE TABLE [dbo].[PortalSiteHost]
(
[PortalSiteHostID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteHost_ID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteHost_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VirtualDirectory] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalSiteHost_IsDefault] DEFAULT ((0)),
[Port] [int] NOT NULL CONSTRAINT [DF_PortalSiteHost_Port] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteHost] ADD CONSTRAINT [PK_PortalSiteHost] PRIMARY KEY CLUSTERED  ([PortalSiteHostID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteHost] ADD CONSTRAINT [FK_PortalSiteHost_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
