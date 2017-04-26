CREATE TABLE [dbo].[tblCodedDataNote]
(
[CodedData_PK] [bigint] NOT NULL,
[NoteText_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCodedDataNote] ADD CONSTRAINT [PK_tblCodedDataNote] PRIMARY KEY CLUSTERED  ([CodedData_PK], [NoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
