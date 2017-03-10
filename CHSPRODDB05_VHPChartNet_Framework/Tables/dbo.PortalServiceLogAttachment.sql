CREATE TABLE [dbo].[PortalServiceLogAttachment]
(
[PortalServiceLogAttachmentID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogAttachment_ID] DEFAULT (newid()),
[PortalServiceLogID] [uniqueidentifier] NOT NULL,
[FileName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AttachmentDate] [datetime] NOT NULL CONSTRAINT [DF_PortalServiceLogAttachment_ServiceLogAttachmentDate] DEFAULT (getdate()),
[FileImage] [image] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogAttachment] ADD CONSTRAINT [PK_PortalServiceLogAttachment] PRIMARY KEY CLUSTERED  ([PortalServiceLogAttachmentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogAttachment] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogAttachment_PortalServiceLog] FOREIGN KEY ([PortalServiceLogID]) REFERENCES [dbo].[PortalServiceLog] ([PortalServiceLogID])
GO
