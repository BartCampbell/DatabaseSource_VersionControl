CREATE TABLE [dbo].[PortalSitePagePartContent]
(
[PortalSitePagePartContentID] [uniqueidentifier] NOT NULL,
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PortalSitePagePartContent_CreateDate] DEFAULT (getdate()),
[PostedDate] [datetime] NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_PortalSitePagePartContent_IsEnabled] DEFAULT ((0)),
[PublishedStatus] [tinyint] NOT NULL,
[Content] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PortalSitePagePartContent_Content] DEFAULT (''),
[LastUpdate] [datetime] NULL,
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL,
[BeginDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartContent] ADD CONSTRAINT [PK_PortalSitePagePartContent] PRIMARY KEY CLUSTERED  ([PortalSitePagePartContentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartContent] WITH NOCHECK ADD CONSTRAINT [FK_PortalSitePagePartContent_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
