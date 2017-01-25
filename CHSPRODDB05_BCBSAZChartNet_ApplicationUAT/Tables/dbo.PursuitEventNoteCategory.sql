CREATE TABLE [dbo].[PursuitEventNoteCategory]
(
[PursuitEventNoteCategoryID] [int] NOT NULL,
[ParentID] [int] NULL,
[SortOrder] [tinyint] NOT NULL CONSTRAINT [DF_PursuitEventNoteCategory_SortOrder] DEFAULT ((0)),
[Title] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventNoteCategory] ADD CONSTRAINT [PK__PursuitE__EDB386942A8B4280] PRIMARY KEY CLUSTERED  ([PursuitEventNoteCategoryID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventNoteCategory] ADD CONSTRAINT [FK__PursuitEv__Paren__2C738AF2] FOREIGN KEY ([ParentID]) REFERENCES [dbo].[PursuitEventNoteCategory] ([PursuitEventNoteCategoryID])
GO
