SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblInvoiceVendorHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadInvoiceVendorHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadInvoiceVendorHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        
       
        INSERT  INTO adv.tblInvoiceVendorHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.InvoiceVendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceVendor,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblInvoiceVendorStage a
                        LEFT OUTER JOIN adv.tblInvoiceVendorHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.InvoiceVendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceVendor,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.LastUpdated,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;




    END;
GO
