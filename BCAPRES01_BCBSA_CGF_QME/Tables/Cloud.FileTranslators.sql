CREATE TABLE [Cloud].[FileTranslators]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileTranslatorGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileTranslators_FileTranslatorGuid] DEFAULT (newid()),
[FileTranslatorID] [smallint] NOT NULL IDENTITY(1, 1),
[InFunctionName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InFunctionSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutFunctionName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OutFunctionSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileTranslators] ADD CONSTRAINT [PK_FileTranslators] PRIMARY KEY CLUSTERED  ([FileTranslatorID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileTranslators_FileTranslatorGuid] ON [Cloud].[FileTranslators] ([FileTranslatorGuid]) ON [PRIMARY]
GO
