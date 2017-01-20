CREATE TABLE [dbo].[tblScanningQANote_Suspect]
(
[Suspect_PK] [bigint] NOT NULL,
[ScanningQANote_PK] [tinyint] NOT NULL,
[dtQA] [smalldatetime] NULL,
[QA_User_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblScanningQANote_Suspect] ADD CONSTRAINT [PK_tblScanningQANote_Suspect] PRIMARY KEY CLUSTERED  ([Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScanningQANote_Suspect_QAUser] ON [dbo].[tblScanningQANote_Suspect] ([QA_User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblScanningQANote_Suspect_Note] ON [dbo].[tblScanningQANote_Suspect] ([ScanningQANote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
