CREATE TABLE [dbo].[FaxQueueStatus]
(
[FaxQueueStatusID] [int] NOT NULL,
[FaxStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FaxQueueStatus] ADD CONSTRAINT [PK_FaxQueueStatus] PRIMARY KEY CLUSTERED  ([FaxQueueStatusID]) ON [PRIMARY]
GO
