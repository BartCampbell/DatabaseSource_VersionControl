CREATE TABLE [dbo].[H_ContactNotesOffice]
(
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContactNotesOffice_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactNotesOfficeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Contact__LoadD__2610A626] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ContactNotesOffice] ADD CONSTRAINT [PK_H_ContactNotesOffice] PRIMARY KEY CLUSTERED  ([H_ContactNotesOffice_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
