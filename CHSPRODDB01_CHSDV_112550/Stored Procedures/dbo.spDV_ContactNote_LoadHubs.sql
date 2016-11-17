SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblContactNoteStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ContactNote_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_ContactNote

INSERT INTO [dbo].[H_ContactNote]
           ([H_ContactNote_RK]
           ,[ContactNote_BK]
           ,[ClientContactNoteID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT ContactNoteHashKey, CNI, ContactNote_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblContactNoteStage  with(nolock)
	WHERE
		ContactNoteHashKey not in (Select H_ContactNote_RK from H_ContactNote)
		AND CCI= @CCI
		

--** LOAD H_CLIENT
INSERT INTO [dbo].[H_Client]
           ([H_Client_RK]
           ,[Client_BK]
           ,[ClientName]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource, LoadDate 
	FROM 
		CHSStaging.adv.tblContactNoteStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI

	--** LOAD H_ContactNotesOffice

INSERT INTO [dbo].[H_ContactNotesOffice]
           ([H_ContactNotesOffice_RK]
           ,[ContactNotesOffice_BK]
           ,[ClientContactNotesOfficeID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT ContactNotesOfficeHashKey, CNI, ContactNotesOffice_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblContactNotesOfficeStage  WITH(NOLOCK)
	WHERE
		ContactNotesOfficeHashKey NOT IN (SELECT H_ContactNotesOffice_RK FROM H_ContactNotesOffice)
		AND CCI= @CCI



		--** LOAD H_CLIENT
INSERT INTO [dbo].[H_Client]
           ([H_Client_RK]
           ,[Client_BK]
           ,[ClientName]
           ,[RecordSource]
           ,[LoadDate])
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource, LoadDate 
	FROM 
		CHSStaging.adv.tblContactNotesOfficeStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI


END

GO
