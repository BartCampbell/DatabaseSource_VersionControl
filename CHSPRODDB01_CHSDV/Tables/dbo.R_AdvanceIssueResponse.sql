CREATE TABLE [dbo].[R_AdvanceIssueResponse]
(
[CentauriIssueResponseID] [int] NOT NULL IDENTITY(1001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientIssueResponseID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueResponseHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriIssueResponseID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceIssueResponse] ADD CONSTRAINT [PK_CentauriIssueResponseID] PRIMARY KEY CLUSTERED  ([CentauriIssueResponseID]) ON [PRIMARY]
GO
