CREATE TABLE [dbo].[L_ProviderMasterOffice]
(
[L_ProviderMasterOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderMasterOffice] ADD CONSTRAINT [PK_L_ProviderMasterOffice] PRIMARY KEY CLUSTERED  ([L_ProviderMasterOffice_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderMasterOffice] ADD CONSTRAINT [FK_H_ProviderMasterOffice_RK2] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderMasterOffice] ADD CONSTRAINT [FK_H_ProviderMasterOffice_RK8] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
