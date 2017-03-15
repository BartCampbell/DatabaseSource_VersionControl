CREATE TABLE [adv].[tblSuspectNoteTextStage]
(
[Suspect_PK] [bigint] NOT NULL,
[Note_Text] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__LoadD__284F8B01] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectNoteTextStage] ADD CONSTRAINT [PK_tblSuspectNoteTextStage] PRIMARY KEY CLUSTERED  ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
