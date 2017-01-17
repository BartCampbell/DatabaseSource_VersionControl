CREATE TABLE [dbo].[L_ProviderOfficeScheduleProject]
(
[L_ProviderOfficeScheduleProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleProject] ADD CONSTRAINT [PK_L_ProviderOfficeScheduleProject] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeScheduleProject_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleProject] ADD CONSTRAINT [FK_H_Project_RK4] FOREIGN KEY ([H_Project_RK]) REFERENCES [dbo].[H_Project] ([H_Project_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleProject] ADD CONSTRAINT [FK_H_ProviderOfficeSchedule_RK] FOREIGN KEY ([H_ProviderOfficeSchedule_RK]) REFERENCES [dbo].[H_ProviderOfficeSchedule] ([H_ProviderOfficeSchedule_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
