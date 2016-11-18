CREATE TABLE [dbo].[projectchangedtime]
(
[PROJECT_ID] [numeric] (18, 0) NOT NULL,
[ISSUE_CHANGED_TIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[projectchangedtime] ADD CONSTRAINT [PK_projectchangedtime] PRIMARY KEY CLUSTERED  ([PROJECT_ID]) ON [PRIMARY]
GO
