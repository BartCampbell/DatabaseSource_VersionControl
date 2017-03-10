CREATE TABLE [dbo].[FaxQueueEventType]
(
[FaxQueueEventTypeID] [int] NOT NULL,
[EventType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventTypeDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueueEventType] ADD CONSTRAINT [PK_FaxQueueEventType] PRIMARY KEY CLUSTERED  ([FaxQueueEventTypeID]) ON [PRIMARY]
GO
