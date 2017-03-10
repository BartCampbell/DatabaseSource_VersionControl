CREATE TABLE [dbo].[FaxFiles]
(
[CanDelete] [bit] NOT NULL CONSTRAINT [DF_FaxFiles_CanDelete] DEFAULT ((0)),
[FaxFileGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FaxFiles_FaxFileGuid] DEFAULT (newid()),
[FaxFileID] [int] NOT NULL IDENTITY(1, 1),
[FaxID] [int] NOT NULL,
[FileExtension] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePath] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileSize] [bigint] NOT NULL,
[MimeType] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortOrder] [int] NOT NULL CONSTRAINT [DF_FaxFiles_SortOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxFiles] ADD CONSTRAINT [PK_FaxFiles] PRIMARY KEY CLUSTERED  ([FaxFileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxFiles] ADD CONSTRAINT [FK_FaxFiles_Faxes] FOREIGN KEY ([FaxID]) REFERENCES [dbo].[Faxes] ([FaxID])
GO
