CREATE TABLE [dbo].[H_NoteType]
(
[H_NoteType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NoteType_BK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNoteTypeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__H_NoteTyp__LoadD__41EDCAC5] DEFAULT (getdate()),
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_NoteType] ADD CONSTRAINT [PK_H_NoteType] PRIMARY KEY CLUSTERED  ([H_NoteType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
