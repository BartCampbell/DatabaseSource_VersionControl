SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	dc_saveCompletionStatus @suspect=541, @usr =1, @chase_status =4, @checkImageCompletion =4, @ConfigLevels=1, @IsBlindCoding=1
CREATE PROCEDURE [dbo].[dc_saveCompletionStatus] 
	@suspect bigint,
	@usr int,
	@chase_status TinyInt,
	@checkImageCompletion tinyint,
	@ConfigLevels TinyInt,
	@IsBlindCoding bit
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@usr
	DECLARE @IsCompleted AS BIT = CASE WHEN @chase_status=1 THEN 1 ELSE 0 END

	IF (@checkImageCompletion=1 AND @IsCompleted=1)
	BEGIN
		IF EXISTS(SELECT * FROM tblScannedData SD WITH (NOLOCK) LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK AND SDPS.CoderLevel=@level WHERE SD.Suspect_PK=@suspect AND SDPS.ScannedData_PK IS NULL AND (SD.is_deleted IS NULL OR SD.is_deleted=0))
			AND NOT EXISTS(SELECT * FROM tblSuspectNote WHERE Suspect_PK=@suspect)
			AND NOT EXISTS(SELECT * FROM tblSuspectNoteText WHERE Suspect_PK=@suspect)
		BEGIN
			SELECT 1
			return;
		END
		ELSE
		BEGIN
			SELECT 0
		END
	END
	ELSE IF (@checkImageCompletion=4) --Image Issue
	BEGIN
		IF EXISTS(SELECT 1 FROM tblScannedData SD WITH (NOLOCK) INNER JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK AND SDPS.CoderLevel=@level WHERE SD.Suspect_PK=@suspect AND IsNull(is_deleted,0)=0 AND PageStatus_PK=3)
		BEGIN
			SELECT 4
		END
		ELSE
		BEGIN
			SELECT 0
			return;
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
		Update SLC SET IsCompleted=@IsCompleted, CompletionStatus_PK = @chase_status,User_PK=@usr,dtInserted=GETDATE(),ReceivedAdditionalPages=CASE WHEN @IsCompleted=1 THEN 0 ELSE ReceivedAdditionalPages END FROM tblSuspectLevelCoded SLC INNER JOIN tblSuspect S ON S.Suspect_PK=SLC.Suspect_PK WHERE CoderLevel=@level AND (S.Suspect_PK=@suspect OR S.LinkedSuspect_PK=@suspect)
	ELSE
		INSERT INTO tblSuspectLevelCoded(CoderLevel,Suspect_PK,User_PK,dtInserted,IsCompleted,CompletionStatus_PK,ReceivedAdditionalPages) 
			SELECT @level,Suspect_PK,@usr,GETDATE(),@IsCompleted,@chase_status,0 FROM tblSuspect WHERE Suspect_PK=@suspect OR LinkedSuspect_PK=@suspect

	--To Update remaining pages as ignored
	IF (@IsCompleted=1)
		INSERT INTO tblScannedDataPageStatus(ScannedData_PK,User_PK,CoderLevel,PageStatus_PK)
		SELECT SD.ScannedData_PK,@usr,@level,4 Ignored FROM tblScannedData SD WITH (NOLOCK) LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK AND SDPS.CoderLevel=@level WHERE SD.Suspect_PK=@suspect AND SDPS.ScannedData_PK IS NULL

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
				Coded_Date= GetDate(),
				Coded_User_PK= @usr,
				LastAccessed_Date = GetDate(),
				LastUpdated = GetDate(),
				ChaseStatus_PK = @ChaseStatusPK,
				FollowUp = NULL
				WHERE SUSPECT_PK=@suspect OR LinkedSuspect_PK=@suspect
			END
			ELSE
			BEGIN
				DECLARE @ChaseStatusExtracted AS INT = 1
				DECLARE @ChaseStatusCNA AS INT = 1
				DECLARE @ChaseStatusScheduled AS INT = 1
				SELECT TOP 1 @ChaseStatusExtracted = ChaseStatus_PK FROM tblChaseStatus WHERE IsExtracted=1
				SELECT TOP 1 @ChaseStatusCNA = ChaseStatus_PK FROM tblChaseStatus WHERE IsCNA=1 AND VendorCodeType='CHS'
				SELECT TOP 1 @ChaseStatusScheduled = ChaseStatus_PK FROM tblChaseStatus WHERE IsScheduled=1

				UPDATE tblSuspect WITH (ROWLOCK) SET 
				MemberStatus=0,
				IsCoded=0,
				Coded_Date = NULL,
				Coded_User_PK = NULL,
				LastAccessed_Date = GetDate(),
				LastUpdated = GetDate(),
				FollowUp = NULL,
				ChaseStatus_PK = CASE WHEN IsScanned=1 THEN @ChaseStatusExtracted WHEN IsCNA=1 THEN @ChaseStatusCNA ELSE @ChaseStatusScheduled END
				WHERE SUSPECT_PK=@suspect OR LinkedSuspect_PK=@suspect
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
