CREATE TABLE [dbo].[PortalMailRecipient]
(
[PortalMailRecipientID] [uniqueidentifier] NOT NULL,
[PortalMailQueueID] [uniqueidentifier] NOT NULL,
[RecipientAddress] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecipientType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailRecipient] ADD CONSTRAINT [CK_PortalMailRecipient_Type] CHECK ((upper([RecipientType])='BCC' OR upper([RecipientType])='CC' OR upper([RecipientType])='TO'))
GO
ALTER TABLE [dbo].[PortalMailRecipient] ADD CONSTRAINT [MailRecipient_PK] PRIMARY KEY CLUSTERED  ([PortalMailRecipientID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailRecipient] ADD CONSTRAINT [PortalMailQueue_PortalMailRecipient_FK1] FOREIGN KEY ([PortalMailQueueID]) REFERENCES [dbo].[PortalMailQueue] ([PortalMailQueueID])
GO
