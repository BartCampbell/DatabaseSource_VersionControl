SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	imv_W9_getW9Pages 26
CREATE PROCEDURE [dbo].[imv_W9_getW9Pages] 
	@office bigint
AS
BEGIN
	SELECT PO.Address OfficeAddress1
		,ZC.City+', '+ZC.State+' '+ZC.Zipcode OfficeAddress2
	FROM tblProviderOffice PO WITH (NOLOCK) 
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
	WHERE PO.ProviderOffice_PK = @office

	SELECT SD.ScannedDataW9_PK
	FROM tblScannedDataW9 SD WITH (NOLOCK)
	WHERE SD.ProviderOffice_PK=@office 
	ORDER BY SD.ScannedDataW9_PK
END
GO
