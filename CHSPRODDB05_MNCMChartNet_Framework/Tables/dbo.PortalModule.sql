CREATE TABLE [dbo].[PortalModule]
(
[PortalModuleID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalModule_PortalModuleID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalModule_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TemplateName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AssemblyName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsContentControl] [bit] NOT NULL CONSTRAINT [DF_PortalModule_IsContentControl] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalModule] ADD CONSTRAINT [PK_PortalModule] PRIMARY KEY CLUSTERED  ([PortalModuleID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalModule] ADD CONSTRAINT [FK_PortalModule_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
