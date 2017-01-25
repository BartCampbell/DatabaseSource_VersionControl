CREATE TABLE [DbUtility].[CopyTableRelationships]
(
[AllowOuterJoin] [bit] NOT NULL CONSTRAINT [DF_CopyTableRelationships_AllowOuterJoin] DEFAULT ((0)),
[ChildColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChildDmCopyTableID] [int] NOT NULL,
[DmCopyTableRelID] [int] NOT NULL IDENTITY(1, 1),
[ParentColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ParentDmCopyTableID] [int] NOT NULL,
[RequireReverse] [bit] NOT NULL CONSTRAINT [DF_CopyTableRelationships_RequireReverse] DEFAULT ((0)),
[WhereColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WhereCondition] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[CopyTableRelationships] ADD CONSTRAINT [PK_CopyTableRelationships] PRIMARY KEY CLUSTERED  ([DmCopyTableRelID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CopyTableRelationships] ON [DbUtility].[CopyTableRelationships] ([ChildDmCopyTableID], [ParentDmCopyTableID], [ChildColumn], [ParentColumn]) ON [PRIMARY]
GO
