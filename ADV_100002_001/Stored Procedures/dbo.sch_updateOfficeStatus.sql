SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sch_updateOfficeStatus 1
CREATE PROCEDURE [dbo].[sch_updateOfficeStatus] 
	@office bigint,
	@bucket tinyint,
	@type tinyint,
	@User_PK smallint
AS
BEGIN
/*
	IF (@type=1)
	BEGIN
		UPDATE tblProviderOffice WITH (ROWLOCK) SET ProviderOfficeBucket_PK = @bucket WHERE ProviderOffice_PK = @office

		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
		SELECT 0 Project_PK,@office ProviderOffice_PK,ContactNote_PK,'To '+POB.Bucket,@User_PK,GETDATE(),0 FROM tblProviderOfficeBucket POB ,tblContactNote CN, cacheProviderOffice cPO WHERE POB.ProviderOfficeBucket_PK=@bucket AND CN.sortOrder=980 AND cPO.ProviderOffice_PK=@office
	END
	ELSE
	BEGIN
	*/
		UPDATE tblProviderOffice WITH (ROWLOCK) SET AssignedUser_PK = NULL,AssignedDate=GETDATE(),hasPriorityNote=0 WHERE ProviderOffice_PK = @office

		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num) 
		SELECT 0 Project_PK,@office ProviderOffice_PK,ContactNote_PK,'',@User_PK,GETDATE(),0 FROM tblContactNote CN WHERE CN.sortOrder=981
--	END
END
GO
