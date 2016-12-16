CREATE TABLE [dbo].[L_ContactNotesOfficeProject]
(
[L_ContactNotesOfficeProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProject] ADD CONSTRAINT [PK_L_ContactNotesOfficeProject] PRIMARY KEY CLUSTERED  ([L_ContactNotesOfficeProject_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProject] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK4] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProject] ADD CONSTRAINT [FK_H_Project_RK10] FOREIGN KEY ([H_Project_RK]) REFERENCES [dbo].[H_Project] ([H_Project_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
