CREATE TABLE [dbo].[S_NoteTextDetail]
(
[S_NoteTextDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_NoteText_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteText] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDiagnosisNote] [bit] NULL,
[IsChartNote] [bit] NULL,
[Client_PK] [smallint] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_NoteTextDetail] ADD CONSTRAINT [PK_S_NoteTextDetail] PRIMARY KEY CLUSTERED  ([S_NoteTextDetail_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081455] ON [dbo].[S_NoteTextDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_NoteTextDetail] ADD CONSTRAINT [FK_H_NoteText_RK4] FOREIGN KEY ([H_NoteText_RK]) REFERENCES [dbo].[H_NoteText] ([H_NoteText_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
