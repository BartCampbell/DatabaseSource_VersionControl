CREATE TABLE [dbo].[AO_82B313_INIT]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_82B313_INIT] ADD CONSTRAINT [pk_AO_82B313_INIT_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_82B313_INIT] ADD CONSTRAINT [U_AO_82B313_INIT_KEY] UNIQUE NONCLUSTERED  ([KEY]) ON [PRIMARY]
GO