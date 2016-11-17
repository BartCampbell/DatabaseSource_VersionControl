CREATE TABLE [dbo].[LS_ContactNotesOfficeContactNote]
(
[LS_ContactNotesOfficeContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ContactNotesOfficeContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeContactNote] ADD CONSTRAINT [PK_LS_ContactNotesOfficeContactNote] PRIMARY KEY CLUSTERED  ([LS_ContactNotesOfficeContactNote_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151138] ON [dbo].[LS_ContactNotesOfficeContactNote] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeContactNote] ADD CONSTRAINT [FK_L_ContactNotesOfficeContactNote_RK1] FOREIGN KEY ([L_ContactNotesOfficeContactNote_RK]) REFERENCES [dbo].[L_ContactNotesOfficeContactNote] ([L_ContactNotesOfficeContactNote_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
