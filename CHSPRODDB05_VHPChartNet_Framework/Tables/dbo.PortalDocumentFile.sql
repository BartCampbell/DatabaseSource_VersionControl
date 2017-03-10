CREATE TABLE [dbo].[PortalDocumentFile]
(
[PortalDocumentFileID] [uniqueidentifier] NOT NULL,
[PortalDocumentID] [uniqueidentifier] NOT NULL,
[DocumentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DocumentImage] [image] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentFile] ADD CONSTRAINT [PK_PortalDocumentFile] PRIMARY KEY CLUSTERED  ([PortalDocumentFileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentFile] ADD CONSTRAINT [FK_PortalDocumentFile_PortalDocument] FOREIGN KEY ([PortalDocumentID]) REFERENCES [dbo].[PortalDocument] ([PortalDocumentID])
GO
