SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[ifax_saveFaxIt] 
	@project int,
	@office int,
	@User_PK int
AS
BEGIN
	    
		DECLARE @ContactPerson AS VARCHAR(100)
		DECLARE @FaxNumber AS VARCHAR(100)
		
		SELECT @ContactPerson=ContactPerson,@FaxNumber=FaxNumber FROM tblProviderOffice WHERE ProviderOffice_Pk=@office

		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
		SELECT Project_PK,ProviderOffice_PK,6,'iFax to '+@FaxNumber,@User_PK,GETDATE(),0 FROM cacheProviderOffice WITH (NOLOCK) WHERE ProviderOffice_PK=@office AND office_status<=4
		/*
		UPDATE cacheProviderOffice SET --contacted=1,
			office_status=CASE WHEN office_status>4 THEN 4 ELSE office_status END
			--, contact_num = CASE WHEN contact_num>1 THEN contact_num ELSE 1 END
        WHERE ProviderOffice_PK=@office AND office_status<=4
		*/
		SELECT @ContactPerson ContactPerson, @FaxNumber FaxNumber


END
GO
