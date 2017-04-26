SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	EXEC comman_updateSuspect 3,1,1
CREATE PROCEDURE [dbo].[comman_updateSuspect] 
	@Action TinyInt,
	@Suspect_PK BIGINT,
	@User SmallINT
AS
BEGIN
	DECLARE @ChaseStatusPK AS INT = 1
-----------Transaction Starts-------------------
	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		IF (@Action=1) --QA
		BEGIN
			UPDATE tblSuspect WITH (ROWLOCK) SET IsQA=1,QA_User_PK=@User,QA_Date=GetDate() WHERE Suspect_PK=@Suspect_PK;
		END
		ELSE IF (@Action=2) --Copy Pages or Moved To
		BEGIN
			SELECT TOP 1 @ChaseStatusPK = ChaseStatus_PK FROM tblChaseStatus WHERE IsExtracted=1

			UPDATE tblSuspect WITH (ROWLOCK) SET IsScanned=1, ChaseStatus_PK = CASE WHEN IsCoded=0 AND IsScanned=0 THEN @ChaseStatusPK ELSE ChaseStatus_PK END
				,Scanned_User_PK=CASE WHEN Scanned_User_PK IS NULL THEN @User ELSE Scanned_User_PK END
				,Scanned_Date=CASE WHEN Scanned_Date IS NULL THEN GetDate() ELSE Scanned_Date END  
				,IsCNA=0,CNA_User_PK=NULL,CNA_Date=NULL
			WHERE Suspect_PK=@Suspect_PK AND Scanned_User_PK IS NULL;
		END
		ELSE IF (@Action=3) --Removed Pages or Moved From
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblScannedData WITH (NOLOCK) WHERE IsNull(is_deleted,0)=0 AND DocumentType_PK<>99 AND Suspect_PK=@Suspect_PK)
			BEGIN
				SELECT TOP 1 @ChaseStatusPK = ChaseStatus_PK FROM tblChaseStatus WHERE ProviderOfficeBucket_PK=3
				Update tblSuspect WITH (ROWLOCK) SET ChartRec_Date=NULL,Scanned_Date=NULL,Scanned_User_PK=NULL,IsScanned=0,ChaseStatus_PK=@ChaseStatusPK WHERE Suspect_PK=@Suspect_PK
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
-----------Transaction Starts-------------------
END
GO
