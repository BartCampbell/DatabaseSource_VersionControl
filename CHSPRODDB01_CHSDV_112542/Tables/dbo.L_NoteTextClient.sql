CREATE TABLE [dbo].[L_NoteTextClient]
(
[L_NoteTextClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTextClient] ADD CONSTRAINT [PK_L_NoteTextClient] PRIMARY KEY CLUSTERED  ([L_NoteTextClient_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTextClient] ADD CONSTRAINT [FK_H_Client_RK5] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_NoteTextClient] ADD CONSTRAINT [FK_H_NoteText_RK] FOREIGN KEY ([H_NoteText_RK]) REFERENCES [dbo].[H_NoteText] ([H_NoteText_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
