CREATE TABLE [dbo].[L_ProviderOfficeScheduleUser]
(
[L_ProviderOfficeScheduleUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleUser] ADD CONSTRAINT [PK_L_ProviderOfficeScheduleUser] PRIMARY KEY CLUSTERED  ([L_ProviderOfficeScheduleUser_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleUser] ADD CONSTRAINT [FK_H_ProviderOfficeSchedule_RK1] FOREIGN KEY ([H_ProviderOfficeSchedule_RK]) REFERENCES [dbo].[H_ProviderOfficeSchedule] ([H_ProviderOfficeSchedule_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ProviderOfficeScheduleUser] ADD CONSTRAINT [FK_H_User_RK21] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
