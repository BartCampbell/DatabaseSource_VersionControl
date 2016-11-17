CREATE TABLE [dbo].[LS_IssueResponseOfficeDetail]
(
[LS_IssueResponseOfficeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_IssueResponseUserContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalResponse] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtInsert] [smalldatetime] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_IssueResponseOfficeDetail] ADD CONSTRAINT [PK_LS_IssueResponseOfficeDetail] PRIMARY KEY CLUSTERED  ([LS_IssueResponseOfficeDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_IssueResponseOfficeDetail] ADD CONSTRAINT [FK_L_IssueResponseUserContactNotesOffice_RK1] FOREIGN KEY ([L_IssueResponseUserContactNotesOffice_RK]) REFERENCES [dbo].[L_IssueResponseUserContactNotesOffice] ([L_IssueResponseUserContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
