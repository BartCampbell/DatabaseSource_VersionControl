SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sch_saveFaxIt] 
	@project int,
	@office int,
	@User_PK int
AS
BEGIN
    
		DECLARE @ContactPerson AS VARCHAR(100)
		DECLARE @FaxNumber AS VARCHAR(100)
		
		SELECT @ContactPerson=ContactPerson,@FaxNumber=FaxNumber FROM tblProviderOffice WITH (NOLOCK) WHERE ProviderOffice_Pk=@office

-----------Transaction Starts-------------------
		RETRY1: -- Transaction RETRY
		BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
			SELECT Project_PK,ProviderOffice_PK,6,'To '+@FaxNumber,@User_PK,GETDATE(),0 FROM cacheProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK=@office
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
			UPDATE cacheProviderOffice WITH (ROWLOCK) SET contact_num = 1 WHERE ProviderOffice_PK=@office AND contact_num<1
			UPDATE tblProviderOffice WITH (RowLock) SET ProviderOfficeBucket_PK=1 WHERE ProviderOffice_PK=@office AND ProviderOfficeBucket_PK=1
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

		SELECT @ContactPerson ContactPerson, @FaxNumber FaxNumber
END
GO
