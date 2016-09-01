CREATE TABLE [dbo].[tblScanningQADetail]
(
[ScannedData_PK] [bigint] NOT NULL,
[ScanningQANoteText_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScanningQADetail] ADD CONSTRAINT [PK_tblSanningQADetail] PRIMARY KEY CLUSTERED  ([ScannedData_PK], [ScanningQANoteText_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
