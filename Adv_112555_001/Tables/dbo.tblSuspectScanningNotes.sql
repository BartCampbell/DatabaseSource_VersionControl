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
-- =============================================
-- Author:		Sajid Ali
-- Create date: March 21,2014
-- Description:	Trigger to upated Coded date and user in suspect table
-- =============================================
CREATE TRIGGER [dbo].[ins_tblSuspectScanningNotes] 
   ON  [dbo].[tblSuspectScanningNotes]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE tblSuspect SET 
			IsCNA=1,
			CNA_Date= CASE WHEN CNA_User_PK IS NULL THEN GetDate() ELSE CNA_Date END,
			CNA_User_PK=CASE WHEN CNA_User_PK IS NULL THEN (SELECT User_PK FROM INSERTED) ELSE CNA_User_PK END,
			LastAccessed_Date = GetDate(),
			LastUpdated = GetDate()
		WHERE SUSPECT_PK IN (SELECT SUSPECT_PK FROM INSERTED) AND IsNull(IsScanned,0)=0
END
GO
ALTER TABLE [dbo].[tblSuspectScanningNotes] ADD CONSTRAINT [PK_tblSuspectScanningNotes] PRIMARY KEY CLUSTERED  ([ScanningNote_PK], [Suspect_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SuspectPK] ON [dbo].[tblSuspectScanningNotes] ([Suspect_PK]) INCLUDE ([ScanningNote_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
