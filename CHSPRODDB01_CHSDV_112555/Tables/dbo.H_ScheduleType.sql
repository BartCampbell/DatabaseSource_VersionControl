CREATE TABLE [dbo].[H_ScheduleType]
(
[H_ScheduleType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScheduleType_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientScheduleTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_Schedul__LoadD__44952D46] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_ScheduleType] ADD CONSTRAINT [PK_H_ScheduleType] PRIMARY KEY CLUSTERED  ([H_ScheduleType_RK]) ON [PRIMARY]
GO
