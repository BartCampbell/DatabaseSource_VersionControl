CREATE TABLE [dbo].[tblSuspectNote]
(
[Suspect_PK] [bigint] NOT NULL,
[NoteText_PK] [smallint] NOT NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL,
[IsConfirmed] [bit] NULL,
[IsRemoved] [bit] NULL,
[IsAdded] [bit] NULL,
[QA_User_PK] [smallint] NULL,
[QA_Date] [smalldatetime] NULL,
[CoderLevel] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectNote] ADD CONSTRAINT [PK_tblSuspectNote] PRIMARY KEY CLUSTERED  ([Suspect_PK], [NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
