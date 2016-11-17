SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblCodedDataStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_CodedData_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_CodedData

INSERT INTO [dbo].[H_CodedData]
           ([H_CodedData_RK]
           ,[CodedData_BK]
           ,[ClientCodedDataID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT CodedDataHashKey, CDI, CodedData_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblCodedDataStage  with(nolock)
	WHERE
		CodedDataHashKey not in (Select H_CodedData_RK from H_CodedData)
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
		CHSStaging.adv.tblCodedDataStage with(nolock)
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
	AND CCI= @CCI

	--** LOAD H_CodedData _ QA

INSERT INTO [dbo].[H_CodedData]
           ([H_CodedData_RK]
           ,[CodedData_BK]
           ,[ClientCodedDataID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT CodedDataHashKey, CDI, CodedData_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblCodedDataQAStage  with(nolock)
	WHERE
		CodedDataHashKey not in (Select H_CodedData_RK from H_CodedData)
		AND CCI= @CCI
End
GO
