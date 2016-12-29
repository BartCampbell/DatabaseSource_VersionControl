CREATE TABLE [dbo].[tblScanningNotes]
(
[ScanningNote_PK] [tinyint] NOT NULL,
[Note_Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCNA] [bit] NOT NULL,
[LastUpdated] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScanningNotes] ADD CONSTRAINT [PK_tblScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
