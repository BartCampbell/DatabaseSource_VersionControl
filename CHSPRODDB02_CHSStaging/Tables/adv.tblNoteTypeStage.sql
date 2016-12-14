CREATE TABLE [adv].[tblNoteTypeStage]
(
[NoteType_PK] [tinyint] NOT NULL,
[NoteType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[CCI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTypeHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CTI] [int] NULL
) ON [PRIMARY]
GO
