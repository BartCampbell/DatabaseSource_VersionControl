CREATE TABLE [dbo].[PortalDocumentType]
(
[PortalDocumentTypeID] [uniqueidentifier] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MimeType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileExtension] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalDocumentType] ADD CONSTRAINT [PortalDocumentType_PK] PRIMARY KEY CLUSTERED  ([PortalDocumentTypeID]) ON [PRIMARY]
GO
