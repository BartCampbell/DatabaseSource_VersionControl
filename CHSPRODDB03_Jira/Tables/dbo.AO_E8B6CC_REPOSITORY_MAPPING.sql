CREATE TABLE [dbo].[AO_E8B6CC_REPOSITORY_MAPPING]
(
[ACTIVITY_LAST_SYNC] [datetime] NULL,
[DELETED] [bit] NULL,
[FORK] [bit] NULL,
[FORK_OF_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FORK_OF_OWNER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FORK_OF_SLUG] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[LAST_CHANGESET_NODE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[LAST_COMMIT_DATE] [datetime] NULL,
[LINKED] [bit] NULL,
[LOGO] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ORGANIZATION_ID] [int] NULL CONSTRAINT [df_AO_E8B6CC_REPOSITORY_MAPPING_ORGANIZATION_ID] DEFAULT ((0)),
[SLUG] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SMARTCOMMITS_ENABLED] [bit] NULL,
[UPDATE_LINK_AUTHORISED] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_E8B6CC_REPOSITORY_MAPPING] ADD CONSTRAINT [pk_AO_E8B6CC_REPOSITORY_MAPPING_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_e8b6cc_rep93578901] ON [dbo].[AO_E8B6CC_REPOSITORY_MAPPING] ([LINKED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_e8b6cc_rep702725269] ON [dbo].[AO_E8B6CC_REPOSITORY_MAPPING] ([ORGANIZATION_ID]) ON [PRIMARY]
GO