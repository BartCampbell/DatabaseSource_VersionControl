CREATE TABLE [dbo].[jiraperms]
(
[ID] [numeric] (18, 0) NOT NULL,
[permtype] [numeric] (18, 0) NULL,
[projectid] [numeric] (18, 0) NULL,
[groupname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[jiraperms] ADD CONSTRAINT [PK_jiraperms] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
