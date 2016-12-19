CREATE TABLE [dbo].[tblIssueResponse]
(
[IssueResponse_PK] [tinyint] NOT NULL,
[IssueResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[sortOrder] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIssueResponse] ADD CONSTRAINT [PK_tblIssueResponse] PRIMARY KEY CLUSTERED  ([IssueResponse_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
