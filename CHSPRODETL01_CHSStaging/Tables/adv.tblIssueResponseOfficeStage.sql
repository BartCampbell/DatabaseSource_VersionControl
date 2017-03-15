CREATE TABLE [adv].[tblIssueResponseOfficeStage]
(
[IssueResponse_PK] [tinyint] NOT NULL,
[ContactNotesOffice_PK] [int] NOT NULL,
[AdditionalResponse] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblIssueResponseOfficeStage] ADD CONSTRAINT [PK_tblIssueResponseOffice] PRIMARY KEY CLUSTERED  ([IssueResponse_PK], [ContactNotesOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
