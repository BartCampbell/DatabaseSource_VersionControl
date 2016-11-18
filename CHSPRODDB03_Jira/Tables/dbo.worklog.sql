CREATE TABLE [dbo].[worklog]
(
[ID] [numeric] (18, 0) NOT NULL,
[issueid] [numeric] (18, 0) NULL,
[AUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[grouplevel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[rolelevel] [numeric] (18, 0) NULL,
[worklogbody] [ntext] COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL,
[UPDATEAUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[UPDATED] [datetime] NULL,
[STARTDATE] [datetime] NULL,
[timeworked] [numeric] (18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[worklog] ADD CONSTRAINT [PK_worklog] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [worklog_author] ON [dbo].[worklog] ([AUTHOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [worklog_issue] ON [dbo].[worklog] ([issueid]) ON [PRIMARY]
GO
