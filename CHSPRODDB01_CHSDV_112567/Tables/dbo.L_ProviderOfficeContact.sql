CREATE TABLE [dbo].[L_ProviderOfficeContact]
(
[L_ProviderOfficeContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Contact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeContact] ADD CONSTRAINT [PK_L_ProviderOfficeContact] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeContact_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeContact] ADD CONSTRAINT [FK_H_Contact_RK9] FOREIGN KEY ([H_Contact_RK]) REFERENCES [dbo].[H_Contact] ([H_Contact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeContact] ADD CONSTRAINT [FK_H_ProviderOffice_RK] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
