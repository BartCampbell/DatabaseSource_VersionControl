CREATE TABLE [dbo].[L_ProviderOfficeScheduleScheduleType]
(
[L_ProviderOfficeScheduleScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleScheduleType] ADD CONSTRAINT [PK_L_ProviderOfficeScheduleScheduleType] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeScheduleScheduleType_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleScheduleType] ADD CONSTRAINT [FK_H_ProviderOfficeSchedule_RK4] FOREIGN KEY ([H_ProviderOfficeSchedule_RK]) REFERENCES [dbo].[H_ProviderOfficeSchedule] ([H_ProviderOfficeSchedule_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleScheduleType] ADD CONSTRAINT [FK_H_ScheduleType_RK21] FOREIGN KEY ([H_ScheduleType_RK]) REFERENCES [dbo].[H_ScheduleType] ([H_ScheduleType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
