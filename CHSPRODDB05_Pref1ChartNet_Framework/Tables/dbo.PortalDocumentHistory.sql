CREATE TABLE [dbo].[PortalDocumentHistory]
(
[PortalDocumentHistoryID] [uniqueidentifier] NOT NULL,
[PortalDocumentID] [uniqueidentifier] NOT NULL,
[DocumentName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthorUserID] [uniqueidentifier] NOT NULL,
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL,
[LastUpdateUserID] [uniqueidentifier] NOT NULL,
[PortalDocumentStatusID] [uniqueidentifier] NULL,
[DocumentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalDocumentTypeID] [uniqueidentifier] NOT NULL,
[PortalDocumentFileID] [uniqueidentifier] NOT NULL,
[DocumentRevision] [int] NOT NULL,
[FileSize] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileSizeInBytes] [int] NOT NULL CONSTRAINT [DF_PortalDocumentHistory_FileSizeInBytes] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentHistory] ADD CONSTRAINT [PortalDocumentHistory_PK] PRIMARY KEY CLUSTERED  ([PortalDocumentHistoryID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentHistory] ADD CONSTRAINT [PortalDocument_PortalDocumentHistory_FK1] FOREIGN KEY ([PortalDocumentID]) REFERENCES [dbo].[PortalDocument] ([PortalDocumentID])
GO
ALTER TABLE [dbo].[PortalDocumentHistory] ADD CONSTRAINT [PortalDocumentStatus_PortalDocumentHistory_FK1] FOREIGN KEY ([PortalDocumentStatusID]) REFERENCES [dbo].[PortalDocumentStatus] ([PortalDocumentStatusID])
GO
ALTER TABLE [dbo].[PortalDocumentHistory] WITH NOCHECK ADD CONSTRAINT [PortalDocumentType_PortalDocumentHistory_FK1] FOREIGN KEY ([PortalDocumentTypeID]) REFERENCES [dbo].[PortalDocumentType] ([PortalDocumentTypeID])
GO
