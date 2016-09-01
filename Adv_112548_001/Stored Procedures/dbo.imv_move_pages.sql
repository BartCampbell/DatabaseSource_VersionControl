SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_move_pages '0,0,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22',9802,2,1
CREATE PROCEDURE [dbo].[imv_move_pages] 
	@ids varchar(MAX),
	@suspect_pk bigint,
	@act int,
	@qa_note int,
	@Source_Suspect bigint,
	@Usr int,
	@EA int
AS
BEGIN	
		DECLARE @SQL VARCHAR(MAX)

		IF (@act=1 AND @EA=0)
		BEGIN
			IF NOT EXISTS (SELECT * FROM tblScanningQANote_Suspect WHERE Suspect_PK=@Source_Suspect)
				INSERT INTO tblScanningQANote_Suspect(Suspect_PK,ScanningQANote_PK,dtQA,QA_User_PK) VALUES (@Source_Suspect,3,GetDate(),@Usr)
			ELSE
				Update tblScanningQANote_Suspect WITH (ROWLOCK) SET ScanningQANote_PK=3, dtQA=GETDATE(), QA_User_PK=@Usr WHERE Suspect_PK=@Source_Suspect
		END

		SET @SQL = 'DELETE FROM tblScanningQADetail WITH (ROWLOCK) WHERE ScannedData_PK IN ('+ @ids +'); Insert Into tblScanningQADetail(ScannedData_PK,ScanningQANoteText_PK) SELECT DISTINCT ScannedData_PK,'+CAST(@qa_note AS varchar)+' FROM tblScannedData WHERE ScannedData_PK IN ('+ @ids +')'
		EXEC(@SQL);

		SELECT S.Project_PK,S.Provider_PK,S.Suspect_PK FROM tblSuspect S WITH (NOLOCK) WHERE S.Suspect_PK=@suspect_pk

		SET @SQL = 'SELECT S.Project_PK,S.Provider_PK,S.Suspect_PK,[Filename] FROM tblSuspect S WITH (NOLOCK) INNER JOIN tblScannedData SD WITH (NOLOCK) ON S.Suspect_PK = SD.Suspect_PK WHERE ScannedData_PK IN ('+ @ids +')';
		EXEC(@SQL);

		IF @act=1
			SET @SQL = 'UPDATE tblScannedData WITH (ROWLOCK) SET is_deleted=0,suspect_pk='+ CAST(@suspect_pk AS VARCHAR) +',CodedStatus=NULL WHERE ScannedData_PK IN ('+ @ids +')';	
		ELSE
			SET @SQL = 'INSERT INTO tblScannedData(Suspect_PK,DocumentType_PK,FileName,User_PK,dtInsert,is_deleted,CodedStatus) SELECT DISTINCT '+ CAST(@suspect_pk AS VARCHAR) +' Suspect_PK,DocumentType_PK,FileName,User_PK,dtInsert,is_deleted,NULL CodedStatus FROM tblScannedData WHERE ScannedData_PK IN ('+ @ids +')';	
	
		EXEC(@SQL);

	EXEC comman_updateSuspect 3,@Source_Suspect,0
	EXEC comman_updateSuspect 2,@suspect_pk,@Usr
END
GO
