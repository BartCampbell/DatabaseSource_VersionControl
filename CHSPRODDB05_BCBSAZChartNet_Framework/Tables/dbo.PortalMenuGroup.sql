CREATE TABLE [dbo].[PortalMenuGroup]
(
[PortalMenuGroupID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalMenuGroup_PortalMenuGroupID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalMenuGroup_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PortalMenuGroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalMenuGroupKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalMenuGroupDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalMenuGroup_IsDefault] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMenuGroup] ADD CONSTRAINT [PK_PortalMenuGroup] PRIMARY KEY CLUSTERED  ([PortalMenuGroupID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMenuGroup] ADD CONSTRAINT [FK_PortalMenuGroup_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
