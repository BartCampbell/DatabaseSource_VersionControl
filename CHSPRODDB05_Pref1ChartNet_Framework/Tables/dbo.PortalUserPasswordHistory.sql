CREATE TABLE [dbo].[PortalUserPasswordHistory]
(
[PortalUserPasswordHistoryID] [uniqueidentifier] NOT NULL,
[PortalUserID] [uniqueidentifier] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_PortalUserPasswordHistory_CreatedDate] DEFAULT (getdate()),
[PasswordHash] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Salt] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserPasswordHistory] ADD CONSTRAINT [PK_PortalUserPasswordHistory] PRIMARY KEY NONCLUSTERED  ([PortalUserPasswordHistoryID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalUserPasswordHistory] WITH NOCHECK ADD CONSTRAINT [FK_PortalUserPasswordHistory_PortalUser] FOREIGN KEY ([PortalUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
