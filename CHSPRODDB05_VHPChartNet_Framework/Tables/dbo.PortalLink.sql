CREATE TABLE [dbo].[PortalLink]
(
[PortalLinkID] [uniqueidentifier] NOT NULL,
[PortalFolderID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Url] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Target] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalLink] ADD CONSTRAINT [PK_PortalLink] PRIMARY KEY CLUSTERED  ([PortalLinkID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalLink] WITH NOCHECK ADD CONSTRAINT [FK_PortalLink_PortalFolder] FOREIGN KEY ([PortalFolderID]) REFERENCES [dbo].[PortalFolder] ([PortalFolderID])
GO
