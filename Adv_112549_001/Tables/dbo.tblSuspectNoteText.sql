CREATE TABLE [dbo].[tblSuspectNoteText]
(
[Suspect_PK] [bigint] NOT NULL,
[Note_Text] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL,
[CoderLevel] [tinyint] NULL,
[QA_User_PK] [smallint] NULL,
[QA_Date] [smalldatetime] NULL,
[BeforeQANote_Text] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QANote_Text] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectNoteText] ADD CONSTRAINT [PK_tblSuspectNoteText] PRIMARY KEY CLUSTERED  ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
