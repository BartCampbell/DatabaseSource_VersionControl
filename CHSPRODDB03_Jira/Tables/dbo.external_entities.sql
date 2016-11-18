CREATE TABLE [dbo].[external_entities]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[entitytype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[external_entities] ADD CONSTRAINT [PK_external_entities] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ext_entity_name] ON [dbo].[external_entities] ([NAME]) ON [PRIMARY]
GO
