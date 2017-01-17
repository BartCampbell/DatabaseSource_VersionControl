SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/22/2016
-- Description:	Load all Hubs from the project staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_Project_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_Project]
           ([H_Project_RK]
           ,[Project_BK]
           ,[ClientProjectID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT ProjectHashKey, CPI, Project_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblProjectStage
	WHERE
		ProjectHashKey NOT IN (SELECT H_ProJect_RK FROM H_Project)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblProjectStage
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
			AND CCI = @CCI




END





GO
