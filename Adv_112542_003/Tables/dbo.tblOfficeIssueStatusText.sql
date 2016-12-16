CREATE TABLE [dbo].[tblOfficeIssueStatusText]
(
[OfficeIssueStatus_PK] [int] NOT NULL,
[OfficeIssueStatusText] [varchar] (27) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxtblOfficeIssueStatusTextPK] ON [dbo].[tblOfficeIssueStatusText] ([OfficeIssueStatus_PK]) ON [PRIMARY]
GO
