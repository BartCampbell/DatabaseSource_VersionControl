SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_inv_getInvoicePages 26
CREATE PROCEDURE [dbo].[imv_inv_getInvoicePages] 
	@invoice bigint
AS
BEGIN
	SELECT PO.Address OfficeAddress1
		,ZC.City+', '+ZC.State+' '+ZC.Zipcode OfficeAddress2
	FROM tblProviderOfficeInvoice POI WITH (NOLOCK) 
		INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = POI.ProviderOffice_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
	WHERE POI.ProviderOfficeInvoice_PK = @invoice

	SELECT SD.ScannedDataInvoice_PK
	FROM tblScannedDataInvoice SD WITH (NOLOCK)
	WHERE SD.ProviderOfficeInvoice_PK=@invoice 
	ORDER BY SD.ScannedDataInvoice_PK
END
GO
