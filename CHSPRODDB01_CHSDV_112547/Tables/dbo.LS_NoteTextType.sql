CREATE TABLE [dbo].[LS_NoteTextType]
(
[LS_NoteTextType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_NoteTextType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_NoteType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_NoteTextType] ADD CONSTRAINT [PK_LS_NoteTextType] PRIMARY KEY CLUSTERED  ([LS_NoteTextType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_NoteTextType] ADD CONSTRAINT [FK_L_NoteTextType_RK1] FOREIGN KEY ([L_NoteTextType_RK]) REFERENCES [dbo].[L_NoteTextType] ([L_NoteTextType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
