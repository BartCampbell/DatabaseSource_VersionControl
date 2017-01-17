SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Load all Hubs from the AdvanceLocation staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Location_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_AdvanceLocation]
           ([H_AdvanceLocation_RK]
           ,[AdvanceLocation_BK]
           ,[ClientAdvanceLocationID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT LocationHashKey, CLI, Location_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblLocationStage
	WHERE
		LocationHashKey NOT IN (SELECT H_AdvanceLocation_RK FROM H_AdvanceLocation)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblLocationStage
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
			AND CCI = @CCI




END





GO
