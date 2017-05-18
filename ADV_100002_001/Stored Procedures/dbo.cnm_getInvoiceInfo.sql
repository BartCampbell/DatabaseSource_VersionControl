SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getInvoiceInfo 546
Create PROCEDURE [dbo].[cnm_getInvoiceInfo] 
	@suspect bigint
AS
BEGIN
	SELECT IsNull(MAX(ProviderOfficeInvoice_PK),0) ProviderOfficeInvoice_PK FROM tblProviderOfficeInvoiceSuspect WITH (NOLOCK) WHERE Suspect_PK=@suspect
END
GO
