CREATE TABLE [dbo].[AO_E8B6CC_PULL_REQUEST]
(
[AUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[COMMENT_COUNT] [int] NULL CONSTRAINT [df_AO_E8B6CC_PULL_REQUEST_COMMENT_COUNT] DEFAULT ((0)),
[CREATED_ON] [datetime] NULL,
[DESTINATION_BRANCH] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DOMAIN_ID] [int] NOT NULL CONSTRAINT [df_AO_E8B6CC_PULL_REQUEST_DOMAIN_ID] DEFAULT ((0)),
[EXECUTED_BY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[LAST_STATUS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[REMOTE_ID] [bigint] NULL,
[SOURCE_BRANCH] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SOURCE_REPO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TO_REPOSITORY_ID] [int] NULL CONSTRAINT [df_AO_E8B6CC_PULL_REQUEST_TO_REPOSITORY_ID] DEFAULT ((0)),
[UPDATED_ON] [datetime] NULL,
[URL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_E8B6CC_PULL_REQUEST] ADD CONSTRAINT [pk_AO_E8B6CC_PULL_REQUEST_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_e8b6cc_pul1230717024] ON [dbo].[AO_E8B6CC_PULL_REQUEST] ([DOMAIN_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_e8b6cc_pul602811170] ON [dbo].[AO_E8B6CC_PULL_REQUEST] ([REMOTE_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [index_ao_e8b6cc_pul1448445182] ON [dbo].[AO_E8B6CC_PULL_REQUEST] ([TO_REPOSITORY_ID]) ON [PRIMARY]
GO