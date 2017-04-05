CREATE TABLE [Cloud].[FileFields]
(
[CreatedBy] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_FileFields_CreatedBy] DEFAULT (suser_sname()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_FileFields_CreatedDate] DEFAULT (getdate()),
[CreatedSpId] [int] NOT NULL CONSTRAINT [DF_FileFields_CreatedSpId] DEFAULT (@@spid),
[FieldName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileFieldGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileFields_FileFieldGuid] DEFAULT (newid()),
[FileFieldID] [int] NOT NULL IDENTITY(1, 1),
[FileObjectID] [int] NOT NULL,
[FileTranslatorID] [smallint] NULL,
[info] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsShown] [bit] NOT NULL CONSTRAINT [DF_FileFields_IsShown] DEFAULT ((1)),
[SourceColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileFields] ADD CONSTRAINT [PK_FileFields] PRIMARY KEY CLUSTERED  ([FileFieldID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFields_FieldName] ON [Cloud].[FileFields] ([FieldName], [FileObjectID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFields_FileFieldGuid] ON [Cloud].[FileFields] ([FileFieldGuid]) ON [PRIMARY]
GO
