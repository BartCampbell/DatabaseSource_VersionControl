CREATE TABLE [dbo].[FaxLogSubmissions]
(
[CreatedDate] [datetime] NULL CONSTRAINT [DF_FaxLogSubmissions_CreatedDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_FaxLogSubmissions_CreatedUser] DEFAULT (suser_sname()),
[FaxLogDocID] [smallint] NOT NULL,
[FaxLogDocFileID] [smallint] NOT NULL,
[FaxLogID] [int] NOT NULL,
[FaxLogSubGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FaxLogSubmissions_FaxLogSubGuid] DEFAULT (newid()),
[FaxLogSubID] [int] NOT NULL IDENTITY(1, 1),
[FileExtension] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilePath] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPrepared] [bit] NOT NULL CONSTRAINT [DF_FaxLogSubmissions_IsPrepared] DEFAULT ((0)),
[IsReady] [bit] NOT NULL CONSTRAINT [DF_FaxLogSubmissions_IsReady] DEFAULT ((0)),
[PreparedDate] [datetime] NULL,
[ReadyDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogSubmissions] ADD CONSTRAINT [PK_FaxLogSubmissions] PRIMARY KEY CLUSTERED  ([FaxLogSubID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLogSubmissions_FaxLogDocFileID] ON [dbo].[FaxLogSubmissions] ([FaxLogDocFileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLogSubmissions_FaxLogDocID] ON [dbo].[FaxLogSubmissions] ([FaxLogDocID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FaxLogSubmissions_FaxLogID] ON [dbo].[FaxLogSubmissions] ([FaxLogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FaxLogSubmissions_FaxLogSubGuid] ON [dbo].[FaxLogSubmissions] ([FaxLogSubGuid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxLogSubmissions] ADD CONSTRAINT [FK_FaxLogSubmissions_FaxLog] FOREIGN KEY ([FaxLogID]) REFERENCES [dbo].[FaxLog] ([FaxLogID])
GO
ALTER TABLE [dbo].[FaxLogSubmissions] ADD CONSTRAINT [FK_FaxLogSubmissions_FaxLogDocument] FOREIGN KEY ([FaxLogDocID]) REFERENCES [dbo].[FaxLogDocument] ([FaxLogDocID])
GO
ALTER TABLE [dbo].[FaxLogSubmissions] ADD CONSTRAINT [FK_FaxLogSubmissions_FaxLogDocumentFiles] FOREIGN KEY ([FaxLogDocFileID]) REFERENCES [dbo].[FaxLogDocumentFiles] ([FaxLogDocFileID])
GO
