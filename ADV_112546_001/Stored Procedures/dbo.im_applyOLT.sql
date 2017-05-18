SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  im_applyOLT
CREATE PROCEDURE [dbo].[im_applyOLT]
AS
BEGIN
	DECLARE @ChartLimit Float
	DECLARE @OfficeLimit Float
	SELECT @ChartLimit=SettingValue FROM tblInvoiceSettingOTL WHERE SettingDecription='ChartLimit'
	SELECT @OfficeLimit=SettingValue FROM tblInvoiceSettingOTL WHERE SettingDecription='OfficeLimit'

	IF (@ChartLimit IS NOT NULL OR @OfficeLimit IS NOT NULL)
	BEGIN
		SELECT POI.ProviderOfficeInvoice_PK INTO #tmp FROM tblProviderOfficeInvoice POI 
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
		WHERE ProviderOfficeInvoiceBucket_PK=6
		GROUP BY POI.ProviderOfficeInvoice_PK,POI.InvoiceAmount
		Having CAST(POI.InvoiceAmount AS FLOAT)/COUNT(POIS.Suspect_PK)>=@ChartLimit OR CAST(POI.InvoiceAmount AS FLOAT)>=@OfficeLimit

		Update POI SET ProviderOfficeInvoiceBucket_PK=8
		FROM tblProviderOfficeInvoice POI 
			INNER JOIN #tmp T ON T.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
	END
END
GO
