SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_remProviderSaveOfficeContactNote @project=0, @old_office=107, @provider=391, @note=41, @aditionaltext='Removing Provider', @User_PK=1, @contact_num=0, @followup=0;
CREATE PROCEDURE [dbo].[sch_remProviderSaveOfficeContactNote] 
	@project int,
	@old_office int,
	@provider int,
	@note int,
	@aditionaltext varchar(max),
	@User_PK int,
	@contact_num int,
	@Followup int
AS
BEGIN
	Declare @office int 

	SELECT TOP 1 @project=Project_PK FROm tblSuspect WITH (NOLOCK) WHERE Provider_PK=@provider

	--Adding new office with default note   
	INSERT INTO tblProviderOffice([Address]) Values('NewAddressCreated')
	SET @office = @@IDENTITY;

	EXEC sch_linkPrv @project,	@office, @provider, @User_PK

-----------Transaction Starts-------------------
	RETRY1: -- Transaction RETRY
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_Date,LastUpdated_User_PK,contact_num)
			SELECT @project,@office,4,'Provider removed from `'+[Address]+IsNull(' '+City+', '+[State]+' '+ZipCode,'')+'`',GETDATE(),@User_PK,0 FROM tblProviderOffice PO LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK where ProviderOffice_PK = @old_office;
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

	--Calling SP to add note to newly created office
	EXEC sch_saveOfficeContactNote @project,@office,@note,@aditionaltext,@User_PK,@contact_num,@Followup,0
END
GO
