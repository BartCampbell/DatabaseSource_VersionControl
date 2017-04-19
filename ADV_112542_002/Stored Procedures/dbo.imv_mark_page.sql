SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_fix_order '0,78,80,81,82,83'
CREATE PROCEDURE [dbo].[imv_mark_page] 
	@ScannedDataPK bigint,
	@page_status tinyint,
	@User_PK smallint,
	@Suspect_PK bigint,
	@ConfigLevels tinyInt,
	@IsBlindCoding tinyint
AS
BEGIN
	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WITH (NOLOCK) WHERE User_PK=@User_PK
-----------Transaction Starts-------------------
	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		IF EXISTS(SELECT 1 FROM tblScannedDataPageStatus WHERE ScannedData_PK=@ScannedDataPK AND CoderLevel=@level)
			UPDATE tblScannedDataPageStatus WITH (ROWLOCK) SET PageStatus_PK=@page_status WHERE ScannedData_PK = @ScannedDataPK AND CoderLevel=@level
		ELSE
			INSERT INTO tblScannedDataPageStatus(ScannedData_PK,User_PK,CoderLevel,PageStatus_PK) VALUES(@ScannedDataPK, @User_PK, @level, @page_status)

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
/*
	--Updating Coding Status
	DECLARE @IsCompleted AS bit
	IF EXISTS(SELECT 1 FROM tblScannedData SD WITH (NOLOCK) LEFT JOIN tblScannedDataPageStatus SDPS WITH (NOLOCK) ON SD.ScannedData_PK = SDPS.ScannedData_PK AND SDPS.CoderLevel=@level
			WHERE SD.Suspect_PK=@Suspect_PK AND IsNull(SD.is_deleted,0)=0 AND SDPS.PageStatus_PK IS NULL)
		SET @IsCompleted=0
	ELSE
		SET @IsCompleted=1

	RETRY2: -- Transaction RETRY to Updating Coding Status
	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS(SELECT SUSPECT_PK FROM tblSuspectLevelCoded WITH (NOLOCK) WHERE SUSPECT_PK=@Suspect_PK AND CoderLevel=@level)
			INSERT INTO tblSuspectLevelCoded(CoderLevel,SUSPECT_PK,User_PK,dtInserted,IsCompleted) VALUES(@level, @Suspect_PK, @User_PK, GETDATE(),@IsCompleted)
		ELSE
			UPDATE tblSuspectLevelCoded WITH (ROWLOCK) SET IsCompleted=@IsCompleted WHERE SUSPECT_PK=@Suspect_PK AND CoderLevel=@level

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

	--To Update tblSuspect with Coded info
	DECLARE @UpdateSuspectTable AS BIT = 0
	IF @IsCompleted=1 AND (@ConfigLevels=1 OR @IsBlindCoding=1)	--WHEN there is only one level or Blind is enabled then simply update the tblSuspect. Because any level is completed, we count the chart as coded on main grid
		SET @UpdateSuspectTable = 1
	ELSE IF @IsCompleted=1 AND (SELECT COUNT(DISTINCT CoderLevel) FROM tblSuspectLevelCoded WITH (NOLOCK) WHERE Suspect_PK=@Suspect_PK)>=@ConfigLevels -- When its not blind then all levels needs to be coded before counting it as coded for main grid
		SET @UpdateSuspectTable = 1

	IF @UpdateSuspectTable=1
	BEGIN
		RETRY3: -- Transaction RETRY to Updating Overall Member Status
		BEGIN TRANSACTION
		BEGIN TRY
			DECLARE @ChaseStatusPK AS INT = 1
			SELECT TOP 1 @ChaseStatusPK = ChaseStatus_PK FROM tblChaseStatus WHERE IsCoded=1

			UPDATE tblSuspect WITH (ROWLOCK) SET 
			MemberStatus=1,
			IsCoded=1,
			Coded_Date= CASE WHEN Coded_User_PK IS NULL THEN GetDate() ELSE Coded_Date END,
			Coded_User_PK=CASE WHEN Coded_User_PK IS NULL THEN @User_PK ELSE Coded_User_PK END,
			LastAccessed_Date = GetDate(),
			LastUpdated = GetDate(),
			ChaseStatus_PK = @ChaseStatusPK,
			FollowUp = NULL
			WHERE SUSPECT_PK=@Suspect_PK

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
*/
END
GO
