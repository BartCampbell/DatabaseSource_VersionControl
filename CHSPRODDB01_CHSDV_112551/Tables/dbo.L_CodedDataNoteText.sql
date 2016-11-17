CREATE TABLE [dbo].[L_CodedDataNoteText]
(
[L_CodedDataNoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_CodedData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataNoteText] ADD CONSTRAINT [PK_L_CodedDataNoteText] PRIMARY KEY CLUSTERED  ([L_CodedDataNoteText_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_CodedDataNoteText] ADD CONSTRAINT [FK_H_CodedData_RK6] FOREIGN KEY ([H_CodedData_RK]) REFERENCES [dbo].[H_CodedData] ([H_CodedData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_CodedDataNoteText] ADD CONSTRAINT [FK_H_NoteText_RK3] FOREIGN KEY ([H_NoteText_RK]) REFERENCES [dbo].[H_NoteText] ([H_NoteText_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
