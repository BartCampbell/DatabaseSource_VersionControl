CREATE TABLE [dbo].[PortalCalendarEvent]
(
[PortalCalendarEventID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalCalendarEvent_PortalCalendarEventID] DEFAULT (newid()),
[PortalCalendarID] [uniqueidentifier] NOT NULL,
[PortalRepeatingEventID] [uniqueidentifier] NULL,
[PreviousEventID] [uniqueidentifier] NULL,
[PortalEventName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalEventDescription] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalEventDate] [datetime] NOT NULL,
[PortalEventTime] [datetime] NULL,
[PortalEventEndDate] [datetime] NULL,
[PortalEventEndTime] [datetime] NULL,
[IsTask] [bit] NOT NULL CONSTRAINT [DF_PortalCalendarEvent_IsTask] DEFAULT ((0)),
[IsTaskComplete] [bit] NOT NULL CONSTRAINT [DF_PortalCalendarEvent_IsTaskComplete] DEFAULT ((0)),
[IsAggregationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalCalendarEvent_IsAggregationAllowed] DEFAULT ((1)),
[PublishedStatus] [tinyint] NOT NULL CONSTRAINT [DF_PortalCalendarEvent_PublishedStatus] DEFAULT ((0)),
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendarEvent] ADD CONSTRAINT [PK_PortalCalendarEvent] PRIMARY KEY CLUSTERED  ([PortalCalendarEventID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendarEvent] ADD CONSTRAINT [FK_PortalCalendarEvent_PortalCalendar] FOREIGN KEY ([PortalCalendarID]) REFERENCES [dbo].[PortalCalendar] ([PortalCalendarID])
GO
ALTER TABLE [dbo].[PortalCalendarEvent] ADD CONSTRAINT [FK_PortalCalendarEvent_PortalCalendarRepeatingEvent] FOREIGN KEY ([PortalRepeatingEventID]) REFERENCES [dbo].[PortalCalendarRepeatingEvent] ([PortalCalendarRepeatingEventID])
GO
