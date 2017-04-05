CREATE TABLE [DbUtility].[SplitDbObjectTypes]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectTypeID] [tinyint] NOT NULL,
[SortOrder] [tinyint] NOT NULL,
[SysObjectType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TSqlName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[SplitDbObjectTypes] ADD CONSTRAINT [PK_DbUtility_SplitDbObjectTypes] PRIMARY KEY CLUSTERED  ([ObjectTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DbUtility_SysObjectTypes] ON [DbUtility].[SplitDbObjectTypes] ([SysObjectType]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'DbUtility', 'TABLE', N'SplitDbObjectTypes', NULL, NULL
GO
