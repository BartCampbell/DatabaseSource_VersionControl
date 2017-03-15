CREATE TABLE [adv].[tblCodedDataNoteTextStage]
(
[CodedData_PK] [bigint] NOT NULL,
[Note_Text] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblCodedD__LoadD__190D4771] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedDataNoteTextStage] ADD CONSTRAINT [PK_tblCodedDataNoteTextStage] PRIMARY KEY CLUSTERED  ([CodedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
