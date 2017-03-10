CREATE TABLE [dbo].[PortalSharedContent]
(
[PortalSharedContentID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSharedContent_PortalSharedContentID] DEFAULT (newid()),
[PortalSiteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSharedContent_PortalSiteID] DEFAULT ('00000000-0000-0000-0000-000000000000'),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PortalSharedContent_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL,
[BeginDate] [datetime] NULL CONSTRAINT [DF_PortalSharedContent_BeginDate] DEFAULT (getdate()),
[EndDate] [datetime] NULL,
[PublishedStatus] [tinyint] NOT NULL,
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL,
[PortalSharedContentText] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSharedContent] ADD CONSTRAINT [PK_PortalSharedContent] PRIMARY KEY CLUSTERED  ([PortalSharedContentID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSharedContent] ADD CONSTRAINT [FK_PortalSharedContent_PortalSite] FOREIGN KEY ([PortalSiteID]) REFERENCES [dbo].[PortalSite] ([PortalSiteID])
GO
