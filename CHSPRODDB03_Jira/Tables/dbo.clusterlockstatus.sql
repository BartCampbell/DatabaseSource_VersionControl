CREATE TABLE [dbo].[clusterlockstatus]
(
[ID] [numeric] (18, 0) NOT NULL,
[LOCK_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LOCKED_BY_NODE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPDATE_TIME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clusterlockstatus] ADD CONSTRAINT [PK_clusterlockstatus] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cluster_lock_name_idx] ON [dbo].[clusterlockstatus] ([LOCK_NAME]) ON [PRIMARY]
GO
