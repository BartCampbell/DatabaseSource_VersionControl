SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_saveOfficeContactNote 0, 107, 16, '', 1, 2, -1
CREATE PROCEDURE [dbo].[sch_saveOfficeContactNote] 
	@project int,
	@office int,
	@note int,
	@aditionaltext varchar(max),
	@User_PK int,
	@contact_num int,
	@Followup int
AS
BEGIN   
			DECLARE @IsCNA AS BIT = 0
			DECLARE @IsFollowup AS BIT = 0
			DECLARE @FollowDate AS Date
			DECLARE @IsIssue AS BIT = 0
			DECLARE @IsCopyCenter AS BIT = 0
			DECLARE @IsDataIssue AS BIT = 0
			SELECT @IsCNA = IsCNA, @IsFollowup = IsFollowup, @IsIssue = IsIssue, @IsDataIssue = IsDataIssue, @IsCopyCenter= IsCopyCenter FROM tblContactNote WHERE ContactNote_PK=@note
			IF (@Followup<>0)
			BEGIN
				IF (@Followup=-1)
					SET @FollowDate = NULL
				ELSE
					SET @FollowDate = DATEADD(day,@Followup,GETDATE())
-----------Transaction Starts-------------------
			RETRY1: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				UPDATE cacheProviderOffice WITH (ROWLOCK) SET follow_up = @FollowDate WHERE ProviderOffice_PK=@office --Project_PK=@project AND 
				UPDATE tblContactNotesOffice WITH (ROWLOCK) SET followup = @FollowDate WHERE Office_PK=@office --Project_PK=@project AND 
				Update tblProviderOfficeStatus WITH (ROWLOCK) SET OfficeIssueStatus=5 WHERE ProviderOffice_PK=@office AND OfficeIssueStatus=2
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

			IF (@IsIssue=1 OR @IsDataIssue=1 OR @IsCopyCenter=1)
			BEGIN
-----------Transaction Starts-------------------
				RETRY2: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					UPDATE cacheProviderOffice WITH (ROWLOCK) SET follow_up = null WHERE ProviderOffice_PK=@office --Project_PK=@project AND 
					UPDATE tblContactNotesOffice WITH (ROWLOCK) SET followup = null WHERE Office_PK=@office --Project_PK=@project AND 
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
				RETRY_IssStatus: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					IF EXISTS(SELECT * FROM tblProviderOfficeStatus WITH (NOLOCK) WHERE ProviderOffice_PK=@office)
						Update tblProviderOfficeStatus WITH (ROWLOCK) SET OfficeIssueStatus=CASE WHEN @IsDataIssue=1 THEN 6 ELSE 1 END WHERE ProviderOffice_PK=@office
					ELSE
						INSERT INTO tblProviderOfficeStatus(Project_PK,ProviderOffice_PK,OfficeIssueStatus) VALUES(0,@office,CASE WHEN @IsDataIssue=1 THEN 6 ELSE 1 END)
					COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
					IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
					BEGIN
						WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
						GOTO RETRY_IssStatus -- Go to Label RETRY
					END
				END CATCH
-----------Transaction Starts-------------------

-----------Transaction Starts-------------------
				RETRY3: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					--IF EXISTS(SELECT * FROM tblProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK=@office AND ProviderOfficeBucket_PK<>CASE WHEN @IsDataIssue=1 THEN 7 WHEN @IsCopyCenter=1 THEN 10 ELSE 8 END)
						Update tblProviderOffice WITH (ROWLOCK) SET Pool_PK=NULL,ProviderOfficeBucket_PK=CASE WHEN @IsIssue=1 THEN 7 WHEN @IsCopyCenter=1 THEN 10 ELSE 8 END 
							WHERE ProviderOffice_PK=@office
							SELECT * FROM tblProviderOfficeBucket
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
			ELSE IF (@IsCNA=1)
			BEGIN
-----------Transaction Starts-------------------
				RETRY5: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					Update S
					SET IsCNA=1,CNA_User_PK=@User_PK,CNA_Date=GetDate()
					FROM tblSuspect S WITH (ROWLOCK)
					INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
					WHERE P.ProviderOffice_PK=@office --AND S.Project_PK=@project
					AND Scanned_User_PK IS NULL AND Coded_User_PK IS NULL AND CNA_User_PK IS NULL
					COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
					IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
					BEGIN
						WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
						GOTO RETRY5 -- Go to Label RETRY
					END
				END CATCH
-----------Transaction Starts-------------------
	
-----------Transaction Starts-------------------
				RETRY6: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					UPDATE cacheProviderOffice WITH (ROWLOCK) SET follow_up = null WHERE ProviderOffice_PK=@office --Project_PK=@project AND 
					UPDATE tblContactNotesOffice WITH (ROWLOCK) SET followup = null WHERE Office_PK=@office --Project_PK=@project AND 
					Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK=0 WHERE ProviderOffice_PK=@office --Project_PK=@project AND 
					COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
					IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
					BEGIN
						WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
						GOTO RETRY6 -- Go to Label RETRY
					END
				END CATCH
-----------Transaction Starts-------------------
			END
			--Update Cache
			IF (@contact_num>0)			    
			BEGIN
-----------Transaction Starts-------------------
				RETRY7: -- Transaction RETRY
				BEGIN TRANSACTION
				BEGIN TRY
					IF EXISTS(SELECT * FROM tblProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK=@office AND ProviderOfficeBucket_PK=1) 
						Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK=2 WHERE ProviderOffice_PK=@office

					UPDATE cacheProviderOffice WITH (ROWLOCK) SET contact_num = CASE WHEN contact_num>@contact_num THEN contact_num ELSE @contact_num END,dtLastContact=GETDATE()
					WHERE ProviderOffice_PK=@office

					COMMIT TRANSACTION
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
					IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
					BEGIN
						WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
						GOTO RETRY7 -- Go to Label RETRY
					END
				END CATCH
-----------Transaction Starts-------------------
			END


-----------Transaction Starts-------------------
			RETRY4: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,followup) 
				SELECT Project_PK,@office,@note,@aditionaltext,@User_PK,getdate(),@contact_num,@FollowDate FROM cacheProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK=@office
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY4 -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------
			
			If EXISTS(SELECT * FROM tblContactNote WITH (NOLOCK) WHERE ContactNote_PK=@note AND ContactNote_Text='Disable location from being auto-faxed')
			BEGIN
				If NOT EXISTS(SELECT * FROM tblExclude_iFax WITH (NOLOCK) WHERE ProviderOffice_PK=@office)
					INSERT INTO tblExclude_iFax(ProviderOffice_PK) VALUES(@office)
			END
END
GO
