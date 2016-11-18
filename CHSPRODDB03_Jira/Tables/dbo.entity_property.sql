CREATE TABLE [dbo].[entity_property]
(
[ID] [numeric] (18, 0) NOT NULL,
[ENTITY_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_ID] [numeric] (18, 0) NULL,
[PROPERTY_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL,
[UPDATED] [datetime] NULL,
[json_value] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_property] ADD CONSTRAINT [PK_entity_property] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entityproperty_entity] ON [dbo].[entity_property] ([ENTITY_NAME], [ENTITY_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entityproperty_key] ON [dbo].[entity_property] ([PROPERTY_KEY]) ON [PRIMARY]
GO
