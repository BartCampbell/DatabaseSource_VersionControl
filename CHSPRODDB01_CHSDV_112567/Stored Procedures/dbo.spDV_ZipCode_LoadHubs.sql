SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/31/2016
-- Description:	Load all Hubs from the ZipCode staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ZipCode_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_PROVIDER
INSERT INTO [dbo].[H_ZipCode]
           ([H_ZipCode_RK]
           ,[ZipCode_BK]
           ,[ClientZipCodeID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT ZipCodeHashKey, CZI, ZipCode_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblZipCodeStage
	WHERE
		ZipCodeHashKey NOT IN (SELECT H_ZipCode_RK FROM H_ZipCode)
		AND CCI = @CCI





END





GO
