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
