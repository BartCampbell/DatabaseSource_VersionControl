SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_getOfficeContactNotes 1,1
CREATE PROCEDURE [dbo].[sch_removeOfficeContactNote] 
	@ContactNotesOffice_PK int,
	@actType int /* 1 Remove, 0 Hide, 2 Unhide */
AS
BEGIN
	DECLARE @Project INT
	DECLARE @Office INT
	DECLARE @dt smalldatetime
	IF @actType<>2
	BEGIN
		SELECT @Project=Project_PK, @Office=Office_PK, @dt=LastUpdated_Date FROM tblContactNotesOffice WHERE ContactNotesOffice_PK=@ContactNotesOffice_PK

		INSERT INTO tblContactNotesOfficeArc([Project_PK],[Office_PK],[ContactNote_PK],[ContactNoteText],[LastUpdated_User_PK],[LastUpdated_Date],[contact_num],[followup],[IsResponded],[IsViewedByScheduler],IsRemoved,IsHide)
		SELECT [Project_PK],[Office_PK],[ContactNote_PK],[ContactNoteText],[LastUpdated_User_PK],[LastUpdated_Date],[contact_num],[followup],[IsResponded],[IsViewedByScheduler],CASE WHEN @actType=1 THEN 1 ELSE 0 END,CASE WHEN @actType=0 THEN 1 ELSE 0 END FROM tblContactNotesOffice WHERE LastUpdated_Date=@dt AND Office_PK=@Office --ContactNotesOffice_PK=@ContactNotesOffice_PK
	
		DELETE FROM tblContactNotesOffice WHERE LastUpdated_Date=@dt AND Office_PK=@Office --ContactNotesOffice_PK=@ContactNotesOffice_PK
	END
	ELSE
	BEGIN
		SELECT @Project=Project_PK, @Office=Office_PK, @dt=LastUpdated_Date FROM tblContactNotesOfficeArc WHERE ContactNotesOffice_PK=@ContactNotesOffice_PK

		INSERT INTO tblContactNotesOffice([Project_PK],[Office_PK],[ContactNote_PK],[ContactNoteText],[LastUpdated_User_PK],[LastUpdated_Date],[contact_num],[followup],[IsResponded],[IsViewedByScheduler])
		SELECT [Project_PK],[Office_PK],[ContactNote_PK],[ContactNoteText],[LastUpdated_User_PK],[LastUpdated_Date],[contact_num],[followup],[IsResponded],[IsViewedByScheduler] FROM tblContactNotesOfficeArc WHERE LastUpdated_Date=@dt AND Office_PK=@Office --ContactNotesOffice_PK=@ContactNotesOffice_PK
	
		DELETE FROM tblContactNotesOfficeArc WHERE LastUpdated_Date=@dt AND Office_PK=@Office --ContactNotesOffice_PK=@ContactNotesOffice_PK
	END
--	IF NOT EXISTS(SELECT * FROM tblContactNotesOffice CNO INNER JOIN tblContactNote CN ON CN.ContactNote_PK=CNO.ContactNote_PK WHERE Project_PK=@project AND Office_PK=@office AND CN.IsIssue=1 AND IsResponded IS NULL)
--		DELETE FROM tblProviderOfficeStatus WHERE Project_PK=@project AND ProviderOffice_PK=@office
END
GO
