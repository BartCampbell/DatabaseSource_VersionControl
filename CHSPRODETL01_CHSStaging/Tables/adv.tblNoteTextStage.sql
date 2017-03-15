CREATE TABLE [adv].[tblNoteTextStage]
(
[NoteText_PK] [smallint] NOT NULL,
[NoteText] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDiagnosisNote] [bit] NULL,
[IsChartNote] [bit] NULL,
[Client_PK] [smallint] NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteType_PK] [tinyint] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTextHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblNoteTextStage] ADD CONSTRAINT [PK_tblNoteText] PRIMARY KEY CLUSTERED  ([NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
