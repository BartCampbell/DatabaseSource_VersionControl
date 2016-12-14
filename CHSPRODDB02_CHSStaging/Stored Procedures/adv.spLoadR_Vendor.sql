SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load the R_Vendor reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_Vendor] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceVendor]
                ( [ClientID] ,
                  [ClientVendorID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[Vendor_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblVendorStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceVendor] b ON a.Vendor_PK = b.ClientVendorID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientVendorID IS NULL;

        UPDATE  CHSStaging.adv.tblVendorStage
        SET     VendorHashKey = b.VendorHashKey
        FROM    CHSStaging.adv.tblVendorStage a
                INNER JOIN CHSDV.dbo.R_AdvanceVendor b ON a.Vendor_PK = b.ClientVendorID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblVendorStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblVendorStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;





        UPDATE  CHSStaging.adv.tblVendorStage
        SET     CVI = b.CentauriVendorID
        FROM    CHSStaging.adv.tblVendorStage a
                INNER JOIN CHSDV.dbo.R_AdvanceVendor b ON a.Vendor_PK = b.ClientVendorID
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
