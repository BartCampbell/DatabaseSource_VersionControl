CREATE TABLE [dbo].[S_NoteTypeDetail]
(
[S_NoteTypeDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_NoteType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_NoteTypeDetail] ADD CONSTRAINT [PK_S_NoteTypeDetail] PRIMARY KEY CLUSTERED  ([S_NoteTypeDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_NoteTypeDetail] ADD CONSTRAINT [FK_H_NoteType_RK4] FOREIGN KEY ([H_NoteType_RK]) REFERENCES [dbo].[H_NoteType] ([H_NoteType_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
