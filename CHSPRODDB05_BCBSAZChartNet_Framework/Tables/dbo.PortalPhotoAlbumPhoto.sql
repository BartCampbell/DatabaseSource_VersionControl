CREATE TABLE [dbo].[PortalPhotoAlbumPhoto]
(
[PortalPhotoAlbumPhotoID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalPhotoAlbumPhoto_ID] DEFAULT (newid()),
[PortalPhotoAlbumID] [uniqueidentifier] NULL,
[PhotoFileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ThumbFileName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhotoDate] [datetime] NULL,
[Width] [smallint] NULL,
[Height] [smallint] NULL,
[ThumbWidth] [smallint] NULL,
[ThumbHeight] [smallint] NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_PortalPhoto_PhotoIsEnabled] DEFAULT ((0)),
[SortNum] [int] NOT NULL CONSTRAINT [DF_PortalPhoto_SortNum] DEFAULT ((0)),
[PublishedStatus] [tinyint] NOT NULL CONSTRAINT [DF_PortalPhotoAlbumPhoto_PublishedStatus] DEFAULT ((0)),
[UserCreatorID] [uniqueidentifier] NULL,
[UserApprovalID] [uniqueidentifier] NULL,
[UserPublishID] [uniqueidentifier] NULL,
[OriginalImage] [image] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoAlbumPhoto] ADD CONSTRAINT [PK_PortalPhotoAlbumPhoto] PRIMARY KEY CLUSTERED  ([PortalPhotoAlbumPhotoID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoAlbumPhoto] ADD CONSTRAINT [FK_PortalPhotoAlbumPhoto_PortalPhotoAlbum] FOREIGN KEY ([PortalPhotoAlbumID]) REFERENCES [dbo].[PortalPhotoAlbum] ([PortalPhotoAlbumID])
GO
