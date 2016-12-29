CREATE TABLE [dbo].[tblIssueResponseOffice]
(
[IssueResponse_PK] [tinyint] NOT NULL,
[ContactNotesOffice_PK] [int] NOT NULL,
[AdditionalResponse] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[User_PK] [smallint] NULL,
[dtInsert] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblIssueResponseOffice] ADD CONSTRAINT [PK_tblIssueResponseOffice] PRIMARY KEY CLUSTERED  ([IssueResponse_PK], [ContactNotesOffice_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
