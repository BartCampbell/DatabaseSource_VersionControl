SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	EXEC qa_insertQAData @Suspect_PK = 6799, @Provider_WK=1, @DOS_From='03/03/2014' , @DOS_Thru='03/03/2014',	@QA_User_PK=1, @CodedData_PK=1,	@DiagnosisCode='4250', @CPT='', @CodedSource_PK=1, @Confirm =0,	@Removed =0,	@Changed =0,	@Added =0, @OpenedPage=0,@Source=0,@Notes='';
CREATE PROCEDURE [dbo].[qa_insertQAData] 
	@Suspect_PK BIGINT,
	@Provider_WK BIGINT,
	@DOS_From smalldatetime,
	@DOS_Thru smalldatetime,
	@QA_User_PK smallint,
	@CodedData_PK BigInt,
	@DiagnosisCode VARCHAR(10),
	@CPT Varchar(5),
	@CodedSource_PK SmallInt,
	@Confirm Bit,
	@Removed Bit,
	@Changed Bit,
	@Added Bit,
	@OpenedPage BigInt,
	@OpenedPage_ID BigInt,
	@Source INT,
	@Notes varchar(500),
	@NotesText varchar(MAX)
AS
BEGIN
		DECLARE @DiagnosisCodeOld AS VARCHAR(10) = ''
		DECLARE @CptOld AS VARCHAR(5) = ''
-----------Transaction Starts-------------------
		RETRY1: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			if (@Added=1)
			BEGIN
				Insert Into tblCodedData(Suspect_PK,DiagnosisCode,DOS_From,DOS_Thru,CPT,Provider_PK,IsICD10,Coded_User_PK,Coded_Date,Updated_Date,OpenedPage,CodedSource_PK,ScannedData_PK)
				Values(@Suspect_PK,@DiagnosisCode,@DOS_From,@DOS_Thru,@CPT,@Provider_WK,0,@QA_User_PK,GetDate(),GetDate(),@OpenedPage,@Source,@OpenedPage_ID)
				
				SELECT @CodedData_PK=@@IDENTITY 		
			END
			ELSE if (@Changed=1)
			BEGIN
				SELECT @DiagnosisCodeOld = DiagnosisCode, @CptOld = CPT FROM tblCodedData WHERE CodedData_PK = @CodedData_PK
				Update tblCodedData WITH (ROWLOCK) SET CodedSource_PK=@Source, DiagnosisCode=@DiagnosisCode,CPT=@CPT,OpenedPage = CASE WHEN @OpenedPage=0 THEN OpenedPage ELSE @OpenedPage END,ScannedData_PK = CASE WHEN @OpenedPage_ID=0 THEN ScannedData_PK ELSE @OpenedPage_ID END WHERE CodedData_PK = @CodedData_PK
			END
			ELSE if (@Confirm=1)
			BEGIN
				Update tblCodedData WITH (ROWLOCK) SET CodedSource_PK=@Source, OpenedPage = CASE WHEN @OpenedPage=0 THEN OpenedPage ELSE @OpenedPage END,ScannedData_PK = CASE WHEN @OpenedPage_ID=0 THEN ScannedData_PK ELSE @OpenedPage_ID END WHERE CodedData_PK = @CodedData_PK
			END
			ELSE if (@Removed=1)
			BEGIN
				Update tblCodedData WITH (ROWLOCK) SET Is_Deleted=1 WHERE CodedData_PK = @CodedData_PK
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
-----------Transaction Starts-------------------

-----------Transaction Starts-------------------
		RETRY2: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @SQL VARCHAR(MAX)
			SET @SQL = 'DELETE FROM tblCodedDataNote WITH (ROWLOCK) WHERE CodedData_PK='+CAST(@CodedData_PK AS VARCHAR)+'; 
			INSERT INTO tblCodedDataNote(CodedData_PK, NoteText_PK)
			SELECT '+CAST(@CodedData_PK AS VARCHAR)+' CodedData_PK,NoteText_PK FROM tblNoteText WHERE NoteText_PK IN ('+@Notes+');'			
			EXEC (@SQL)	
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

-----------Transaction Starts-------------------
		RETRY3: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM tblCodedDataNoteText WITH (ROWLOCK) WHERE CodedData_PK=@CodedData_PK
			IF @NotesText<>'' 
				INSERT INTO tblCodedDataNoteText(CodedData_PK, Note_Text) VALUES(@CodedData_PK,@NotesText)	

			DELETE tblCodedDataQA WHERE CodedData_PK = @CodedData_PK

			INSERT INTO tblCodedDataQA(CodedData_PK,IsConfirmed,IsRemoved,IsAdded,IsChanged,Old_ICD9,Old_Cpt,dtInsert,QA_User_PK)
			VALUES(@CodedData_PK,@Confirm,@Removed,@Added,@Changed,@DiagnosisCodeOld,@CptOld,GetDate(),@QA_User_PK)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
			BEGIN
				WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
				GOTO RETRY3 -- Go to Label RETRY
			END
		END CATCH
-----------Transaction Starts-------------------
END
GO
