CREATE TABLE [dbo].[clusternode]
(
[NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[NODE_STATE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIMESTAMP] [numeric] (18, 0) NULL,
[IP] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CACHE_LISTENER_PORT] [numeric] (18, 0) NULL,
[NODE_BUILD_NUMBER] [numeric] (18, 0) NULL,
[NODE_VERSION] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clusternode] ADD CONSTRAINT [PK_clusternode] PRIMARY KEY CLUSTERED  ([NODE_ID]) ON [PRIMARY]
GO
