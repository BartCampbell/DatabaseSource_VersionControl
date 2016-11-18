CREATE TABLE [dbo].[jiraaction]
(
[ID] [numeric] (18, 0) NOT NULL,
[issueid] [numeric] (18, 0) NULL,
[AUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[actiontype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[actionlevel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[rolelevel] [numeric] (18, 0) NULL,
[actionbody] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL,
[UPDATEAUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPDATED] [datetime] NULL,
[actionnum] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraaction] ADD CONSTRAINT [PK_jiraaction] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [action_author_created] ON [dbo].[jiraaction] ([AUTHOR], [CREATED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [action_issue] ON [dbo].[jiraaction] ([issueid]) ON [PRIMARY]
GO
