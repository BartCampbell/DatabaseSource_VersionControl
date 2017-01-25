CREATE TABLE [dbo].[PortalPhotoAlbum]
(
[PortalPhotoAlbumID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalPhotoAlbum_PortalPhotoAlbumID] DEFAULT (newid()),
[PortalSitePagePartID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxWidth] [smallint] NULL,
[MaxHeight] [smallint] NULL,
[MaxThumbWidth] [smallint] NULL,
[MaxThumbHeight] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoAlbum] ADD CONSTRAINT [PK_PortalPhotoAlbum] PRIMARY KEY CLUSTERED  ([PortalPhotoAlbumID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoAlbum] WITH NOCHECK ADD CONSTRAINT [FK_PortalPhotoAlbum_PortalSitePagePart] FOREIGN KEY ([PortalSitePagePartID]) REFERENCES [dbo].[PortalSitePagePart] ([PortalSitePagePartID])
GO
