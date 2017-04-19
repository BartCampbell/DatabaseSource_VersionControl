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
	@NotesText varchar(MAX),
	@DOSErr TinyInt
AS
BEGIN
-----------DOS Err Starts-------------------
	IF @DOSErr=1
	BEGIN
		RETRY_DOSErr: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			SELECT T.CodedData_PK INTO #tCodedDataPK
			FROM tblCodedData T WITH (NOLOCK)
				INNER JOIN tblCodedData S WITH (NOLOCK) ON S.Suspect_PK = T.Suspect_PK AND S.DOS_From = T.DOS_From AND S.DOS_Thru = T.DOS_Thru
			WHERE S.CodedData_PK = @CodedData_PK

			Update T SET Is_Deleted=1
			FROM tblCodedData T
				INNER JOIN #tCodedDataPK S WITH (NOLOCK) ON S.CodedData_PK = T.CodedData_PK

			DELETE T 
			FROM tblCodedDataQA T
				INNER JOIN #tCodedDataPK S WITH (NOLOCK) ON S.CodedData_PK = T.CodedData_PK

			INSERT INTO tblCodedDataQA(CodedData_PK,IsConfirmed,IsRemoved,IsAdded,IsChanged,Old_ICD9,Old_Cpt,dtInsert,QA_User_PK)
			SELECT CodedData_PK,0 IsConfirmed,1 IsRemoved,0 IsAdded,0 IsChanged,'' Old_ICD9,'' Old_Cpt,GetDate() dtInsert,@QA_User_PK FROM #tCodedDataPK

			--Diagnotes:
			UPDATE NT WITH (ROWLOCK) SET BeforeQANote_Text=CASE WHEN BeforeQANote_Text IS NULL THEN Note_Text ELSE BeforeQANote_Text END,Note_Text='Incorrect DOS' 
				FROM #tCodedDataPK T INNER JOIN tblCodedDataNoteText NT ON NT.CodedData_PK = T.CodedData_PK

			INSERT INTO tblCodedDataNoteText(CodedData_PK, Note_Text, BeforeQANote_Text) 
				SELECT T.CodedData_PK,'Incorrect DOS','' FROM #tCodedDataPK T LEFT JOIN tblCodedDataNoteText NT ON NT.CodedData_PK = T.CodedData_PK WHERE NT.CodedData_PK IS NULL


			--New Codes
			Insert Into tblCodedData(Suspect_PK,DiagnosisCode,DOS_From,DOS_Thru,CPT,Provider_PK,IsICD10,Coded_User_PK,Coded_Date,Updated_Date,OpenedPage,CodedSource_PK,ScannedData_PK,Is_Deleted,BeforeQA_OpenedPage,BeforeQA_ScannedData_PK)
			SELECT Suspect_PK,DiagnosisCode,@DOS_From,@DOS_Thru,CPT,Provider_PK,IsICD10,Coded_User_PK,Coded_Date,Updated_Date,OpenedPage,CodedSource_PK,ScannedData_PK,0,NULL,NULL
				FROM tblCodedData T
					INNER JOIN #tCodedDataPK S WITH (NOLOCK) ON S.CodedData_PK = T.CodedData_PK
			/*
			INSERT INTO tblCodedDataQA(CodedData_PK,IsConfirmed,IsRemoved,IsAdded,IsChanged,Old_ICD9,Old_Cpt,dtInsert,QA_User_PK)
			SELECT T.CodedData_PK,0 IsConfirmed,0 IsRemoved,1 IsAdded,0 IsChanged,'' Old_ICD9,'' Old_Cpt,GetDate() dtInsert,@QA_User_PK
			FROM tblCodedData T WITH (NOLOCK)
			WHERE Suspect_PK=@Suspect_PK AND DOS_From = @DOS_From AND DOS_Thru = @DOS_Thru AND Is_Deleted=0
			*/
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
			BEGIN
				WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
				GOTO RETRY_DOSErr -- Go to Label RETRY
			END
		END CATCH
		RETURN; -- In case of DOS error no need to go forward
	END
-----------DOS Err Ends-------------------

		DECLARE @DiagnosisCodeOld AS VARCHAR(10) = ''
		DECLARE @CptOld AS VARCHAR(5) = ''
