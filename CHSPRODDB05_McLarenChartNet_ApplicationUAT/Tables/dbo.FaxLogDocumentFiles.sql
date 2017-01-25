CREATE TABLE [dbo].[FaxLogDocumentFiles]
(
[FaxLogDocFileID] [smallint] NOT NULL,
[FaxLogDocID] [smallint] NOT NULL,
[FileExtension] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MimeType] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [smallint] NOT NULL,
[SourceName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SoucePath] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogDocumentFiles] ADD CONSTRAINT [PK_FaxLogDocumentFiles] PRIMARY KEY CLUSTERED  ([FaxLogDocFileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLogDocumentFiles_FaxLogDocID] ON [dbo].[FaxLogDocumentFiles] ([FaxLogDocID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FaxLogDocumentFiles_SortOrder] ON [dbo].[FaxLogDocumentFiles] ([FaxLogDocID], [SortOrder]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FaxLogDocumentFiles_SourceName] ON [dbo].[FaxLogDocumentFiles] ([FaxLogDocID], [SourceName], [SourceType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogDocumentFiles] ADD CONSTRAINT [FK_FaxLogDocumentFiles_FaxLogDocument] FOREIGN KEY ([FaxLogDocID]) REFERENCES [dbo].[FaxLogDocument] ([FaxLogDocID])
GO
