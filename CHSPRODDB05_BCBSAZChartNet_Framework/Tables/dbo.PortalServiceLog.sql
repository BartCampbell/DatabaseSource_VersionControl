CREATE TABLE [dbo].[PortalServiceLog]
(
[PortalServiceLogID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLog_PortalServiceLogID] DEFAULT (newid()),
[PortalServiceLogParentID] [uniqueidentifier] NULL,
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLog_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[ServiceID] [int] NOT NULL IDENTITY(1, 1),
[CreatorID] [uniqueidentifier] NOT NULL,
[OwnerID] [uniqueidentifier] NULL,
[AssignedUserID] [uniqueidentifier] NULL,
[PortalServiceLogStatusID] [uniqueidentifier] NULL,
[PortalServiceLogSeverityID] [uniqueidentifier] NULL,
[PortalServiceLogImportanceID] [uniqueidentifier] NULL,
[PortalServiceLogComplexityID] [uniqueidentifier] NULL,
[PortalServiceLogCategoryID] [uniqueidentifier] NULL,
[CategoryOther] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalServiceLogResolutionTypeID] [uniqueidentifier] NULL,
[ResolutionTypeOther] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [int] NULL,
[CreateDate] [datetime] NULL,
[LastUpdate] [datetime] NULL,
[RequestedDate] [datetime] NULL,
[DueDate] [datetime] NULL,
[IsWorkOrder] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLog_IsWorkOrder] DEFAULT ((0)),
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resolution] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLog] ADD CONSTRAINT [PK_PortalServiceLog] PRIMARY KEY CLUSTERED  ([PortalServiceLogID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLog] FOREIGN KEY ([PortalServiceLogParentID]) REFERENCES [dbo].[PortalServiceLog] ([PortalServiceLogID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogCategory] FOREIGN KEY ([PortalServiceLogCategoryID]) REFERENCES [dbo].[PortalServiceLogCategory] ([PortalServiceLogCategoryID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogComplexity] FOREIGN KEY ([PortalServiceLogComplexityID]) REFERENCES [dbo].[PortalServiceLogComplexity] ([PortalServiceLogComplexityID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogImportance] FOREIGN KEY ([PortalServiceLogImportanceID]) REFERENCES [dbo].[PortalServiceLogImportance] ([PortalServiceLogImportanceID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogResolutionType] FOREIGN KEY ([PortalServiceLogResolutionTypeID]) REFERENCES [dbo].[PortalServiceLogResolutionType] ([PortalServiceLogResolutionTypeID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogSeverity] FOREIGN KEY ([PortalServiceLogSeverityID]) REFERENCES [dbo].[PortalServiceLogSeverity] ([PortalServiceLogSeverityID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalServiceLogStatus] FOREIGN KEY ([PortalServiceLogStatusID]) REFERENCES [dbo].[PortalServiceLogStatus] ([PortalServiceLogStatusID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalUser] FOREIGN KEY ([CreatorID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalUser1] FOREIGN KEY ([OwnerID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
ALTER TABLE [dbo].[PortalServiceLog] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLog_PortalUser2] FOREIGN KEY ([AssignedUserID]) REFERENCES [dbo].[PortalUser] ([PortalUserID])
GO
