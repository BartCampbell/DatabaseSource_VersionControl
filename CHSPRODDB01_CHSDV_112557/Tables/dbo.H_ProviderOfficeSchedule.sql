CREATE TABLE [dbo].[H_ProviderOfficeSchedule]
(
[H_ProviderOfficeSchedule_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderOfficeSchedule_BK] [int] NULL,
[ClientProviderOfficeScheduleID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Provide__LoadD__3B0BC30C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ProviderOfficeSchedule] ADD CONSTRAINT [PK_H_ProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([H_ProviderOfficeSchedule_RK]) ON [PRIMARY]
GO
