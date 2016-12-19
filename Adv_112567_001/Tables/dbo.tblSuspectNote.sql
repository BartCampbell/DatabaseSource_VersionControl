CREATE TABLE [dbo].[tblSuspectNote]
(
[Suspect_PK] [bigint] NOT NULL,
[NoteText_PK] [smallint] NOT NULL,
[Coded_User_PK] [smallint] NULL,
[Coded_Date] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectNote] ADD CONSTRAINT [PK_tblSuspectNote] PRIMARY KEY CLUSTERED  ([Suspect_PK], [NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
