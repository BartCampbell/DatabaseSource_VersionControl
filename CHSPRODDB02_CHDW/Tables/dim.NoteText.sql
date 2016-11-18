CREATE TABLE [dim].[NoteText]
(
[NoteTextID] [int] NOT NULL IDENTITY(1, 1),
[CentauriNoteTextid] [int] NULL,
[NoteText] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDiagnosisNote] [bit] NULL,
[IsChartNote] [bit] NULL,
[Client_PK] [smallint] NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteType_PK] [tinyint] NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF_NoteText_CreateDate] DEFAULT (getdate()),
[LastUpdate] [datetime] NULL CONSTRAINT [DF_NoteText_LastUpdate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dim].[NoteText] ADD CONSTRAINT [PK_NoteText] PRIMARY KEY CLUSTERED  ([NoteTextID]) ON [PRIMARY]
GO
