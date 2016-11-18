CREATE TABLE [dbo].[AO_9412A1_AOTASK]
(
[APPLICATION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[APPLICATION_LINK_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CREATED] [datetime] NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ENTITY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[GLOBAL_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[ITEM_ICON_URL] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ITEM_TITLE] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[METADATA] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[STATUS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[TITLE] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[UPDATED] [datetime] NULL,
[URL] [ntext] COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[USER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CS_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_9412A1_AOTASK] ADD CONSTRAINT [pk_AO_9412A1_AOTASK_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_9412a1_aot1465568358] ON [dbo].[AO_9412A1_AOTASK] ([GLOBAL_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_9412a1_aotask_user] ON [dbo].[AO_9412A1_AOTASK] ([USER]) ON [PRIMARY]
GO
