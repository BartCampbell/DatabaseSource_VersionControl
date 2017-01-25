CREATE TABLE [dbo].[FaxQueueEvent]
(
[FaxQueueEventID] [int] NOT NULL,
[FaxQueueID] [int] NOT NULL,
[FaxQueueEventTypeID] [int] NOT NULL,
[EventDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueueEvent] ADD CONSTRAINT [PK_FaxQueueEvent] PRIMARY KEY CLUSTERED  ([FaxQueueEventID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueueEvent] ADD CONSTRAINT [FK_FaxQueueEvent_FaxQueue] FOREIGN KEY ([FaxQueueID]) REFERENCES [dbo].[FaxQueue] ([FaxQueueID])
GO
ALTER TABLE [dbo].[FaxQueueEvent] ADD CONSTRAINT [FK_FaxQueueEvent_FaxQueueEventType] FOREIGN KEY ([FaxQueueEventTypeID]) REFERENCES [dbo].[FaxQueueEventType] ([FaxQueueEventTypeID])
GO
