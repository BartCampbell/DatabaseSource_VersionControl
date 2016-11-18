CREATE TABLE [dbo].[reindex_request]
(
[ID] [numeric] (18, 0) NOT NULL,
[TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REQUEST_TIME] [datetime] NULL,
[START_TIME] [datetime] NULL,
[COMPLETION_TIME] [datetime] NULL,
[STATUS] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[EXECUTION_NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[QUERY] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[reindex_request] ADD CONSTRAINT [PK_reindex_request] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
