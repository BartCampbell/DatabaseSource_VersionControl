CREATE TABLE [dbo].[PortalServiceLogFilter]
(
[PortalServiceLogFilterID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogFilter_PortalServiceLogFilterID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogFilter_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterText] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogFilter_IsEnabled] DEFAULT ((0)),
[IsCustomSQL] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogFilter_IsCustomSQL] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogFilter] ADD CONSTRAINT [PK_PortalServiceLogFilter] PRIMARY KEY CLUSTERED  ([PortalServiceLogFilterID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogFilter] ADD CONSTRAINT [FK_PortalServiceLogFilter_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
