CREATE TABLE [fact].[ProviderOfficeSchedule]
(
[ProviderOfficeScheduleID] [int] NOT NULL IDENTITY(1, 1),
[CentauriProviderOfficeScheduleID] [int] NOT NULL,
[CentauriProviderOfficeID] [int] NULL,
[ProjectID] [int] NULL,
[LastUserID] [int] NULL,
[ScheduledUserID] [int] NULL,
[ScheduleTypeID] [int] NULL,
[Sch_Start] [smalldatetime] NULL,
[Sch_End] [smalldatetime] NULL,
[LastUpdated_Date] [smalldatetime] NULL,
[followup] [smallint] NULL,
[AddInfo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeSchedule_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_ProviderOfficeDetail_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [fact].[ProviderOfficeSchedule] ADD CONSTRAINT [PK_ProviderOfficeSchedule] PRIMARY KEY CLUSTERED  ([ProviderOfficeScheduleID]) ON [PRIMARY]
GO
ALTER TABLE [fact].[ProviderOfficeSchedule] ADD CONSTRAINT [FK_ProviderOfficeSchedule_LastUser] FOREIGN KEY ([LastUserID]) REFERENCES [dim].[User] ([UserID])
GO
ALTER TABLE [fact].[ProviderOfficeSchedule] ADD CONSTRAINT [FK_ProviderOfficeSchedule_Project] FOREIGN KEY ([ProjectID]) REFERENCES [dim].[ADVProject] ([ProjectID])
GO
ALTER TABLE [fact].[ProviderOfficeSchedule] ADD CONSTRAINT [FK_ProviderOfficeSchedule_ScheduledUser] FOREIGN KEY ([ScheduledUserID]) REFERENCES [dim].[User] ([UserID])
GO
ALTER TABLE [fact].[ProviderOfficeSchedule] ADD CONSTRAINT [FK_ProviderOfficeSchedule_ScheduleType] FOREIGN KEY ([ScheduleTypeID]) REFERENCES [dim].[ScheduleType] ([ScheduleTypeID])
GO
