CREATE TABLE [dbo].[tblScanningQANote]
(
[ScanningQANote_PK] [tinyint] NOT NULL,
[QANote_Text] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScanningQANote] ADD CONSTRAINT [PK_tblScanningQANote] PRIMARY KEY CLUSTERED  ([ScanningQANote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
