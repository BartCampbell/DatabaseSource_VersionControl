CREATE TABLE [stage].[IssueResponseOffice_ADV]
(
[CentauriIssueResponseID] [int] NOT NULL,
[CentauriContactNotesOfficeID] [int] NULL,
[CentauriUserID] [int] NULL,
[IssueResponse] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalResponse] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[ClientID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
