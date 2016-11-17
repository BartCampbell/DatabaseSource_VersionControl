SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblClaimDataStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ClaimData_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_ClaimData

INSERT INTO [dbo].[H_ClaimData]
           ([H_ClaimData_RK]
           ,[ClaimData_BK]
           ,[ClientClaimDataID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT ClaimDataHashKey, CDI, ClaimData_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblClaimDataStage  with(nolock)
	WHERE
		ClaimDataHashKey not in (Select H_ClaimData_RK from H_ClaimData)
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
		CHSStaging.adv.tblClaimDataStage with(nolock)
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
	AND CCI= @CCI


End
GO
