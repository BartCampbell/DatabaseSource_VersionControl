CREATE TABLE [dbo].[propertyentry]
(
[ID] [numeric] (18, 0) NOT NULL,
[ENTITY_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_ID] [numeric] (18, 0) NULL,
[PROPERTY_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[propertytype] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[propertyentry] ADD CONSTRAINT [PK_propertyentry] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [osproperty_all] ON [dbo].[propertyentry] ([ENTITY_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [osproperty_entityName] ON [dbo].[propertyentry] ([ENTITY_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [osproperty_propertyKey] ON [dbo].[propertyentry] ([PROPERTY_KEY]) ON [PRIMARY]
GO
