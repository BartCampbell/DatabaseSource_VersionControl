CREATE TABLE [DbUtility].[SplitConfigs]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DmSplitConfigID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[SplitConfigs] ADD CONSTRAINT [PK_SplitConfigs] PRIMARY KEY CLUSTERED  ([DmSplitConfigID]) ON [PRIMARY]
GO
