CREATE TABLE [dbo].[L_ContactNotesOfficeUser]
(
[L_ContactNotesOfficeUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeUser] ADD CONSTRAINT [PK_L_ContactNotesOfficeUser] PRIMARY KEY CLUSTERED  ([L_ContactNotesOfficeUser_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeUser] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK3] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeUser] ADD CONSTRAINT [FK_H_User_RK20] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
