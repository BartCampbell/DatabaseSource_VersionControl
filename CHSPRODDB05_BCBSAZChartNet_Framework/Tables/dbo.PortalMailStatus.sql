CREATE TABLE [dbo].[PortalMailStatus]
(
[PortalMailStatusID] [tinyint] NOT NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalMailStatus] ADD CONSTRAINT [MailStatus_PK] PRIMARY KEY CLUSTERED  ([PortalMailStatusID]) ON [PRIMARY]
GO
