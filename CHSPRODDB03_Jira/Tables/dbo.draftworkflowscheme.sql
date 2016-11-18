CREATE TABLE [dbo].[draftworkflowscheme]
(
[ID] [numeric] (18, 0) NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[WORKFLOW_SCHEME_ID] [numeric] (18, 0) NULL,
[LAST_MODIFIED_DATE] [datetime] NULL,
[LAST_MODIFIED_USER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[draftworkflowscheme] ADD CONSTRAINT [PK_draftworkflowscheme] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [draft_workflow_scheme_parent] ON [dbo].[draftworkflowscheme] ([WORKFLOW_SCHEME_ID]) ON [PRIMARY]
GO
