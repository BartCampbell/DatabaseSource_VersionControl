CREATE TABLE [DbUtility].[CopyTables]
(
[DmCopyConfigID] [int] NOT NULL,
[DmCopyTableID] [int] NOT NULL,
[PrimaryGuidColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryIdColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableAlias] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[WhereColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WhereCondition] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[CopyTables] ADD CONSTRAINT [CK_CopyTables_PrimaryColumns] CHECK (([PrimaryGuidColumn] IS NOT NULL AND [PrimaryIdColumn] IS NOT NULL OR [PrimaryGuidColumn] IS NULL AND [PrimaryIdColumn] IS NULL))
GO
ALTER TABLE [DbUtility].[CopyTables] ADD CONSTRAINT [PK_CopyTables] PRIMARY KEY CLUSTERED  ([DmCopyTableID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CopyTables_TableAlias] ON [DbUtility].[CopyTables] ([DmCopyConfigID], [TableAlias]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Primary Columns must both be set or both be empty.', 'SCHEMA', N'DbUtility', 'TABLE', N'CopyTables', 'CONSTRAINT', N'CK_CopyTables_PrimaryColumns'
GO
