CREATE TABLE [dbo].[moved_issue_key]
(
[ID] [numeric] (18, 0) NOT NULL,
[OLD_ISSUE_KEY] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISSUE_ID] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[moved_issue_key] ADD CONSTRAINT [PK_moved_issue_key] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_old_issue_key] ON [dbo].[moved_issue_key] ([OLD_ISSUE_KEY]) ON [PRIMARY]
GO
