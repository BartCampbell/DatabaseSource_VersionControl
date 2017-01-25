CREATE TABLE [dbo].[PortalSitePagePartContentNote]
(
[PortalSitePagePartContentNoteID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_PortalSitePagePartContentNote_PortalSitePagePartContentNodeID] DEFAULT (newid()),
[PortalSitePagePartContentID] [uniqueidentifier] NOT NULL,
[UserID] [uniqueidentifier] NOT NULL,
[NoteDate] [datetime] NOT NULL,
[NoteText] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PublishedStatus] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartContentNote] ADD CONSTRAINT [PK_PortalSitePagePartContentNote] PRIMARY KEY CLUSTERED  ([PortalSitePagePartContentNoteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PortalSitePagePartContentNote] ADD CONSTRAINT [FK_PortalSitePagePartContentNote_PortalSitePagePartContent] FOREIGN KEY ([PortalSitePagePartContentID]) REFERENCES [dbo].[PortalSitePagePartContent] ([PortalSitePagePartContentID])
GO
