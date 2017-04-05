CREATE TABLE [DbUtility].[CopyParameterRelationships]
(
[DmCopyParamID] [int] NOT NULL,
[DmCopyParamRelID] [int] NOT NULL IDENTITY(1, 1),
[DmCopyTableID] [int] NOT NULL,
[TableColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[CopyParameterRelationships] ADD CONSTRAINT [PK_CopyParameterRelationships] PRIMARY KEY CLUSTERED  ([DmCopyParamRelID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CopyParameterRelationships] ON [DbUtility].[CopyParameterRelationships] ([DmCopyTableID], [DmCopyParamID]) ON [PRIMARY]
GO
