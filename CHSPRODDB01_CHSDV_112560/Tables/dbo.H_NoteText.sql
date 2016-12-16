CREATE TABLE [dbo].[H_NoteText]
(
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NoteText_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNoteTextID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_NoteTex__LoadD__2DB1C7EE] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_NoteText] ADD CONSTRAINT [PK_H_NoteText] PRIMARY KEY CLUSTERED  ([H_NoteText_RK]) ON [PRIMARY]
GO
