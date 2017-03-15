SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/31/2016
-- Description:	Load the R_ZipCode reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_ZipCode] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceZipCode]
                ( [ClientID] ,
                  [ClientZipCodeID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[ZipCode_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblZipCodeStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceZipCode] b ON a.ZipCode_PK = b.ClientZipCodeID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientZipCodeID IS NULL;

        UPDATE  CHSStaging.adv.tblZipCodeStage
        SET     ZipCodeHashKey = b.ZipCodeHashKey
        FROM    CHSStaging.adv.tblZipCodeStage a
                INNER JOIN CHSDV.dbo.R_AdvanceZipCode b ON a.ZipCode_PK = b.ClientZipCodeID
                                                           AND a.CCI = b.ClientID;





        UPDATE  CHSStaging.adv.tblZipCodeStage
        SET     CZI = b.CentauriZipCodeID
        FROM    CHSStaging.adv.tblZipCodeStage a
                INNER JOIN CHSDV.dbo.R_AdvanceZipCode b ON a.ZipCode_PK = b.ClientZipCodeID
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
