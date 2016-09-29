SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_mark_removed '0',1,1,1,1
CREATE PROCEDURE [dbo].[imv_mark_removed] 
	@ids varchar(MAX),
	@qa_note int,
	@Source_Suspect bigint,
	@Usr int,
	@EA int
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)

	IF @EA=0
	BEGIN
		IF NOT EXISTS (SELECT * FROM tblScanningQANote_Suspect WITH (NOLOCK) WHERE Suspect_PK=@Source_Suspect)
			INSERT INTO tblScanningQANote_Suspect(Suspect_PK,ScanningQANote_PK,dtQA,QA_User_PK) VALUES (@Source_Suspect,2,GetDate(),@Usr)
		ELSE
			Update tblScanningQANote_Suspect WITH (ROWLOCK) SET ScanningQANote_PK=2, dtQA=GETDATE(), QA_User_PK=@Usr WHERE Suspect_PK=@Source_Suspect
	END

	SET @SQL = 'DELETE FROM tblScanningQADetail WITH (ROWLOCK) WHERE ScannedData_PK IN ('+ @ids +'); Insert Into tblScanningQADetail(ScannedData_PK,ScanningQANoteText_PK) SELECT DISTINCT ScannedData_PK,'+CAST(@qa_note AS varchar)+' FROM tblScannedData WHERE ScannedData_PK IN ('+ @ids +')'
	EXEC(@SQL);

	SET @SQL = 'UPDATE tblScannedData WITH (ROWLOCK) SET is_deleted=1 WHERE ScannedData_PK IN ('+ @ids +');';
	EXEC(@SQL);

	IF NOT EXISTS(SELECT * FROM tblScannedData WHERE suspect_pk=@Source_Suspect AND IsNull(is_deleted,0)=0)
	BEGIN
		--Setting Assignenment to QA to allow him to re attach in chart management 
		Update E 
		SET AssignedDate=GETDATE(),AssignedUser_PK=@Usr
		FROM tblExtractionQueueAttachLog L INNER JOIN tblExtractionQueue E ON E.ExtractionQueue_PK = L.ExtractionQueue_PK
		WHERE Suspect_PK = @Source_Suspect

		--Clearing current attachments
		DELETE tblExtractionQueueAttachLog WHERE Suspect_PK = @Source_Suspect
	END

	EXEC comman_updateSuspect 3,@Source_Suspect,0
END
GO
