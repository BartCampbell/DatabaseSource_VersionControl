CREATE TABLE [dbo].[reindex_component]
(
[ID] [numeric] (18, 0) NOT NULL,
[REQUEST_ID] [numeric] (18, 0) NULL,
[AFFECTED_INDEX] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_TYPE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reindex_component] ADD CONSTRAINT [PK_reindex_component] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_reindex_component_req_id] ON [dbo].[reindex_component] ([REQUEST_ID]) ON [PRIMARY]
GO
