CREATE TABLE [dbo].[L_ProviderOfficeProviderOfficeSchedule]
(
[L_ProviderOfficeProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeProviderOfficeSchedule] ADD CONSTRAINT [PK_L_ProviderOfficeProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeProviderOfficeSchedule_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeProviderOfficeSchedule] ADD CONSTRAINT [FK_H_ProviderOffice_RK3] FOREIGN KEY ([H_ProviderOffice_RK]) REFERENCES [dbo].[H_ProviderOffice] ([H_ProviderOffice_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeProviderOfficeSchedule] ADD CONSTRAINT [FK_H_ProviderOfficeSchedule_RK2] FOREIGN KEY ([H_ProviderOfficeSchedule_RK]) REFERENCES [dbo].[H_ProviderOfficeSchedule] ([H_ProviderOfficeSchedule_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
