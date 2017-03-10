CREATE TABLE [dbo].[PortalNewsFeed]
(
[PortalNewsFeedID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalNewsFeed_PortalNewsFeedID] DEFAULT (newid()),
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsAggregate] [bit] NOT NULL CONSTRAINT [DF_PortalNewsFeed_IsAggregate] DEFAULT ((0)),
[IsAggregationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalNewsFeed_IsAggregationAllowed] DEFAULT ((0)),
[LastUpdate] [datetime] NULL,
[FeedImage] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Author] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRssFeedEnabled] [bit] NULL CONSTRAINT [DF_PortalNewsFeed_IsRssFeedEnabled] DEFAULT ((1)),
[MaximumItemsToDisplay] [int] NULL,
[ShowFullTextOnly] [bit] NULL,
[RssFullTextOnly] [bit] NULL,
[MaximumRssItems] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalNewsFeed] ADD CONSTRAINT [PK_PortalNewsFeed] PRIMARY KEY CLUSTERED  ([PortalNewsFeedID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalNewsFeed] WITH NOCHECK ADD CONSTRAINT [FK_PortalNewsFeed_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
