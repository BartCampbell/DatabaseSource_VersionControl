CREATE TABLE [dbo].[PortalCalendarRepeatingEvent]
(
[PortalCalendarRepeatingEventID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalCalendarRepeatingEvent_PortalRepeatingEventID] DEFAULT (newid()),
[PortalCalendarID] [uniqueidentifier] NOT NULL,
[PreviousRepeatingEventID] [uniqueidentifier] NULL,
[EventName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventDescription] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsTask] [bit] NOT NULL CONSTRAINT [DF_PortalCalendarRepeatingEvent_IsTask] DEFAULT ((0)),
[IsDaily] [bit] NOT NULL,
[IsWeekly] [bit] NOT NULL,
[IsMonthly] [bit] NOT NULL,
[IsYearly] [bit] NOT NULL,
[WeekDay] [smallint] NULL,
[MonthDay] [smallint] NULL,
[MonthOfYear] [smallint] NULL,
[ScheduledTime] [datetime] NULL,
[EndTime] [datetime] NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[IsAggregationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalCalendarRepeatingEvent_IsAggregationAllowed] DEFAULT ((1)),
[PublishedStatus] [tinyint] NOT NULL CONSTRAINT [DF_PortalCalendarRepeatingEvent_PublishedStatus] DEFAULT ((0)),
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendarRepeatingEvent] ADD CONSTRAINT [PK_PortalCalendarRepeatingEvent] PRIMARY KEY CLUSTERED  ([PortalCalendarRepeatingEventID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendarRepeatingEvent] ADD CONSTRAINT [FK_PortalCalendarRepeatingEvent_PortalCalendar] FOREIGN KEY ([PortalCalendarID]) REFERENCES [dbo].[PortalCalendar] ([PortalCalendarID])
GO
