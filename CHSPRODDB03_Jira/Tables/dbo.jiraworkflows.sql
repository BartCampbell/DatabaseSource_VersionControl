CREATE TABLE [dbo].[jiraworkflows]
(
[ID] [numeric] (18, 0) NOT NULL,
[workflowname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[creatorname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTOR] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISLOCKED] [nvarchar] (60) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraworkflows] ADD CONSTRAINT [PK_jiraworkflows] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
