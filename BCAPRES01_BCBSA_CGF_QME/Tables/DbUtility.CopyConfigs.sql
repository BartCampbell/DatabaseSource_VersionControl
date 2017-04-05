CREATE TABLE [DbUtility].[CopyConfigs]
(
[Descr] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DmCopyConfigID] [int] NOT NULL,
[KeyGuidColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyIdColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyTableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KeyTableSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[CopyConfigs] ADD CONSTRAINT [PK_CopyConfigs] PRIMARY KEY CLUSTERED  ([DmCopyConfigID]) ON [PRIMARY]
GO
