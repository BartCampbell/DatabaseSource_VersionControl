CREATE TABLE [dbo].[L_IssueResponseUserContactNotesOffice]
(
[L_IssueResponseUserContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_IssueResponse_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_IssueResponseUserContactNotesOffice] ADD CONSTRAINT [PK_L_IssueResponseUserContactNotesOffice] PRIMARY KEY CLUSTERED  ([L_IssueResponseUserContactNotesOffice_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_IssueResponseUserContactNotesOffice] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK1] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_IssueResponseUserContactNotesOffice] ADD CONSTRAINT [FK_H_IssueResponse_RK6] FOREIGN KEY ([H_IssueResponse_RK]) REFERENCES [dbo].[H_IssueResponse] ([H_IssueResponse_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_IssueResponseUserContactNotesOffice] ADD CONSTRAINT [FK_H_User_RK23] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
