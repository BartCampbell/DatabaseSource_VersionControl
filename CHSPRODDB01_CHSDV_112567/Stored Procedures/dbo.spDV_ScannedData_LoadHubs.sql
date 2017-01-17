SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblScannedDataStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScannedData_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_ScannedData

INSERT INTO [dbo].[H_ScannedData]
           ([H_ScannedData_RK]
           ,[ScannedData_BK]
           ,[ClientScannedDataID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT ScannedDataHashKey, CSI, ScannedData_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblScannedDataStage  WITH(NOLOCK)
	WHERE
		ScannedDataHashKey NOT IN (SELECT H_ScannedData_RK FROM H_ScannedData)
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
		CHSStaging.adv.tblScannedDataStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI


END


GO
