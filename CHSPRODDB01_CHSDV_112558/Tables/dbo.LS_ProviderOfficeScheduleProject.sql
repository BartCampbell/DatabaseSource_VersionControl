CREATE TABLE [dbo].[LS_ProviderOfficeScheduleProject]
(
[LS_ProviderOfficeScheduleProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeScheduleProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleProject] ADD CONSTRAINT [PK_LS_ProviderOfficeScheduleProject] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeScheduleProject_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151451] ON [dbo].[LS_ProviderOfficeScheduleProject] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleProject] ADD CONSTRAINT [FK_L_ProviderOfficeScheduleProject_RK1] FOREIGN KEY ([L_ProviderOfficeScheduleProject_RK]) REFERENCES [dbo].[L_ProviderOfficeScheduleProject] ([L_ProviderOfficeScheduleProject_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
