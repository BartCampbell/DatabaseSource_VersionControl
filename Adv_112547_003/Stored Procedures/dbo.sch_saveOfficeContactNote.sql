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
	@Followup int,
	@priority_supervisor int
AS
BEGIN   
	-- PROJECT/Channel SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)

	CREATE TABLE #tmpChannel (Channel_PK INT)
	CREATE INDEX idxChannelPK ON #tmpChannel (Channel_PK)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User_PK)	--For Admins
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblChannel 
	END
	ELSE
	BEGIN
		INSERT INTO #tmpProject(Project_PK) SELECT DISTINCT Project_PK FROM tblUserProject WHERE User_PK=@User_PK
		INSERT INTO #tmpChannel(Channel_PK) SELECT DISTINCT Channel_PK FROM tblUserChannel WHERE User_PK=@User_PK
	END
	-- PROJECT/Channel SELECTION


	DECLARE @FollowupDays AS INT = 0
	DECLARE @FollowDate AS Date
	DECLARE @IsCNA AS BIT = 0
	DECLARE @IsIssue AS BIT = 0
	DECLARE @IsCopyCenter AS BIT = 0
	DECLARE @IsDataIssue AS BIT = 0
	DECLARE @IsContact AS BIT = 0
	DECLARE @ContactNote_Text AS VARCHAR(150)
	DECLARE @ChaseStatusPK AS INT
	DECLARE @ProviderOfficeSubBucketPK AS TINYINT
	SELECT @ContactNote_Text=ContactNote_Text, @IsCNA=IsCNA, @FollowupDays=Followup_days, @IsIssue=IsIssue, @IsDataIssue=IsDataIssue, @IsCopyCenter=IsCopyCenter, @IsContact=IsContact, @ChaseStatusPK=ChaseStatus_PK, @ProviderOfficeSubBucketPK=ProviderOfficeSubBucket_PK FROM tblContactNote WHERE ContactNote_PK=@note

	DECLARE @IsFollowUp AS BIT = 0
	IF (@IsIssue=1 OR @IsDataIssue=1 OR @IsCNA=1)
	BEGIN
		SET @FollowDate = NULL
		SET @IsFollowUp = 1
	END
	ELSE IF (@FollowupDays>0)
	BEGIN
		SET @FollowDate = DATEADD(day,@FollowupDays,GETDATE())
		SET @IsFollowUp = 1
	END

-----------Transaction Starts-------------------
	RETRY_UpdateChase: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE S SET FollowUp = CASE WHEN @IsFollowUp=0 THEN FollowUp ELSE @FollowDate END, 
			LastContacted=CASE WHEN @IsContact=0 THEN LastContacted ELSE GetDate() END
			,IsCNA=@IsCNA
			,CNA_User_PK=CASE WHEN @IsCNA=1 THEN @User_PK ELSE NULL END
			,CNA_Date=CASE WHEN @IsCNA=1 THEN GetDate() ELSE NULL END
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (ROWLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
			INNER JOIN #tmpChannel FC ON FC.Channel_PK = S.Channel_PK
		WHERE P.ProviderOffice_PK=@office AND S.IsScanned=0 AND S.IsCNA=0

		IF (@ChaseStatusPK IS NOT NULL)
			EXEC cnm_updateChaseStatus @Channel=0 , @Projects=0 , @ProjectGroup=0 , @Status1=0 , @Status2=0 , @updateType='o' , @IDs=@office , @User=@User_PK , @ChaseStatus=@ChaseStatusPK

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY_UpdateChase -- Go to Label RETRY
		END
	END CATCH
-----------Transaction Starts-------------------


-----------Transaction Starts-------------------
	RETRY_UpdateOffice: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@FollowupDays<>0)
			UPDATE tblContactNotesOffice WITH (ROWLOCK) SET followup = @FollowDate WHERE Office_PK=@office

		IF @ContactNote_Text='Disable location from being auto-faxed' AND NOT EXISTS(SELECT * FROM tblExclude_iFax WITH (NOLOCK) WHERE ProviderOffice_PK=@office)
			INSERT INTO tblExclude_iFax(ProviderOffice_PK) VALUES(@office)

		IF @ProviderOfficeSubBucketPK<>0
			Update tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeSubBucket_PK=@ProviderOfficeSubBucketPK WHERE ProviderOffice_PK=@office

		IF (@priority_supervisor>0)
			UPDATE tblProviderOffice SET AssignedUser_PK=@priority_supervisor, AssignedDate = GETDATE(), hasPriorityNote=1 WHERE ProviderOffice_PK=@office

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY_UpdateOffice -- Go to Label RETRY
		END
	END CATCH
-----------Transaction Starts-------------------


-----------Transaction Starts-------------------
	RETRY_ContactNoteInsert: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num,followup) 
			VALUES(0,@office,@note,@aditionaltext,@User_PK,getdate(),@contact_num,@FollowDate)
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY_ContactNoteInsert -- Go to Label RETRY
		END
	END CATCH
-----------Transaction Starts-------------------
END
GO
