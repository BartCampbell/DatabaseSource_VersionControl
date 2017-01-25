CREATE TABLE [Dictionary].[ObjectColumns]
(
[ColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForeignKeyGuid] [uniqueidentifier] NULL,
[FriendlyName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ObjectColumnGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectColumns_ObjectColumnGuid] DEFAULT (newid()),
[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dictionary].[ObjectColumns] ADD CONSTRAINT [PK_Dictionary_ObjectColumns] PRIMARY KEY CLUSTERED  ([ObjectSchema], [ObjectName], [ColumnName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dictionary_ObjectColumns_ObjectColumnGuid] ON [Dictionary].[ObjectColumns] ([ObjectColumnGuid]) ON [PRIMARY]
GO
ALTER TABLE [Dictionary].[ObjectColumns] ADD CONSTRAINT [FK_Dictionary_Objects_ObjectColumns] FOREIGN KEY ([ObjectSchema], [ObjectName]) REFERENCES [Dictionary].[Objects] ([ObjectSchema], [ObjectName])
GO
