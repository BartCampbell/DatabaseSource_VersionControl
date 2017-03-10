CREATE TABLE [dbo].[PortalSiteObjectOwner]
(
[ObjectID] [uniqueidentifier] NOT NULL,
[ParentObjectID] [uniqueidentifier] NULL,
[OwnerID] [uniqueidentifier] NOT NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteObjectOwner_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PortalSiteObjectOwner_CreateDate] DEFAULT (getdate()),
[InheritFromParent] [bit] NOT NULL CONSTRAINT [DF_PortalSiteObjectOwner_IsInheritDisabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectOwner] ADD CONSTRAINT [PK_PortalSiteObjectOwner] PRIMARY KEY CLUSTERED  ([ObjectID]) ON [PRIMARY]
GO
