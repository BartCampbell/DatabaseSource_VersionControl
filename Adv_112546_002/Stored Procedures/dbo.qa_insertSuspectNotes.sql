SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--EXEC dc_insertSuspectNotes @Suspect_PK = 541,@Notes_IDS='0',@Notes_Text='ABXcccdddXXX', @Coded_User_PK=1
--EXEC dc_insertSuspectNotes @Suspect_PK = 541,	@Notes_IDS='0',	@Notes_Text='ABXX', @Coded_User_PK=1
CREATE PROCEDURE [dbo].[qa_insertSuspectNotes] 
	@Suspect_PK BIGINT,
	@Notes_IDS VARCHAR(100),
	@Notes_Text VARCHAR(2000),
	@QA_Text VARCHAR(2000),
	@Coded_User_PK smallint
AS
BEGIN
-----------Transaction Starts-------------------
	SET @Notes_Text = REPLACE(@Notes_Text,'undefined','')
	SET @QA_Text = REPLACE(@QA_Text,'undefined','')
	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @SQL VARCHAR(MAX)
		SET @SQL = '
			UPDATE tblSuspectNote WITH (ROWLOCK) SET IsRemoved=1,IsAdded=0,IsConfirmed=0 WHERE Suspect_PK='+CAST(@Suspect_PK AS VARCHAR)+' AND NoteText_PK NOT IN ('+@Notes_IDS+'); 
			UPDATE tblSuspectNote WITH (ROWLOCK) SET IsRemoved=0,IsAdded=0,IsConfirmed=1 WHERE Suspect_PK='+CAST(@Suspect_PK AS VARCHAR)+' AND NoteText_PK IN ('+@Notes_IDS+') AND (IsConfirmed IS NULL OR IsConfirmed=0);
			INSERT INTO tblSuspectNote(Suspect_PK, NoteText_PK, IsAdded,IsRemoved,IsConfirmed)
				SELECT '+CAST(@Suspect_PK AS VARCHAR)+' Suspect_PK,NT.NoteText_PK,1,0,0 FROM tblNoteText NT LEFT JOIN tblSuspectNote CDN ON NT.NoteText_PK = CDN.NoteText_PK AND CDN.Suspect_PK='+CAST(@Suspect_PK AS VARCHAR)+'
				WHERE NT.NoteText_PK IN ('+@Notes_IDS+') AND CDN.NoteText_PK IS NULL'			
		EXEC (@SQL)	


		IF EXISTS (SELECT * FROM tblSuspectNoteText WITH (NOLOCK) WHERE Suspect_PK=@Suspect_PK)
			UPDATE tblSuspectNoteText WITH (ROWLOCK) SET BeforeQANote_Text=CASE WHEN BeforeQANote_Text IS NULL THEN Note_Text ELSE BeforeQANote_Text END,Note_Text=@Notes_Text,QANote_Text=@QA_Text WHERE Suspect_PK=@Suspect_PK AND BeforeQANote_Text IS NULL
		ELSE IF @Notes_Text<>'' OR @QA_Text<>''
			INSERT INTO tblSuspectNoteText(Suspect_PK, Note_Text, BeforeQANote_Text,QANote_Text,Coded_User_PK,Coded_Date) VALUES(@Suspect_PK,@Notes_Text, '',@QA_Text,@Coded_User_PK,GetDate())	

		Update tblSuspect SET QA_User_PK=@Coded_User_PK,QA_Date=GetDate(),IsQA=1 WHERE Suspect_PK=@Suspect_PK
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY1 -- Go to Label RETRY
		END
	END CATCH
-----------Transaction Starts-------------------
END
GO
