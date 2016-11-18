CREATE TABLE [dbo].[clusternodeheartbeat]
(
[NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[HEARTBEAT_TIME] [numeric] (18, 0) NULL,
[DATABASE_TIME] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clusternodeheartbeat] ADD CONSTRAINT [PK_clusternodeheartbeat] PRIMARY KEY CLUSTERED  ([NODE_ID]) ON [PRIMARY]
GO
