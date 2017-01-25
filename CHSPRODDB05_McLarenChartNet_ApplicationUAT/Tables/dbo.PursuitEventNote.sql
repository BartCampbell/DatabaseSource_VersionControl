CREATE TABLE [dbo].[PursuitEventNote]
(
[NoteID] [int] NOT NULL IDENTITY(1, 1),
[PursuitEventID] [int] NOT NULL,
[PursuitEventNoteCategoryID] [int] NULL,
[ParentID] [int] NULL,
[NoteText] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PursuitEventNote_CreateUser] DEFAULT ('admin'),
[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEventNote_CreateDate] DEFAULT (getdate()),
[UpdateUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventNote] ADD CONSTRAINT [PK_PursuitEventNote] PRIMARY KEY CLUSTERED  ([NoteID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEventNote] ADD CONSTRAINT [FK_PursuitEventNote_PursuitEvent] FOREIGN KEY ([PursuitEventID]) REFERENCES [dbo].[PursuitEvent] ([PursuitEventID])
GO
ALTER TABLE [dbo].[PursuitEventNote] ADD CONSTRAINT [fk_PursuitEventNote_PursuitEventNoteCategory] FOREIGN KEY ([PursuitEventNoteCategoryID]) REFERENCES [dbo].[PursuitEventNoteCategory] ([PursuitEventNoteCategoryID])
GO