-----------Transaction Starts-------------------
		RETRY1: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			if (@Added=1 AND @CodedData_PK=0)
			BEGIN
				Insert Into tblCodedData(Suspect_PK,DiagnosisCode,DOS_From,DOS_Thru,CPT,Provider_PK,IsICD10,Coded_User_PK,Coded_Date,Updated_Date,OpenedPage,CodedSource_PK,ScannedData_PK,BeforeQA_OpenedPage,BeforeQA_ScannedData_PK)
				Values(@Suspect_PK,@DiagnosisCode,@DOS_From,@DOS_Thru,@CPT,@Provider_WK,0,@QA_User_PK,GetDate(),GetDate(),@OpenedPage,@Source,@OpenedPage_ID,0,0)
				
				SELECT @CodedData_PK=@@IDENTITY 		
			END
			ELSE if (@Changed=1 OR @Added=1)
			BEGIN
				IF (@Changed=1)
					SELECT @DiagnosisCodeOld = DiagnosisCode, @CptOld = CPT FROM tblCodedData WHERE CodedData_PK = @CodedData_PK
				Update tblCodedData WITH (ROWLOCK) SET CodedSource_PK=@Source, DiagnosisCode=@DiagnosisCode,CPT=@CPT,OpenedPage = CASE WHEN @OpenedPage=0 THEN OpenedPage ELSE @OpenedPage END,ScannedData_PK = CASE WHEN @OpenedPage_ID=0 THEN ScannedData_PK ELSE @OpenedPage_ID END,BeforeQA_OpenedPage=IsNull(BeforeQA_OpenedPage,OpenedPage),BeforeQA_ScannedData_PK=IsNull(BeforeQA_ScannedData_PK,ScannedData_PK) WHERE CodedData_PK = @CodedData_PK
			END
			ELSE if (@Confirm=1)
			BEGIN
				Update tblCodedData WITH (ROWLOCK) SET CodedSource_PK=@Source, OpenedPage = CASE WHEN @OpenedPage=0 THEN OpenedPage ELSE @OpenedPage END,ScannedData_PK = CASE WHEN @OpenedPage_ID=0 THEN ScannedData_PK ELSE @OpenedPage_ID END,BeforeQA_OpenedPage=IsNull(BeforeQA_OpenedPage,OpenedPage),BeforeQA_ScannedData_PK=IsNull(BeforeQA_ScannedData_PK,ScannedData_PK) WHERE CodedData_PK = @CodedData_PK
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
			SET @SQL = '
				UPDATE tblCodedDataNote WITH (ROWLOCK) SET IsRemoved=1,IsAdded=0,IsConfirmed=0 WHERE CodedData_PK='+CAST(@CodedData_PK AS VARCHAR)+' AND NoteText_PK NOT IN ('+@Notes+'); 
				UPDATE tblCodedDataNote WITH (ROWLOCK) SET IsRemoved=0,IsAdded=0,IsConfirmed=1 WHERE CodedData_PK='+CAST(@CodedData_PK AS VARCHAR)+' AND NoteText_PK IN ('+@Notes+') AND (IsAdded IS NULL OR IsAdded=0);
				INSERT INTO tblCodedDataNote(CodedData_PK, NoteText_PK, IsAdded,IsRemoved,IsConfirmed)
					SELECT '+CAST(@CodedData_PK AS VARCHAR)+' CodedData_PK,NT.NoteText_PK,1,0,0 FROM tblNoteText NT LEFT JOIN tblCodedDataNote CDN ON NT.NoteText_PK = CDN.NoteText_PK AND CDN.CodedData_PK='+CAST(@CodedData_PK AS VARCHAR)+'
					WHERE NT.NoteText_PK IN ('+@Notes+') AND CDN.NoteText_PK IS NULL'			
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
			IF EXISTS (SELECT * FROM tblCodedDataNoteText WITH (NOLOCK) WHERE CodedData_PK=@CodedData_PK)
				UPDATE tblCodedDataNoteText WITH (ROWLOCK) SET BeforeQANote_Text=CASE WHEN BeforeQANote_Text IS NULL THEN Note_Text ELSE BeforeQANote_Text END,Note_Text=@NotesText WHERE CodedData_PK=@CodedData_PK AND BeforeQANote_Text IS NULL
			ELSE IF @NotesText<>''
				INSERT INTO tblCodedDataNoteText(CodedData_PK, Note_Text, BeforeQANote_Text) VALUES(@CodedData_PK,@NotesText, '')	

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
