CREATE TABLE [dbo].[H_ContactNote]
(
[H_ContactNote_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContactNote_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactNoteID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Contact__LoadD__2334397B] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ContactNote] ADD CONSTRAINT [PK_H_ContactNote] PRIMARY KEY CLUSTERED  ([H_ContactNote_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
