CREATE TABLE [dbo].[R_NoteType]
(
[CentauriNoteTypeID] [int] NOT NULL IDENTITY(10100, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNoteTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTypeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriNoteTypeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_NoteType] ADD CONSTRAINT [PK_R_NoteType] PRIMARY KEY CLUSTERED  ([CentauriNoteTypeID]) ON [PRIMARY]
GO
