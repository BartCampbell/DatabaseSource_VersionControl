CREATE TABLE [dbo].[tblCodedDataNoteText]
(
[CodedData_PK] [bigint] NOT NULL,
[Note_Text] [varchar] (1000) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCodedDataNoteText] ADD CONSTRAINT [PK_tblCodedDataNoteText] PRIMARY KEY CLUSTERED  ([CodedData_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
