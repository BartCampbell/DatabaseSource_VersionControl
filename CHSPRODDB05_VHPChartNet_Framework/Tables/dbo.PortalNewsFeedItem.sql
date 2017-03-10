CREATE TABLE [dbo].[PortalNewsFeedItem]
(
[PortalNewsFeedItemID] [uniqueidentifier] NOT NULL,
[PortalNewsFeedID] [uniqueidentifier] NOT NULL,
[Title] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TeaserText] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PortalNewsFeedItemText] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PortalNewsFeedItemDate] [datetime] NOT NULL,
[IsAggregationAllowed] [bit] NOT NULL CONSTRAINT [DF_PortalNewsFeedItem_IsAggregationAllowed] DEFAULT ((1)),
[PublishedStatus] [tinyint] NOT NULL CONSTRAINT [DF_PortalNewsFeedItem_PublishedStatus] DEFAULT ((0)),
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalNewsFeedItem] ADD CONSTRAINT [PK_PortalNewsFeedItem] PRIMARY KEY CLUSTERED  ([PortalNewsFeedItemID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalNewsFeedItem] ADD CONSTRAINT [FK_PortalNewsFeedItem_PortalNewsFeed] FOREIGN KEY ([PortalNewsFeedID]) REFERENCES [dbo].[PortalNewsFeed] ([PortalNewsFeedID])
GO
