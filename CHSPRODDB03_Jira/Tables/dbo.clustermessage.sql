CREATE TABLE [dbo].[clustermessage]
(
[ID] [numeric] (18, 0) NOT NULL,
[SOURCE_NODE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESTINATION_NODE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CLAIMED_BY_NODE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MESSAGE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MESSAGE_TIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[clustermessage] ADD CONSTRAINT [PK_clustermessage] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [source_destination_node_idx] ON [dbo].[clustermessage] ([SOURCE_NODE], [DESTINATION_NODE]) ON [PRIMARY]
GO
