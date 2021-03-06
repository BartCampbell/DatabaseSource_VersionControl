CREATE TABLE [dbo].[AO_54307E_CONFLUENCEKBENABLED]
(
[CONFLUENCE_KBID] [int] NOT NULL,
[ENABLED] [bit] NULL,
[FORM_ID] [int] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[SERVICE_DESK_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_54307E_CONFLUENCEKBENABLED] ADD CONSTRAINT [pk_AO_54307E_CONFLUENCEKBENABLED_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_54307e_con1483953915] ON [dbo].[AO_54307E_CONFLUENCEKBENABLED] ([CONFLUENCE_KBID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_54307e_con534365480] ON [dbo].[AO_54307E_CONFLUENCEKBENABLED] ([FORM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_54307e_con1935875239] ON [dbo].[AO_54307E_CONFLUENCEKBENABLED] ([SERVICE_DESK_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_54307E_CONFLUENCEKBENABLED] ADD CONSTRAINT [fk_ao_54307e_confluencekbenabled_confluence_kbid] FOREIGN KEY ([CONFLUENCE_KBID]) REFERENCES [dbo].[AO_54307E_CONFLUENCEKB] ([ID])
GO
ALTER TABLE [dbo].[AO_54307E_CONFLUENCEKBENABLED] ADD CONSTRAINT [fk_ao_54307e_confluencekbenabled_form_id] FOREIGN KEY ([FORM_ID]) REFERENCES [dbo].[AO_54307E_VIEWPORTFORM] ([ID])
GO
ALTER TABLE [dbo].[AO_54307E_CONFLUENCEKBENABLED] ADD CONSTRAINT [fk_ao_54307e_confluencekbenabled_service_desk_id] FOREIGN KEY ([SERVICE_DESK_ID]) REFERENCES [dbo].[AO_54307E_SERVICEDESK] ([ID])
GO
