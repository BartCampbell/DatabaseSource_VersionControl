CREATE TABLE [dbo].[AO_C7F17E_PROJECT_LANG_REV]
(
[AUTHOR_USER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED_TIMESTAMP] [bigint] NULL,
[DEFAULT_LANGUAGE] [nvarchar] (63) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[PROJECT_LANG_CONFIG_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_PROJECT_LANG_REV] ADD CONSTRAINT [pk_AO_C7F17E_PROJECT_LANG_REV_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_c7f17e_pro847365574] ON [dbo].[AO_C7F17E_PROJECT_LANG_REV] ([PROJECT_LANG_CONFIG_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_PROJECT_LANG_REV] ADD CONSTRAINT [fk_ao_c7f17e_project_lang_rev_project_lang_config_id] FOREIGN KEY ([PROJECT_LANG_CONFIG_ID]) REFERENCES [dbo].[AO_C7F17E_PROJECT_LANG_CONFIG] ([ID])
GO
