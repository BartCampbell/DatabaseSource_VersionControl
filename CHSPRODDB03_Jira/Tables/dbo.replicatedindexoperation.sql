CREATE TABLE [dbo].[replicatedindexoperation]
(
[ID] [numeric] (18, 0) NOT NULL,
[INDEX_TIME] [datetime] NULL,
[NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[AFFECTED_INDEX] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[AFFECTED_IDS] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[OPERATION] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FILENAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[replicatedindexoperation] ADD CONSTRAINT [PK_replicatedindexoperation] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [node_operation_idx] ON [dbo].[replicatedindexoperation] ([NODE_ID], [AFFECTED_INDEX], [OPERATION], [INDEX_TIME]) ON [PRIMARY]
GO
