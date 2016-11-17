SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/24/2016
-- Description:	Load all Hubs from the Advantage tblNoteTextStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Notes_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_NoteText

INSERT INTO [dbo].[H_NoteText]
           ([H_NoteText_RK]
           ,[NoteText_BK]
           ,[ClientNoteTextID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT NoteTextHashKey, CNI, NoteText_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblNoteTextStage  with(nolock)
	WHERE
		NoteTextHashKey not in (Select H_NoteText_RK from H_NoteText)
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
		CHSStaging.adv.tblNoteTextStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI


	--** LOAD H_NoteType

INSERT INTO [dbo].[H_NoteType]
           ([H_NoteType_RK]
           ,[NoteType_BK]
           ,[ClientNoteTypeID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT NoteTypeHashKey, CTI, NoteType_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblNoteTypeStage  WITH(NOLOCK)
	WHERE
		NoteTypeHashKey NOT IN (SELECT H_NoteType_RK FROM H_NoteType)
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
		CHSStaging.adv.tblNoteTypeStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI


END
GO
