SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sync_getSuspect 2,2,'1/1/2014'
CREATE PROCEDURE [dbo].[sync_getInvoiceVendor]
	@LastSync smalldatetime
AS
BEGIN
	SELECT [InvoiceVendor_PK],[InvoiceVendor]
	FROM tblInvoiceVendor
	WHERE LastUpdated>=@LastSync
END
GO
