CREATE TABLE [adv].[tblCodedDataNoteStage]
(
[CodedData_PK] [bigint] NOT NULL,
[NoteText_PK] [smallint] NOT NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblCodedD__LoadD__18192338] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedDataNoteStage] ADD CONSTRAINT [PK_tblCodedDataNoteStage] PRIMARY KEY CLUSTERED  ([CodedData_PK], [NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
