CREATE TABLE [dbo].[LS_ContactNotesOfficeProject]
(
[LS_ContactNotesOfficeProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ContactNotesOfficeProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeProject] ADD CONSTRAINT [PK_LS_ContactNotesOfficeProject] PRIMARY KEY CLUSTERED  ([LS_ContactNotesOfficeProject_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151203] ON [dbo].[LS_ContactNotesOfficeProject] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeProject] ADD CONSTRAINT [FK_L_ContactNotesOfficeProject_RK1] FOREIGN KEY ([L_ContactNotesOfficeProject_RK]) REFERENCES [dbo].[L_ContactNotesOfficeProject] ([L_ContactNotesOfficeProject_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
