CREATE TABLE [dbo].[PortalPhotoCategory]
(
[PortalPhotoCategoryID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_PortalPhotoCategory_IsEnabled] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalPhotoCategory] ADD CONSTRAINT [PK_PortalPhotoCategory] PRIMARY KEY CLUSTERED  ([PortalPhotoCategoryID]) ON [PRIMARY]
GO
