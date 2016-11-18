CREATE TABLE [dbo].[nodeindexcounter]
(
[ID] [numeric] (18, 0) NOT NULL,
[NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SENDING_NODE_ID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[INDEX_OPERATION_ID] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nodeindexcounter] ADD CONSTRAINT [PK_nodeindexcounter] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [node_id_idx] ON [dbo].[nodeindexcounter] ([NODE_ID], [SENDING_NODE_ID]) ON [PRIMARY]
GO
