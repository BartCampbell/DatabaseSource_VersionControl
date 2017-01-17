CREATE TABLE [dbo].[L_ContactNotesOfficeContactNote]
(
[L_ContactNotesOfficeContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeContactNote] ADD CONSTRAINT [PK_L_ContactNotesOfficeContactNote] PRIMARY KEY CLUSTERED  ([L_ContactNotesOfficeContactNote_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeContactNote] ADD CONSTRAINT [FK_H_ContactNote_RK2] FOREIGN KEY ([H_ContactNote_RK]) REFERENCES [dbo].[H_ContactNote] ([H_ContactNote_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeContactNote] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK6] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
