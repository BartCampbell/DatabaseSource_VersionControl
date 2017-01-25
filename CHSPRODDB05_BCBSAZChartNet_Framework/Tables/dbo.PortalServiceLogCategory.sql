CREATE TABLE [dbo].[PortalServiceLogCategory]
(
[PortalServiceLogCategoryID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogCategory_ID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalServiceLogCategory_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalServiceLogCategory_SortNum] DEFAULT ((0)),
[IsDefault] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogCategory_IsDefault] DEFAULT ((0)),
[IsOther] [bit] NOT NULL CONSTRAINT [DF_PortalServiceLogCategory_IsOther] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogCategory] ADD CONSTRAINT [PK_PortalServiceLogCategory] PRIMARY KEY CLUSTERED  ([PortalServiceLogCategoryID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalServiceLogCategory] WITH NOCHECK ADD CONSTRAINT [FK_PortalServiceLogCategory_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
