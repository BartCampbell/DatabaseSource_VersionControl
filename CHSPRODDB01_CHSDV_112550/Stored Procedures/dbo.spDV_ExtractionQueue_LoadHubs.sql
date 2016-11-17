SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/15/2016
-- Description:	Load all Hubs from the Advantage tblExtractionQueueStage table.
-- =============================================
CREATE PROCEDURE [dbo].[spDV_ExtractionQueue_LoadHubs]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(50)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;


--** LOAD H_ExtractionQueue

        INSERT  INTO [dbo].[H_ExtractionQueue]
                ( [H_ExtractionQueue_RK] ,
                  [ExtractionQueue_BK] ,
                  [ClientExtracionQueueID] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT 
		DISTINCT        ExtractionQueueHashKey ,
                        CEI ,
                        ExtractionQueue_PK ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblExtractionQueueStage WITH ( NOLOCK )
                WHERE   ExtractionQueueHashKey NOT IN (
                        SELECT  H_ExtractionQueue_RK
                        FROM    H_ExtractionQueue )
                        AND CCI = @CCI;
		

--** LOAD H_CLIENT
        INSERT  INTO [dbo].[H_Client]
                ( [H_Client_RK] ,
                  [Client_BK] ,
                  [ClientName] ,
                  [RecordSource] ,
                  [LoadDate]
                )
                SELECT 
		DISTINCT        ClientHashKey ,
                        CCI ,
                        Client ,
                        RecordSource ,
                        LoadDate
                FROM    CHSStaging.adv.tblExtractionQueueStage WITH ( NOLOCK )
                WHERE   ClientHashKey NOT IN ( SELECT   H_Client_RK
                                               FROM     H_Client )
                        AND CCI = @CCI;


    END;
GO
