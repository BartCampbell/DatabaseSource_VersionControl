SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/30/2016
-- Description:	Load the R_Location reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_Location] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceLocation]
                ( [ClientID] ,
                  [ClientLocationID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[Location_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblLocationStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceLocation] b ON a.Location_PK = b.ClientLocationID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientLocationID IS NULL;

        UPDATE  CHSStaging.adv.tblLocationStage
        SET     LocationHashKey = b.LocationHashKey
        FROM    CHSStaging.adv.tblLocationStage a
                INNER JOIN CHSDV.dbo.R_AdvanceLocation b ON a.Location_PK = b.ClientLocationID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblLocationStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblLocationStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;





        UPDATE  CHSStaging.adv.tblLocationStage
        SET     CLI = b.CentauriLocationID
        FROM    CHSStaging.adv.tblLocationStage a
                INNER JOIN CHSDV.dbo.R_AdvanceLocation b ON a.Location_PK = b.ClientLocationID
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
