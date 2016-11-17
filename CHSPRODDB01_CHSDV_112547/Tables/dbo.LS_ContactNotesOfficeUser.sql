CREATE TABLE [dbo].[LS_ContactNotesOfficeUser]
(
[LS_ContactNotesOfficeUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ContactNotesOfficeUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeUser] ADD CONSTRAINT [PK_LS_ContactNotesOfficeUser] PRIMARY KEY CLUSTERED  ([LS_ContactNotesOfficeUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151243] ON [dbo].[LS_ContactNotesOfficeUser] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeUser] ADD CONSTRAINT [FK_L_ContactNotesOfficeUser_RK1] FOREIGN KEY ([L_ContactNotesOfficeUser_RK]) REFERENCES [dbo].[L_ContactNotesOfficeUser] ([L_ContactNotesOfficeUser_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
