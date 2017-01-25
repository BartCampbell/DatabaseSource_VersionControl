CREATE TABLE [dbo].[PortalLog]
(
[PortalLogID] [int] NOT NULL IDENTITY(1, 1),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalLog_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[PortalUserID] [uniqueidentifier] NULL,
[EventDescription] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AffectedObject] [uniqueidentifier] NULL,
[Source] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LogLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventTime] [datetime] NOT NULL CONSTRAINT [DF_PortalLog_EventTime] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalLog] ADD CONSTRAINT [PK_PortalLog] PRIMARY KEY CLUSTERED  ([PortalLogID]) ON [PRIMARY]
GO
