SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblDocumentStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Document_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_DocumentType

INSERT INTO [dbo].[H_DocumentType]
           ([H_DocumentType_RK]
           ,[DocumentType_BK]
           ,[ClientDocumentTypeID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT DocumentTypeHashKey, CDI, DocumentType_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblDocumentTypeStage  WITH(NOLOCK)
	WHERE
		DocumentTypeHashKey NOT IN (SELECT H_DocumentType_RK FROM H_DocumentType)
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
		CHSStaging.adv.tblDocumentTypeStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI


END
GO
