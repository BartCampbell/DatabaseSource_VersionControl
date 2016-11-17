CREATE TABLE [dbo].[L_NoteTypeClient]
(
[L_NoteTypeClient_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_NoteType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Client_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTypeClient] ADD CONSTRAINT [PK_L_NoteTypeClient] PRIMARY KEY CLUSTERED  ([L_NoteTypeClient_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_NoteTypeClient] ADD CONSTRAINT [FK_H_Client_RK6] FOREIGN KEY ([H_Client_RK]) REFERENCES [dbo].[H_Client] ([H_Client_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_NoteTypeClient] ADD CONSTRAINT [FK_H_NoteType_RK] FOREIGN KEY ([H_NoteType_RK]) REFERENCES [dbo].[H_NoteType] ([H_NoteType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
