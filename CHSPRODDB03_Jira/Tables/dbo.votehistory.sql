CREATE TABLE [dbo].[votehistory]
(
[ID] [numeric] (18, 0) NOT NULL,
[issueid] [numeric] (18, 0) NULL,
[VOTES] [numeric] (18, 0) NULL,
[TIMESTAMP] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[votehistory] ADD CONSTRAINT [PK_votehistory] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [votehistory_issue_index] ON [dbo].[votehistory] ([issueid]) ON [PRIMARY]
GO
