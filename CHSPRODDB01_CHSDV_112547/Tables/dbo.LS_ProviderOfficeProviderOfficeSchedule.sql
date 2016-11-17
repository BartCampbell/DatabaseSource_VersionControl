CREATE TABLE [dbo].[LS_ProviderOfficeProviderOfficeSchedule]
(
[LS_ProviderOfficeProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOffice_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeProviderOfficeSchedule] ADD CONSTRAINT [PK_LS_ProviderOfficeProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeProviderOfficeSchedule_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151436] ON [dbo].[LS_ProviderOfficeProviderOfficeSchedule] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeProviderOfficeSchedule] ADD CONSTRAINT [FK_L_ProviderOfficeProviderOfficeSchedule_RK1] FOREIGN KEY ([L_ProviderOfficeProviderOfficeSchedule_RK]) REFERENCES [dbo].[L_ProviderOfficeProviderOfficeSchedule] ([L_ProviderOfficeProviderOfficeSchedule_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
