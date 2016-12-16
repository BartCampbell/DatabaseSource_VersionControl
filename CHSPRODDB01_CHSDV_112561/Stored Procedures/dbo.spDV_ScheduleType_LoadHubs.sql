SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/26/2016
-- Description:	Load all Hubs from the Advantage tblScheduleTypeStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ScheduleType_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	--** LOAD H_ScheduleType

INSERT INTO [dbo].[H_ScheduleType]
           ([H_ScheduleType_RK]
           ,[ScheduleType_BK]
           ,[ClientScheduleTypeID]
           ,[LoadDate]
           ,[RecordSource])
	SELECT 
		DISTINCT ScheduleTypeHashKey, CSI, ScheduleType_PK, LoadDate , RecordSource
	FROM 
		CHSStaging.adv.tblScheduleTypeStage  WITH(NOLOCK)
	WHERE
		ScheduleTypeHashKey NOT IN (SELECT H_ScheduleType_RK FROM H_ScheduleType)
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
		CHSStaging.adv.tblScheduleTypeStage WITH(NOLOCK)
	WHERE
		ClientHashKey NOT IN (SELECT H_Client_RK FROM H_Client)
	AND CCI= @CCI



END


GO
