SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load the R_InvoiceVendor reference table and pull back the hashkey
-- =============================================
CREATE PROCEDURE [adv].[spLoadR_InvoiceVendor] 
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(100)
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        INSERT  INTO [CHSDV].[dbo].[R_AdvanceInvoiceVendor]
                ( [ClientID] ,
                  [ClientInvoiceVendorID] ,
                  [LoadDate] ,
                  [RecordSource]
                )
                SELECT  DISTINCT
                        a.[CCI] ,
                        a.[InvoiceVendor_PK] ,
                        a.LoadDate ,
                        a.[RecordSource]
                FROM    CHSStaging.adv.tblInvoiceVendorStage a
                        LEFT OUTER JOIN [CHSDV].[dbo].[R_AdvanceInvoiceVendor] b ON a.InvoiceVendor_PK = b.ClientInvoiceVendorID AND a.CCI = b.ClientID
                WHERE   a.CCI = @CCI
                        AND b.ClientInvoiceVendorID IS NULL;

        UPDATE  CHSStaging.adv.tblInvoiceVendorStage
        SET     InvoiceVendorHashKey = b.InvoiceVendorHashKey
        FROM    CHSStaging.adv.tblInvoiceVendorStage a
                INNER JOIN CHSDV.dbo.R_AdvanceInvoiceVendor b ON a.InvoiceVendor_PK = b.ClientInvoiceVendorID
                                                           AND a.CCI = b.ClientID;


        UPDATE  CHSStaging.adv.tblInvoiceVendorStage
        SET     ClientHashKey = b.[ClientHashKey]
        FROM    CHSStaging.adv.tblInvoiceVendorStage a
                INNER JOIN CHSDV.dbo.R_Client b ON a.CCI = b.CentauriClientID;





        UPDATE  CHSStaging.adv.tblInvoiceVendorStage
        SET     CVI = b.CentauriInvoiceVendorID
        FROM    CHSStaging.adv.tblInvoiceVendorStage a
                INNER JOIN CHSDV.dbo.R_AdvanceInvoiceVendor b ON a.InvoiceVendor_PK = b.ClientInvoiceVendorID
                                                           AND a.CCI = b.ClientID;


										   


    END;
GO
