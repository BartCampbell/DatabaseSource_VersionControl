CREATE TABLE [dbo].[H_IssueResponse]
(
[H_IssueResponse_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IssueResponse_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientIssueResponseID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_IssueResponse] ADD CONSTRAINT [PK_H_IssueResponse] PRIMARY KEY CLUSTERED  ([H_IssueResponse_RK]) ON [PRIMARY]
GO
