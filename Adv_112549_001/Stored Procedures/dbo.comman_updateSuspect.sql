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
	DECLARE @Update_Office AS TinyInt = 0
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
			UPDATE tblSuspect WITH (ROWLOCK) SET IsScanned=1
				,Scanned_User_PK=CASE WHEN Scanned_User_PK IS NULL THEN @User ELSE Scanned_User_PK END
				,Scanned_Date=CASE WHEN Scanned_Date IS NULL THEN GetDate() ELSE Scanned_Date END  
				,IsCNA=0,CNA_User_PK=NULL,CNA_Date=NULL
			WHERE Suspect_PK=@Suspect_PK AND Scanned_User_PK IS NULL;

			SET @Update_Office = 1
		END
		ELSE IF (@Action=3) --Removed Pages or Moved From
		BEGIN
			--UPDATE tblSuspect SET IsQA=1,QA_User_PK=@User,QA_Date=GetDate() WHERE Suspect_PK=@Suspect_PK;
			IF NOT EXISTS(SELECT * FROM tblScannedData WITH (NOLOCK) WHERE IsNull(is_deleted,0)=0 AND DocumentType_PK<>99 AND Suspect_PK=@Suspect_PK)
			BEGIN
				Update tblSuspect WITH (ROWLOCK) SET ChartRec_Date=NULL,Scanned_Date=NULL,Scanned_User_PK=NULL,IsScanned=0 WHERE Suspect_PK=@Suspect_PK
				SET @Update_Office = 1
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

	IF (@Update_Office=1)
	BEGIN
		DECLARE @extracted_charts AS INT
		DECLARE @cna_charts AS INT
		DECLARE @total_charts AS INT
		DECLARE @project AS INT
		DECLARE @office AS INT
		SELECT Top 1 @project=S.Project_PK,@office=P.ProviderOffice_PK FROM tblSuspect S WITH (NOLOCK)	
					INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
				WHERE Suspect_PK = @Suspect_PK

		SELECT 
			@extracted_charts = COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NOT NULL THEN S.Suspect_PK ELSE NULL END),
			@cna_charts = COUNT(DISTINCT CASE WHEN Scanned_User_PK IS NULL AND CNA_User_PK IS NOT NULL THEN S.Suspect_PK ELSE NULL END),
			@total_charts = COUNT(DISTINCT S.Suspect_PK)
		FROM tblSuspect S WITH (NOLOCK)	
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
		WHERE S.Project_PK=@project AND P.ProviderOffice_PK=@office AND S.IsScanned=1

-----------Transaction Starts-------------------
		RETRY2: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			UPDATE cPO SET extracted_count=@extracted_charts, cna_count = @cna_charts, charts = @total_charts
			FROM cacheProviderOffice cPO WITH (ROWLOCK)
			WHERE Project_PK=@project AND ProviderOffice_PK=@office
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

		IF @extracted_charts>0
		BEGIN
			Update tblProviderOffice WITH (RowLOCK) SET ProviderOfficeBucket_PK=6 WHERE ProviderOffice_PK=@office
		END
	END
END
GO
