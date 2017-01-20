SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--EXEC dc_insertSuspectNotes @Suspect_PK = 7558,	@Notes_IDS='0,1,2,3',	@Notes_Text='', @Coded_User_PK=1
CREATE PROCEDURE [dbo].[dc_insertSuspectNotes] 
	@Suspect_PK BIGINT,
	@Notes_IDS VARCHAR(100),
	@Notes_Text VARCHAR(2000),
	@Coded_User_PK smallint
AS
BEGIN
-----------Transaction Starts-------------------
	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM tblSuspectNote WItH (ROWLOCK) WHERE Suspect_PK = @Suspect_PK
		DELETE FROM tblSuspectNoteText WItH (ROWLOCK) WHERE Suspect_PK = @Suspect_PK
		
		DECLARE @SQL AS VARCHAR(MAX)
		SET @SQL = 'INSERT INTO tblSuspectNote(Suspect_PK, NoteText_PK,Coded_User_PK,Coded_Date)
		SELECT '+CAST(@Suspect_PK AS VARCHAR)+' Suspect_PK,NoteText_PK,'+CAST(@Coded_User_PK AS VARCHAR)+',GetDate() FROM tblNoteText WHERE NoteText_PK IN ('+@Notes_IDS+')'
		
		EXEC (@SQL)
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

-----------Transaction Starts-------------------
	RETRY2: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@Notes_Text NOT IN ('undefined',''))
		BEGIN
			INSERT INTO tblSuspectNoteText(Suspect_PK, Note_Text,Coded_User_PK,Coded_Date) VALUES(@Suspect_PK,@Notes_Text,@Coded_User_PK,GetDate())
		END		
		
		IF (@Notes_Text NOT IN ('undefined','') OR @Notes_IDS<>'0')
		BEGIN
			UPDATE tblSuspect WItH (ROWLOCK) SET 
					IsCoded=1,
					Coded_Date= CASE WHEN Coded_User_PK IS NULL THEN GetDate() ELSE Coded_Date END,
					Coded_User_PK=CASE WHEN Coded_User_PK IS NULL THEN @Coded_User_PK ELSE Coded_User_PK END,
					LastAccessed_Date = GetDate(),
					LastUpdated = GetDate()
				WHERE SUSPECT_PK=@Suspect_PK
			
			SELECT 1 HaveData;
		END 
		ELSE IF (NOT EXISTS(SELECT * FROM tblCodedData WHERE Suspect_PK=@Suspect_PK))
		BEGIN
			UPDATE tblSuspect WItH (ROWLOCK) SET 
					IsCoded=0,
					Coded_Date= NULL,
					Coded_User_PK=NULL,
					LastAccessed_Date = GetDate(),
					LastUpdated = GetDate()
				WHERE SUSPECT_PK=@Suspect_PK
				
			SELECT 0 HaveData;
		END 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY2 -- Go to Label RETRY
		END
	END CATCH
-----------Transaction Starts-------------------		
END
GO
