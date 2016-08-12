SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getInvoices 1,2
CREATE PROCEDURE [dbo].[im_getInvoices] 
	@Project int,
	@Office int
AS
BEGIN
	SELECT SII.Invoice_PK,S.Suspect_PK
			,SII.dtInsert,SII.InvoiceNumber,SII.InvoiceAmount,IsNull(IV.InvoiceVendor,'OTHERS') InvoiceVendor
			,(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
			,IV.InvoiceVendor_PK,PaymentType_PK,InvoiceAccountNumber,Check_Transaction_Number,Inv_File
		FROM tblSuspectInvoiceInfo SII WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = SII.Suspect_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblInvoiceVendor IV WITH (NOLOCK) ON IV.InvoiceVendor_PK = SII.InvoiceVendor_PK
		WHERE P.ProviderOffice_PK=@Office AND S.Project_PK=@Project

	--Total
	SELECT 
			SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
		FROM tblSuspectInvoiceInfo SII WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = SII.Suspect_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			LEFT JOIN tblInvoiceVendor IV WITH (NOLOCK) ON IV.InvoiceVendor_PK = SII.InvoiceVendor_PK
		WHERE P.ProviderOffice_PK=@Office AND S.Project_PK=@Project
END


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name='IX_tblSuspectInvoiceInfo_Suspect' AND object_id = OBJECT_ID('tblSuspectInvoiceInfo'))
BEGIN
	ALTER TABLE [dbo].[tblSuspectInvoiceInfo] DROP CONSTRAINT [PK_tblSuspectInvoiceInfo]

	ALTER TABLE [dbo].[tblSuspectInvoiceInfo] ADD  CONSTRAINT [PK_tblSuspectInvoiceInfo] PRIMARY KEY CLUSTERED 
	(
		[Invoice_PK] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IX_tblSuspectInvoiceInfo_Suspect] ON [dbo].[tblSuspectInvoiceInfo]
	(
		[Suspect_PK] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO
