CREATE TABLE [dbo].[R_NoteText]
(
[CentauriNoteTextID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNoteTextID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTextHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriNoteTextID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_NoteText] ADD CONSTRAINT [PK_R_NoteText] PRIMARY KEY CLUSTERED  ([CentauriNoteTextID]) ON [PRIMARY]
GO
