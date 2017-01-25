CREATE TABLE [dbo].[PortalSiteObjectType]
(
[PortalSiteObjectTypeID] [tinyint] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssemblyName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectType] ADD CONSTRAINT [PK_PortalSiteObjectType] PRIMARY KEY CLUSTERED  ([PortalSiteObjectTypeID]) ON [PRIMARY]
GO
