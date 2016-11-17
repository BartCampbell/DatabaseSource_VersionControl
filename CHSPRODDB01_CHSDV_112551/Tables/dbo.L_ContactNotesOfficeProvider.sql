CREATE TABLE [dbo].[L_ContactNotesOfficeProvider]
(
[L_ContactNotesOfficeProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ContactNotesOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProvider] ADD CONSTRAINT [PK_L_ContactNotesOfficeProvider] PRIMARY KEY CLUSTERED  ([L_ContactNotesOfficeProvider_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProvider] ADD CONSTRAINT [FK_H_ContactNotesOffice_RK5] FOREIGN KEY ([H_ContactNotesOffice_RK]) REFERENCES [dbo].[H_ContactNotesOffice] ([H_ContactNotesOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ContactNotesOfficeProvider] ADD CONSTRAINT [FK_H_ProviderOffice_RK10] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
