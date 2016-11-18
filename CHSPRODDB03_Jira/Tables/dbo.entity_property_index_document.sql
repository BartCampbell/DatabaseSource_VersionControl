CREATE TABLE [dbo].[entity_property_index_document]
(
[ID] [numeric] (18, 0) NOT NULL,
[PLUGIN_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[MODULE_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPDATED] [datetime] NULL,
[DOCUMENT] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_property_index_document] ADD CONSTRAINT [PK_entity_property_index_docum] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [entpropindexdoc_module] ON [dbo].[entity_property_index_document] ([PLUGIN_KEY], [MODULE_KEY]) ON [PRIMARY]
GO
