SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/19/2016
-- Description:	Load all Hubs from the Suspect staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Suspect_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_Suspect]
           ([H_Suspect_RK]
           ,[Suspect_BK]
           ,[ClientSuspectID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT SuspectHashKey, CSI, Suspect_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblSuspectWCStage
	WHERE
		SuspectHashKey NOT IN (SELECT H_Suspect_RK FROM H_Suspect)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblSuspectWCStage
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
			AND CCI = @CCI




END




GO
