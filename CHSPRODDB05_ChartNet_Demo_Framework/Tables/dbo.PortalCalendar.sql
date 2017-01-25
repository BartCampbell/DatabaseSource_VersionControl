CREATE TABLE [dbo].[PortalCalendar]
(
[PortalCalendarID] [uniqueidentifier] NOT NULL,
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsAggregateCalender] [bit] NOT NULL CONSTRAINT [DF_PortalCalendar_IsAggregateCalender] DEFAULT ((0)),
[IsAggregationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalCalendar_IsAggregationAllowed] DEFAULT ((0)),
[IsTaskCreationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalCalendar_IsTaskCreationAllowed] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendar] ADD CONSTRAINT [PK_PortalCalendar] PRIMARY KEY CLUSTERED  ([PortalCalendarID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalCalendar] WITH NOCHECK ADD CONSTRAINT [FK_PortalCalendar_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
