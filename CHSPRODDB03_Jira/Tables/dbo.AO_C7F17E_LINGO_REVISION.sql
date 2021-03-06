CREATE TABLE [dbo].[AO_C7F17E_LINGO_REVISION]
(
[CREATED_TIMESTAMP] [bigint] NOT NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[LINGO_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_LINGO_REVISION] ADD CONSTRAINT [pk_AO_C7F17E_LINGO_REVISION_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_c7f17e_lin1649844463] ON [dbo].[AO_C7F17E_LINGO_REVISION] ([LINGO_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_C7F17E_LINGO_REVISION] ADD CONSTRAINT [fk_ao_c7f17e_lingo_revision_lingo_id] FOREIGN KEY ([LINGO_ID]) REFERENCES [dbo].[AO_C7F17E_LINGO] ([ID])
GO
