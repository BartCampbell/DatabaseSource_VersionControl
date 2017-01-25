CREATE TABLE [Log].[SourceObjects]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SqlObjectID] AS (object_id(([ObjectSchema]+'.')+[ObjectName])),
[SqlSchemaID] AS (schema_id([ObjectSchema])),
[SrcObjectGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SourceObjects_SrcObjGuid] DEFAULT (newid()),
[SrcObjectID] [smallint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Log].[SourceObjects] ADD CONSTRAINT [PK_Log_SourceObjects] PRIMARY KEY CLUSTERED  ([SrcObjectID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_SourceObjects] ON [Log].[SourceObjects] ([SrcObjectGuid]) ON [PRIMARY]
GO
