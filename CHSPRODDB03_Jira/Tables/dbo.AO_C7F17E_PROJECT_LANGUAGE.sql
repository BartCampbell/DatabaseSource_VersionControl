CREATE TABLE [dbo].[AO_C7F17E_PROJECT_LANGUAGE]
(
[ACTIVE] [bit] NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[LOCALE] [nvarchar] (63) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PROJECT_LANG_REV_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_PROJECT_LANGUAGE] ADD CONSTRAINT [pk_AO_C7F17E_PROJECT_LANGUAGE_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_c7f17e_pro2026674159] ON [dbo].[AO_C7F17E_PROJECT_LANGUAGE] ([PROJECT_LANG_REV_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_PROJECT_LANGUAGE] ADD CONSTRAINT [fk_ao_c7f17e_project_language_project_lang_rev_id] FOREIGN KEY ([PROJECT_LANG_REV_ID]) REFERENCES [dbo].[AO_C7F17E_PROJECT_LANG_REV] ([ID])
GO
