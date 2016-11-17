SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/13/2016
-- Description:	Loads the tblSuspectInvoiceInfoHash with the hashdiff key
-- Usage		EXECUTE adv.spLoadSuspectInvoiceInfoHash
-- =============================================
CREATE PROCEDURE [adv].[spLoadSuspectInvoiceInfoHash]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	
        
       
        INSERT  INTO adv.tblSuspectInvoiceInfoHash
                ( HashDiff
                )
                SELECT  UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                          UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AccountNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceAmount,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceVendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsApproved,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Update_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtUpdate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Invoice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AmountPaid,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Check_Transaction_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PaymentType_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceAccountNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Inv_File,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsPaid,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2))
                FROM    adv.tblSuspectInvoiceInfoStage a
                        LEFT OUTER JOIN adv.tblSuspectInvoiceInfoHash b ON UPPER(CONVERT(CHAR(32), HASHBYTES('MD5',
                                                              UPPER(CONCAT(RTRIM(LTRIM(COALESCE(a.Suspect_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AccountNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceAmount,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceVendor_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtInsert,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsApproved,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Update_User_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.dtUpdate,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Invoice_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.AmountPaid,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Check_Transaction_Number,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.PaymentType_PK,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.InvoiceAccountNumber,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Inv_File,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.IsPaid,
                                                              ''))), ':',
                                                              RTRIM(LTRIM(COALESCE(a.Client,
                                                              '')))))), 2)) = b.HashDiff
                WHERE   b.HashDiff IS NULL;





    END;
GO
