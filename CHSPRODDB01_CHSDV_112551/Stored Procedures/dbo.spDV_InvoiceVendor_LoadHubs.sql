SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date: 08/25/2016
-- Description:	Load all Hubs from the InvoiceVendor staging table.  
-- =============================================
CREATE PROCEDURE [dbo].[spDV_InvoiceVendor_LoadHubs]
	-- Add the parameters for the stored procedure here
	@CCI VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--** LOAD H_InvoiceVendor
INSERT INTO [dbo].[H_InvoiceVendor]
           ([H_InvoiceVendor_RK]
           ,[InvoiceVendor_BK]
           ,[ClientInvoiceVendorID]
           ,[RecordSource]
           ,[LoadDate])
 
SELECT	DISTINCT InvoiceVendorHashKey, CVI, InvoiceVendor_PK,RecordSource,LoadDate
	FROM 
		CHSStaging.adv.tblInvoiceVendorStage
	WHERE
		InvoiceVendorHashKey not in (Select H_InvoiceVendor_RK from H_InvoiceVendor)
		AND CCI = @CCI



--** LOAD H_CLIENT
INSERT INTO H_Client
	SELECT 
		DISTINCT ClientHashKey, CCI, Client, RecordSource,  LoadDate
	FROM 
		CHSStaging.adv.tblInvoiceVendorStage
	WHERE
		ClientHashKey not in (Select H_Client_RK from H_Client)
			AND CCI = @CCI

			

END



GO
