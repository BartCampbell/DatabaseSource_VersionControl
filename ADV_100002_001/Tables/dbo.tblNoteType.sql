CREATE TABLE [dbo].[tblNoteType]
(
[NoteType_PK] [tinyint] NOT NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NoteType] ON [dbo].[tblNoteType] ([NoteType_PK]) INCLUDE ([NoteType]) ON [PRIMARY]
GO
