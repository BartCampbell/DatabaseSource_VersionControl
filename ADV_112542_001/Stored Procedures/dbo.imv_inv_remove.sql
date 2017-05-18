SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_inv_remove 41,1
CREATE PROCEDURE [dbo].[imv_inv_remove] 
	@invoice bigint,
	@user int
AS
BEGIN
	IF EXISTS(Select * FROM tblProviderOfficeInvoice WHERE ProviderOfficeInvoice_PK=@invoice AND ProviderOfficeInvoiceBucket_PK=6)
	BEGIN
		UPDATE S SET IsInvoiced=0,InvoiceExt_Date=NULL,InvoiceRec_Date=NULL
			FROM tblProviderOfficeInvoiceSuspect POI WITH (NOLOCK) INNER JOIN tblSuspect S ON S.Suspect_PK = POI.Suspect_PK WHERE POI.ProviderOfficeInvoice_PK=@invoice

		UPDATE EQ SET AssignedUser_PK=@user,AssignedDate=GetDate() FROM tblExtractionQueueAttachLog EQAL WITH (NOLOCK) INNER JOIN tblExtractionQueue EQ ON EQ.ExtractionQueue_PK=EQAL.ExtractionQueue_PK WHERE EQAL.ProviderOfficeInvoice_PK=@invoice AND EQAL.IsInvoice=1
		DELETE EQAL	FROM tblExtractionQueueAttachLog EQAL WHERE EQAL.ProviderOfficeInvoice_PK=@invoice AND EQAL.IsInvoice=1

		DELETE EQAL	FROM tblExtractionQueueAttachLog EQAL WHERE EQAL.ProviderOfficeInvoice_PK=@invoice AND EQAL.IsInvoice=1

		DELETE FROM tblScannedDataInvoice WHERE ProviderOfficeInvoice_PK=@invoice

		DELETE FROM tblProviderOfficeInvoiceSuspect WHERE ProviderOfficeInvoice_PK=@invoice
		DELETE FROM tblProviderOfficeInvoice WHERE ProviderOfficeInvoice_PK=@invoice

		SELECT 1
	END
	ELSE
		SELECT 0
END
GO
