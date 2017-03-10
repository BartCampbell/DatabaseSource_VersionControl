CREATE TABLE [dbo].[PortalMailQueueAttachment]
(
[PortalMailQueueAttachmentID] [uniqueidentifier] NOT NULL,
[AttachmentFile] [image] NOT NULL,
[AttachmentFileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalMailQueueID] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailQueueAttachment] ADD CONSTRAINT [PortalMailQueueAttachment_PK] PRIMARY KEY CLUSTERED  ([PortalMailQueueAttachmentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailQueueAttachment] WITH NOCHECK ADD CONSTRAINT [PortalMailQueue_PortalMailQueueAttachment_FK1] FOREIGN KEY ([PortalMailQueueID]) REFERENCES [dbo].[PortalMailQueue] ([PortalMailQueueID])
GO
