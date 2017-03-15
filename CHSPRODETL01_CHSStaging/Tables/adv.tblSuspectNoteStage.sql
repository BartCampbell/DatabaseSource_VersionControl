CREATE TABLE [adv].[tblSuspectNoteStage]
(
[Suspect_PK] [bigint] NOT NULL,
[NoteText_PK] [smallint] NOT NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL,
[Client] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__LoadD__2667428F] DEFAULT (getdate()),
[CCI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectUserNoteHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuspectHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTextHashKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSI] [int] NULL,
[CUI] [int] NULL,
[CNI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectNoteStage] ADD CONSTRAINT [PK_tblSuspectNoteStage] PRIMARY KEY CLUSTERED  ([Suspect_PK], [NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
