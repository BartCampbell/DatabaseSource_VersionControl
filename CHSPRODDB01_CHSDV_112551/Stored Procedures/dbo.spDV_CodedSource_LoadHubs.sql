SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblCodedSourceStage table.
-- =============================================
Create PROCEDURE [dbo].[spDV_CodedSource_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_CodedSource

INSERT INTO [dbo].[H_CodedSource]
           ([H_CodedSource_RK]
           ,[CodedSource_BK]
           ,[ClientCodedSourceID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT CodedSourceHashKey, CSI, CodedSource_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblCodedSourceStage  with(nolock)
	WHERE
		CodedSourceHashKey not in (Select H_CodedSource_RK from H_CodedSource)
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
		CHSStaging.adv.tblCodedSourceStage with(nolock)
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
	AND CCI= @CCI


End
GO
