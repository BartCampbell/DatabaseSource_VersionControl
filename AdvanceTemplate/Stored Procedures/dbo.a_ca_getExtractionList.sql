SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	a_ca_getExtractionList 0,2,1
CREATE PROCEDURE [dbo].[a_ca_getExtractionList] 
	@invoice tinyint,
	@type tinyint,
	@id bigint
AS
BEGIN
	if (@type=1)
	BEGIN
		Update tblExtractionQueue SET OfficeFaxOrID=SUBSTRING(PDFname,1,10) 
			WHERE SUBSTRING(PDFname,11,1)='_' AND OfficeFaxOrID IS NULL AND ExtractionQueueSource_PK IN (1,7) AND UploadDate>'2016-8-8'

		Update tblExtractionQueueAttachLog SET IsProcessed=1 
			WHERE IsProcessed=0 AND PageFrom=0 AND PageTo=0

		if (@invoice = 0)
		BEGIN
			SELECT DISTINCT S.Suspect_PK,S.Project_PK,S.Provider_PK,EQAL.User_PK,CAST(EQAL.ExtractionQueue_PK AS varchar) FileId,EQ.PDFname,EQAL.pageFrom,EQAL.pageTo  
			FROM tblSuspect S WITH (NOLOCK) 
			INNER JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQAL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblExtractionQueue EQ WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
			WHERE EQAL.IsProcessed=0 AND EQAL.IsInvoice=0
		END
		ELSE
		BEGIN
			SELECT DISTINCT EQAL.ProviderOfficeInvoice_PK,EQAL.User_PK,CAST(EQAL.ExtractionQueue_PK AS varchar) FileId,EQ.PDFname,EQAL.pageFrom,EQAL.pageTo  
			FROM tblExtractionQueueAttachLog EQAL
				INNER JOIN tblExtractionQueue EQ WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
			WHERE EQAL.IsProcessed=0 AND EQAL.IsInvoice=1
		END
	END
	ELSE
	BEGIN
		if (@invoice = 0)
		BEGIN
			SELECT COUNT(*) AlreadyScanned FROM tblScannedData SD WITH (NOLOCK) WHERE SD.Suspect_PK=@id
		END
		ELSE
		BEGIN
			SELECT COUNT(*) AlreadyScanned FROM tblScannedDataInvoice SD WITH (NOLOCK) WHERE SD.ProviderOfficeInvoice_PK=@id
		END
	END	
END
GO
