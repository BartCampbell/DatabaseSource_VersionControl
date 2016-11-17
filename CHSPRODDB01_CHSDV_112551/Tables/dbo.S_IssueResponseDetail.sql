CREATE TABLE [dbo].[S_IssueResponseDetail]
(
[S_IssueResponseDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_IssueResponse_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_IssueResponseDetail] ADD CONSTRAINT [PK_S_IssueResponseDetail] PRIMARY KEY CLUSTERED  ([S_IssueResponseDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_IssueResponseDetail] ADD CONSTRAINT [FK_H_IssueResponse_RK1] FOREIGN KEY ([H_IssueResponse_RK]) REFERENCES [dbo].[H_IssueResponse] ([H_IssueResponse_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
