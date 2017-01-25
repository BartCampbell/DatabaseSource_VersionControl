CREATE TABLE [dbo].[PortalSiteObjectSecurityAction]
(
[PortalSiteObjectSecurityActionID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteObjectSecurityAction_ID] DEFAULT (newid()),
[PortalSiteObjectSecurityID] [uniqueidentifier] NOT NULL,
[SecurityAction] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActionPermission] [tinyint] NOT NULL CONSTRAINT [DF_PortalSiteObjectSecurityAction_ActionPermission] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectSecurityAction] ADD CONSTRAINT [PK_PortalSiteObjectSecurityAction] PRIMARY KEY CLUSTERED  ([PortalSiteObjectSecurityActionID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectSecurityAction] ADD CONSTRAINT [FK_PortalSiteObjectSecurityAction_PortalSiteObjectSecurity] FOREIGN KEY ([PortalSiteObjectSecurityID]) REFERENCES [dbo].[PortalSiteObjectSecurity] ([PortalSiteObjectSecurityID])
GO
