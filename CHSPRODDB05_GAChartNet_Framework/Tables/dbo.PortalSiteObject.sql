CREATE TABLE [dbo].[PortalSiteObject]
(
[ObjectID] [uniqueidentifier] NOT NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteObject_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PortalSiteObjectTypeID] [tinyint] NULL,
[ObjectName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObject] ADD CONSTRAINT [PK_PortalSiteObject] PRIMARY KEY CLUSTERED  ([ObjectID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObject] ADD CONSTRAINT [FK_PortalSiteObject_PortalSiteObjectType] FOREIGN KEY ([PortalSiteObjectTypeID]) REFERENCES [dbo].[PortalSiteObjectType] ([PortalSiteObjectTypeID])
GO
