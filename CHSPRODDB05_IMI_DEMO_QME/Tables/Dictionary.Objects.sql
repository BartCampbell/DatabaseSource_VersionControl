CREATE TABLE [Dictionary].[Objects]
(
[BitObjectCtgies] [bigint] NOT NULL CONSTRAINT [DF_Objects_BitObjectCtgies] DEFAULT ((0)),
[Descr] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DataDictionary_ObjectGuid] DEFAULT (newid()),
[ObjectID] AS (object_id((quotename([ObjectSchema])+'.')+quotename([ObjectName]))),
[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dictionary].[Objects] ADD CONSTRAINT [PK_Dictionary_Objects] PRIMARY KEY CLUSTERED  ([ObjectSchema], [ObjectName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dictionary_Objects_ObjectGuid] ON [Dictionary].[Objects] ([ObjectGuid]) ON [PRIMARY]
GO
