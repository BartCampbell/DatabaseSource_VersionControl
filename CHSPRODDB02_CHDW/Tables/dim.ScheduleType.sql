CREATE TABLE [dim].[ScheduleType]
(
[ScheduleTypeID] [int] NOT NULL IDENTITY(1, 1),
[CentauriScheduleTypeID] [int] NULL,
[ScheduleType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ScheduleType_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ScheduleType_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[ScheduleType] ADD CONSTRAINT [PK_ScheduleType] PRIMARY KEY CLUSTERED  ([ScheduleTypeID]) ON [PRIMARY]
GO
