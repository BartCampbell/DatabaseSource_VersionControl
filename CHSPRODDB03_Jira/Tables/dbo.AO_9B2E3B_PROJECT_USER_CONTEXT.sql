CREATE TABLE [dbo].[AO_9B2E3B_PROJECT_USER_CONTEXT]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[PROJECT_ID] [bigint] NOT NULL,
[STRATEGY] [nvarchar] (127) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[USER_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AO_9B2E3B_PROJECT_USER_CONTEXT] ADD CONSTRAINT [pk_AO_9B2E3B_PROJECT_USER_CONTEXT_ID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO