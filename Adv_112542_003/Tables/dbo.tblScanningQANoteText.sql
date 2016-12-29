CREATE TABLE [dbo].[tblScanningQANoteText]
(
[ScanningQANoteText_PK] [smallint] NOT NULL,
[ScanningQANoteText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCopy] [bit] NULL,
[IsMove] [bit] NULL,
[IsRemove] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScanningQANoteText] ADD CONSTRAINT [PK_tblScanningQANoteText] PRIMARY KEY CLUSTERED  ([ScanningQANoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
