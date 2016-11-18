CREATE TABLE [dbo].[entity_translation]
(
[ID] [numeric] (18, 0) NOT NULL,
[ENTITY_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENTITY_ID] [numeric] (18, 0) NULL,
[LOCALE] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRANS_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TRANS_DESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[entity_translation] ADD CONSTRAINT [PK_entity_translation] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_entitytranslation] ON [dbo].[entity_translation] ([ENTITY_NAME], [ENTITY_ID], [LOCALE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [entitytranslation_locale] ON [dbo].[entity_translation] ([LOCALE]) ON [PRIMARY]
GO
