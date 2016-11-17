CREATE TABLE [dbo].[LS_ContactNotesOfficeProvider]
(
[LS_ContactNotesOfficeProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ContactNotesOfficeProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeProvider] ADD CONSTRAINT [PK_LS_ContactNotesOfficeProvider] PRIMARY KEY CLUSTERED  ([LS_ContactNotesOfficeProvider_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151224] ON [dbo].[LS_ContactNotesOfficeProvider] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ContactNotesOfficeProvider] ADD CONSTRAINT [FK_L_ContactNotesOfficeProvider_RK1] FOREIGN KEY ([L_ContactNotesOfficeProvider_RK]) REFERENCES [dbo].[L_ContactNotesOfficeProvider] ([L_ContactNotesOfficeProvider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
