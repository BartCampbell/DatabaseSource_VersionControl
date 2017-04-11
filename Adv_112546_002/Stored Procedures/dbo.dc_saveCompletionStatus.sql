SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	dc_saveCompletionStatus @suspect=1, @usr =1, @chase_status =1, @checkImageCompletion =1, @ConfigLevels=1, @IsBlindCoding=1
CREATE PROCEDURE [dbo].[dc_saveCompletionStatus] 
	@suspect bigint,
	@usr int,
	@chase_status TinyInt,
	@checkImageCompletion bit,
	@ConfigLevels TinyInt,
	@IsBlindCoding bit
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@usr
	DECLARE @IsCompleted AS BIT = CASE WHEN @chase_status=1 THEN 1 ELSE 0 END

	IF (@checkImageCompletion=1)
	BEGIN
		IF EXISTS(SELECT * FROM tblScannedData SD WITH (NOLOCK) LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK AND SDPS.CoderLevel=@level WHERE SD.Suspect_PK=@suspect AND SDPS.ScannedData_PK IS NULL)
		BEGIN
			SELECT 1
			return;
		END
		ELSE
		BEGIN
			SELECT 0
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END

	--Updating Assignment
	IF EXISTS(SELECT * FROM tblCoderAssignment WHERE CoderLevel=@level AND Suspect_PK=@suspect)
		Update tblCoderAssignment SET User_PK=@usr,LastUpdated_User_PK=@usr,LastUpdated_Date=GetDate() WHERE CoderLevel=@level AND Suspect_PK=@suspect AND User_PK<>@usr
	ELSE
		INSERT INTO tblCoderAssignment(CoderLevel,Suspect_PK,User_PK,LastUpdated_User_PK,LastUpdated_Date) VALUES(@level,@suspect,@usr,@usr,GETDATE())

	--Chase Coded Status
	IF EXISTS(SELECT * FROM tblSuspectLevelCoded WHERE CoderLevel=@level AND Suspect_PK=@suspect)
		Update tblSuspectLevelCoded SET IsCompleted=@IsCompleted, CompletionStatus_PK = @chase_status WHERE CoderLevel=@level AND Suspect_PK=@suspect
	ELSE
		INSERT INTO tblSuspectLevelCoded(CoderLevel,Suspect_PK,User_PK,dtInserted,IsCompleted,CompletionStatus_PK) VALUES(@level,@suspect,@usr,GETDATE(),@IsCompleted,@chase_status)

	--To Update tblSuspect with Coded info
	DECLARE @UpdateSuspectTable AS BIT = 0
	IF @IsCompleted=1 AND (@ConfigLevels=1 OR @IsBlindCoding=1)	--WHEN there is only one level or Blind is enabled then simply update the tblSuspect. Because any level is completed, we count the chart as coded on main grid
		SET @UpdateSuspectTable = 1
	ELSE IF @IsCompleted=1 AND (SELECT COUNT(DISTINCT CoderLevel) FROM tblSuspectLevelCoded WITH (NOLOCK) WHERE Suspect_PK=@suspect)>=@ConfigLevels -- When its not blind then all levels needs to be coded before counting it as coded for main grid
		SET @UpdateSuspectTable = 1


		RETRY3: -- Transaction RETRY to Updating Overall Member Status
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @ChaseStatusPK AS INT = 1
			IF @UpdateSuspectTable=1
			BEGIN
				SELECT TOP 1 @ChaseStatusPK = ChaseStatus_PK FROM tblChaseStatus WHERE IsCoded=1

				UPDATE tblSuspect WITH (ROWLOCK) SET 
				MemberStatus=1,
				IsCoded=1,
				Coded_Date= CASE WHEN Coded_User_PK IS NULL THEN GetDate() ELSE Coded_Date END,
				Coded_User_PK=CASE WHEN Coded_User_PK IS NULL THEN @usr ELSE Coded_User_PK END,
				LastAccessed_Date = GetDate(),
				LastUpdated = GetDate(),
				ChaseStatus_PK = @ChaseStatusPK,
				FollowUp = NULL
				WHERE SUSPECT_PK=@suspect
			END
			ELSE
			BEGIN
				UPDATE tblSuspect WITH (ROWLOCK) SET 
				MemberStatus=0,
				IsCoded=0,
				Coded_Date = NULL,
				Coded_User_PK = NULL,
				LastAccessed_Date = GetDate(),
				LastUpdated = GetDate(),
				FollowUp = NULL
				WHERE SUSPECT_PK=@suspect
			END
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

END
GO
