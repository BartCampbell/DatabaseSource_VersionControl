CREATE TABLE [dbo].[L_NoteTextType]
(
[L_NoteTextType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_NoteType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTextType] ADD CONSTRAINT [PK_L_NoteTextType] PRIMARY KEY CLUSTERED  ([L_NoteTextType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTextType] ADD CONSTRAINT [FK_H_NoteText_RK1] FOREIGN KEY ([H_NoteText_RK]) REFERENCES [dbo].[H_NoteText] ([H_NoteText_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_NoteTextType] ADD CONSTRAINT [FK_H_NoteType_RK2] FOREIGN KEY ([H_NoteType_RK]) REFERENCES [dbo].[H_NoteType] ([H_NoteType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
