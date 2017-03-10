CREATE TABLE [dbo].[PortalDocument]
(
[PortalDocumentID] [uniqueidentifier] NOT NULL,
[PortalDocumentFolderID] [uniqueidentifier] NOT NULL,
[DocumentName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorUserID] [uniqueidentifier] NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL,
[LastUpdateUserID] [uniqueidentifier] NOT NULL,
[PortalDocumentStatusID] [uniqueidentifier] NULL,
[DocumentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalDocumentTypeID] [uniqueidentifier] NOT NULL,
[PortalDocumentFileID] [uniqueidentifier] NULL,
[DocumentRevision] [int] NOT NULL,
[FileSize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSizeInBytes] [int] NOT NULL CONSTRAINT [DF_PortalDocument_FileSizeInBytes] DEFAULT ((0)),
[IsDeleted] [bit] NOT NULL CONSTRAINT [DF_PortalDocument_IsDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocument] ADD CONSTRAINT [PortalDocument_PK] PRIMARY KEY CLUSTERED  ([PortalDocumentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocument] ADD CONSTRAINT [PortalDocumentFolder_PortalDocument_FK1] FOREIGN KEY ([PortalDocumentFolderID]) REFERENCES [dbo].[PortalDocumentFolder] ([PortalDocumentFolderID])
GO
ALTER TABLE [dbo].[PortalDocument] ADD CONSTRAINT [PortalDocumentStatus_PortalDocument_FK1] FOREIGN KEY ([PortalDocumentStatusID]) REFERENCES [dbo].[PortalDocumentStatus] ([PortalDocumentStatusID])
GO
ALTER TABLE [dbo].[PortalDocument] WITH NOCHECK ADD CONSTRAINT [PortalDocumentType_PortalDocument_FK1] FOREIGN KEY ([PortalDocumentTypeID]) REFERENCES [dbo].[PortalDocumentType] ([PortalDocumentTypeID])
GO
