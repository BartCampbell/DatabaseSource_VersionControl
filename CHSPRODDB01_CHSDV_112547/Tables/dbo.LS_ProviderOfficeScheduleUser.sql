CREATE TABLE [dbo].[LS_ProviderOfficeScheduleUser]
(
[LS_ProviderOfficeScheduleUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_ProviderOfficeScheduleUser_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleUser] ADD CONSTRAINT [PK_LS_ProviderOfficeScheduleUser] PRIMARY KEY CLUSTERED  ([LS_ProviderOfficeScheduleUser_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161004-151522] ON [dbo].[LS_ProviderOfficeScheduleUser] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_ProviderOfficeScheduleUser] ADD CONSTRAINT [FK_L_ProviderOfficeScheduleUser_RK1] FOREIGN KEY ([L_ProviderOfficeScheduleUser_RK]) REFERENCES [dbo].[L_ProviderOfficeScheduleUser] ([L_ProviderOfficeScheduleUser_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
