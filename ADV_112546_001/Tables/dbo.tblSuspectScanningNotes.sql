CREATE TABLE [dbo].[tblSuspectScanningNotes]
(
[ScanningNote_PK] [tinyint] NOT NULL,
[Suspect_PK] [bigint] NOT NULL,
[dtInsert] [smalldatetime] NULL,
[User_PK] [smallint] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ins_tblSuspectScanningNotes] 
   ON  [dbo].[tblSuspectScanningNotes]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
		Update S SET 
			IsCNA=1,
			CNA_Date=T.dtInsert, 
			CNA_User_PK=T.User_PK,			
			LastAccessed_Date = GetDate(),
			LastUpdated = GetDate()
		FROM INSERTED T INNER JOIN tblSuspect S ON S.Suspect_PK = T.Suspect_PK 
		WHERE IsCNA=0 AND IsScanned=0
END
GO
ALTER TABLE [dbo].[tblSuspectScanningNotes] ADD CONSTRAINT [PK_tblSuspectScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNote_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK] ON [dbo].[tblSuspectScanningNotes] ([Suspect_PK]) INCLUDE ([ScanningNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
