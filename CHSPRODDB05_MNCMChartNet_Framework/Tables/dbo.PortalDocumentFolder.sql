CREATE TABLE [dbo].[PortalDocumentFolder]
(
[PortalDocumentFolderID] [uniqueidentifier] NOT NULL,
[PortalDocumentFolderParentID] [uniqueidentifier] NULL,
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PortalDocumentFolder_IsDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentFolder] ADD CONSTRAINT [PortalDocumentFolder_PK] PRIMARY KEY CLUSTERED  ([PortalDocumentFolderID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentFolder] WITH NOCHECK ADD CONSTRAINT [FK_PortalDocumentFolder_PortalDocumentFolder] FOREIGN KEY ([PortalDocumentFolderParentID]) REFERENCES [dbo].[PortalDocumentFolder] ([PortalDocumentFolderID])
GO
ALTER TABLE [dbo].[PortalDocumentFolder] WITH NOCHECK ADD CONSTRAINT [FK_PortalDocumentFolder_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
