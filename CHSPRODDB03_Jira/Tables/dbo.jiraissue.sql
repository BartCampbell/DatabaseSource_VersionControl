CREATE TABLE [dbo].[jiraissue]
(
[ID] [numeric] (18, 0) NOT NULL,
[pkey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[issuenum] [numeric] (18, 0) NULL,
[PROJECT] [numeric] (18, 0) NULL,
[REPORTER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ASSIGNEE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[issuetype] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[SUMMARY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DESCRIPTION] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ENVIRONMENT] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PRIORITY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[RESOLUTION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[issuestatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL,
[UPDATED] [datetime] NULL,
[DUEDATE] [datetime] NULL,
[RESOLUTIONDATE] [datetime] NULL,
[VOTES] [numeric] (18, 0) NULL,
[WATCHES] [numeric] (18, 0) NULL,
[TIMEORIGINALESTIMATE] [numeric] (18, 0) NULL,
[TIMEESTIMATE] [numeric] (18, 0) NULL,
[TIMESPENT] [numeric] (18, 0) NULL,
[WORKFLOW_ID] [numeric] (18, 0) NULL,
[SECURITY] [numeric] (18, 0) NULL,
[FIXFOR] [numeric] (18, 0) NULL,
[COMPONENT] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraissue] ADD CONSTRAINT [PK_jiraissue] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_assignee] ON [dbo].[jiraissue] ([ASSIGNEE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_created] ON [dbo].[jiraissue] ([CREATED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_duedate] ON [dbo].[jiraissue] ([DUEDATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_proj_num] ON [dbo].[jiraissue] ([issuenum], [PROJECT]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_proj_status] ON [dbo].[jiraissue] ([PROJECT], [issuestatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_reporter] ON [dbo].[jiraissue] ([REPORTER]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_resolutiondate] ON [dbo].[jiraissue] ([RESOLUTIONDATE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_updated] ON [dbo].[jiraissue] ([UPDATED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_votes] ON [dbo].[jiraissue] ([VOTES]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_watches] ON [dbo].[jiraissue] ([WATCHES]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [issue_workflow] ON [dbo].[jiraissue] ([WORKFLOW_ID]) ON [PRIMARY]
GO
