CREATE TABLE [dbo].[tblSuspectScanningNotes]
(
[ScanningNote_PK] [tinyint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[dtInsert] [smalldatetime] NULL,
[User_PK] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuspectScanningNotes] ADD CONSTRAINT [PK_tblSuspectScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNote_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK] ON [dbo].[tblSuspectScanningNotes] ([Suspect_PK]) INCLUDE ([ScanningNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
