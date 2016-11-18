CREATE TABLE [dbo].[changegroup]
(
[ID] [numeric] (18, 0) NOT NULL,
[issueid] [numeric] (18, 0) NULL,
[AUTHOR] [nvarchar] (255) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[CREATED] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[changegroup] ADD CONSTRAINT [PK_changegroup] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [chggroup_author_created] ON [dbo].[changegroup] ([AUTHOR], [CREATED]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [chggroup_issue] ON [dbo].[changegroup] ([issueid]) ON [PRIMARY]
GO
