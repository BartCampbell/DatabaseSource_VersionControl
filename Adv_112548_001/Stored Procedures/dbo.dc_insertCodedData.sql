SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	EXEC dc_insertCodedData @Suspect_PK = 6799, @DiagnosisCode='4250', @DOS_From='03/03/2014' , @DOS_Thru='03/03/2014',	@CPT='12', @Provider_WK=575,	@IsICD10=0, @CodedSource_PK=1, @Coded_User_PK=1,	@Diag_notes='0', @Diag_notes_text='', @CodedData_PK=3,	@DelFlag='0',@OpenedPage='0';
CREATE PROCEDURE [dbo].[dc_insertCodedData] 
	@Suspect_PK BIGINT,
	@DiagnosisCode VARCHAR(10),
	@DOS_From smalldatetime,
	@DOS_Thru smalldatetime,
	@CPT Varchar(5),
	@Provider_WK BIGINT,
	@CodedSource_PK SmallInt,
	@IsICD10 Bit,
	@Coded_User_PK smallint,
	@Diag_notes varchar(200),
	@Diag_notes_text varchar(1000),
	@CodedData_PK BigInt,
	@DelFlag VARCHAR(1),
	@OpenedPage BigInt,
	@OpenedPage_ID BigInt
AS
BEGIN
-----------Transaction Starts-------------------
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@Coded_User_PK

	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @SQL AS VARCHAR(MAX)	
		IF @DelFlag='1'
		BEGIN
			PRINT 'Delete'
			DELETE FROM tblCodedDataNoteText WITH (ROWLOCK) WHERE CodedData_PK = @CodedData_PK
			DELETE FROM tblCodedDataNote WITH (ROWLOCK) WHERE CodedData_PK = @CodedData_PK
			DELETE FROM tblCodedData WITH (ROWLOCK) WHERE CodedData_PK = @CodedData_PK
		END
		ELSE IF @CodedData_PK>0
		BEGIN
			PRINT 'Update'
			Update tblCodedData WITH (ROWLOCK) SET 
				Suspect_PK=@Suspect_PK,
				DiagnosisCode=@DiagnosisCode,
				DOS_From=@DOS_From,
				DOS_Thru=@DOS_Thru,
				CPT=@CPT,
				Provider_PK=@Provider_WK,
				CodedSource_PK=@CodedSource_PK,
				IsICD10=@IsICD10,
				Coded_User_PK=@Coded_User_PK,Updated_Date=GetDate(),
				OpenedPage = CASE WHEN @OpenedPage=0 THEN OpenedPage ELSE @OpenedPage END,
				ScannedData_PK = CASE WHEN @OpenedPage=0 THEN ScannedData_PK ELSE @OpenedPage_ID END,
				CoderLevel = @level
			WHERE CodedData_PK = @CodedData_PK

			SET @SQL = 'DELETE FROM tblCodedDataNote WITH (ROWLOCK) WHERE CodedData_PK='+CAST(@CodedData_PK AS VARCHAR)+'; 
			INSERT INTO tblCodedDataNote(CodedData_PK, NoteText_PK)
			SELECT '+CAST(@CodedData_PK AS VARCHAR)+' CodedData_PK,NoteText_PK FROM tblNoteText WHERE NoteText_PK IN ('+@Diag_notes+');'
			
			EXEC (@SQL)		
			
			DELETE FROM tblCodedDataNoteText WITH (ROWLOCK) WHERE CodedData_PK=@CodedData_PK
			IF (@Diag_notes_text NOT IN ('undefined',''))
			BEGIN
				INSERT INTO tblCodedDataNoteText(CodedData_PK, Note_Text) VALUES(@CodedData_PK,@Diag_notes_text)
			END					
		END		
		ELSE IF NOT EXISTS(SELECT * FROM tblCodedData WHERE Suspect_PK=@Suspect_PK AND DiagnosisCode=@DiagnosisCode AND DOS_Thru=@DOS_Thru AND Coded_User_PK=@Coded_User_PK) 
		BEGIN
			IF @CodedData_PK=0
			BEGIN
				PRINT 'INsert'
				Insert Into tblCodedData(Suspect_PK,DiagnosisCode,DOS_From,DOS_Thru,CPT,Provider_PK,CodedSource_PK,IsICD10,Coded_User_PK,Coded_Date,Updated_Date,OpenedPage,ScannedData_PK,CoderLevel)
				Values(@Suspect_PK,@DiagnosisCode,@DOS_From,@DOS_Thru,@CPT,@Provider_WK,@CodedSource_PK,@IsICD10,@Coded_User_PK,GetDate(),GetDate(),@OpenedPage,@OpenedPage_ID,@level)
				
				SELECT @CodedData_PK=@@IDENTITY 
				
				SET @SQL = 'INSERT INTO tblCodedDataNote(CodedData_PK, NoteText_PK)
				SELECT '+CAST(@CodedData_PK AS VARCHAR)+' CodedData_PK,NoteText_PK FROM tblNoteText WHERE NoteText_PK IN ('+@Diag_notes+')'
				
				EXEC (@SQL)
				
				IF (@Diag_notes_text NOT IN ('undefined',''))
				BEGIN
					INSERT INTO tblCodedDataNoteText(CodedData_PK, Note_Text) VALUES(@CodedData_PK,@Diag_notes_text)
				END		
			END	
		END

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
-----------Transaction Starts------------------

	RETRY2: -- Transaction RETRY to Updating Coding Status
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS(SELECT SUSPECT_PK FROM tblSuspectLevelCoded WITH (NOLOCK) WHERE SUSPECT_PK=@Suspect_PK AND CoderLevel=@level)
			INSERT INTO tblSuspectLevelCoded(CoderLevel,SUSPECT_PK,User_PK,dtInserted,IsCompleted) VALUES(@level, @Suspect_PK, @Coded_User_PK, GETDATE(),0)

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
END
GO
