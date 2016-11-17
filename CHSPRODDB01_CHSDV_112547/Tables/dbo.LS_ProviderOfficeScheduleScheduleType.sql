CREATE TABLE [dbo].[LS_ProviderOfficeScheduleScheduleType]
(
[LS_ProviderOfficeScheduleScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeScheduleScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleScheduleType] ADD CONSTRAINT [PK_LS_ProviderOfficeScheduleScheduleType] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeScheduleScheduleType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151506] ON [dbo].[LS_ProviderOfficeScheduleScheduleType] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleScheduleType] ADD CONSTRAINT [FK_L_ProviderOfficeScheduleScheduleType_RK1] FOREIGN KEY ([L_ProviderOfficeScheduleScheduleType_RK]) REFERENCES [dbo].[L_ProviderOfficeScheduleScheduleType] ([L_ProviderOfficeScheduleScheduleType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
