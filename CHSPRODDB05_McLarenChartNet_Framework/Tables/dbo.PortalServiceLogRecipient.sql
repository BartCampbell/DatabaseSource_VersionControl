CREATE TABLE [dbo].[PortalServiceLogRecipient]
(
[PortalServiceLogID] [uniqueidentifier] NOT NULL,
[PortalUserID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogRecipient] ADD CONSTRAINT [PK_PortalServiceLogRecipient] PRIMARY KEY CLUSTERED  ([PortalServiceLogID], [PortalUserID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogRecipient] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogRecipient_PortalServiceLog] FOREIGN KEY ([PortalServiceLogID]) REFERENCES [dbo].[PortalServiceLog] ([PortalServiceLogID])
GO
ALTER TABLE [dbo].[PortalServiceLogRecipient] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogRecipient_PortalUser] FOREIGN KEY ([PortalUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
