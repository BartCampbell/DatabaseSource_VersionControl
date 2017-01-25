CREATE TABLE [dbo].[PortalSiteObjectSecurity]
(
[PortalSiteObjectSecurityID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSiteObjectSecurity_ID] DEFAULT (newid()),
[ObjectID] [uniqueidentifier] NOT NULL,
[SecurityID] [uniqueidentifier] NOT NULL,
[SecurityType] [tinyint] NULL CONSTRAINT [DF_PortalSiteObjectSecurity3_SecurityType] DEFAULT ((0)),
[SecurityName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsOneTimePasswordAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalSiteObjectSecurity_IsOneTimePasswordAllowed] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectSecurity] ADD CONSTRAINT [PK_PortalSiteObjectSecurity] PRIMARY KEY CLUSTERED  ([PortalSiteObjectSecurityID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSiteObjectSecurity] WITH NOCHECK ADD CONSTRAINT [FK_PortalSiteObjectSecurity_PortalSiteObject] FOREIGN KEY ([ObjectID]) REFERENCES [dbo].[PortalSiteObject] ([ObjectID])
GO
