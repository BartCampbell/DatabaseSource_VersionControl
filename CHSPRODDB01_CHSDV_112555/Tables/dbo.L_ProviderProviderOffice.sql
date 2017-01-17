CREATE TABLE [dbo].[L_ProviderProviderOffice]
(
[L_ProviderProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderProviderOffice] ADD CONSTRAINT [PK_L_ProviderProviderOffice] PRIMARY KEY CLUSTERED  ([L_ProviderProviderOffice_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderProviderOffice] ADD CONSTRAINT [FK_H_Provider_RK9] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderProviderOffice] ADD CONSTRAINT [FK_H_ProviderOffice_RK2] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
