CREATE TABLE [adv].[tblIssueResponseStage]
(
[IssueResponse_PK] [tinyint] NOT NULL,
[IssueResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueResponseHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblIssueResponseStage] ADD CONSTRAINT [PK_tblIssueResponse] PRIMARY KEY CLUSTERED  ([IssueResponse_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
