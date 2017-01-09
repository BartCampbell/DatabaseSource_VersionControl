CREATE TABLE [dbo].[tblNoteText]
(
[NoteText_PK] [smallint] NOT NULL IDENTITY(1, 1),
[NoteText] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDiagnosisNote] [bit] NULL,
[IsChartNote] [bit] NULL,
[Client_PK] [smallint] NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteType_PK] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblNoteText] ADD CONSTRAINT [PK_tblNoteText] PRIMARY KEY CLUSTERED  ([NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_IsChartNote] ON [dbo].[tblNoteText] ([IsChartNote]) INCLUDE ([NoteText], [NoteText_PK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IsDiagNote] ON [dbo].[tblNoteText] ([IsDiagnosisNote]) INCLUDE ([NoteText], [NoteText_PK], [NoteType_PK]) ON [PRIMARY]
GO
