CREATE TABLE [dbo].[PortalPhotoCategoryPhoto]
(
[PortalPhotoAlbumPhotoID] [uniqueidentifier] NOT NULL,
[PortalPhotoCategoryID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoCategoryPhoto] ADD CONSTRAINT [PK_PortalPhotoCategoryPhoto] PRIMARY KEY CLUSTERED  ([PortalPhotoAlbumPhotoID], [PortalPhotoCategoryID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoCategoryPhoto] ADD CONSTRAINT [FK_PortalPhotoCategoryPhoto_PortalPhotoAlbumPhoto] FOREIGN KEY ([PortalPhotoAlbumPhotoID]) REFERENCES [dbo].[PortalPhotoAlbumPhoto] ([PortalPhotoAlbumPhotoID])
GO
ALTER TABLE [dbo].[PortalPhotoCategoryPhoto] ADD CONSTRAINT [FK_PortalPhotoCategoryPhoto_PortalPhotoCategory] FOREIGN KEY ([PortalPhotoCategoryID]) REFERENCES [dbo].[PortalPhotoCategory] ([PortalPhotoCategoryID])
GO
