SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	a_ca_updateExtractionLog @invoice, @id,	@fileId, @from,	@to, @alreadyScanned, @totalPages
CREATE PROCEDURE [dbo].[a_ca_updateExtractionLog] 
	@attach_type tinyint,
	@id bigint,
	@fileId int,
	@from int,
	@to int,
	@alreadyScanned int,
	@totalPages int,
	@pagesScanned int,
	@user int
AS
BEGIN
	IF (@attach_type = 0) --Chart
	BEGIN
		UPDATE tblExtractionQueueAttachLog 
		SET dtProcessed=getDate(),IsProcessed=1,PagesAlreadyScanned=@alreadyScanned,PagesInPDF=@totalPages, PagesScanned=@pagesScanned
		WHERE (IsProcessed IS NULL OR IsProcessed=0) AND Suspect_PK=@id AND ExtractionQueue_PK=@fileId AND pageFrom=@from AND pageTo=@to

		UPDATE S SET S.IsScanned = 1, S.Scanned_Date = GETDATE(), S.Scanned_User_PK = @user
		FROM tblSuspect S 
		WHERE Suspect_PK=@id AND S.Scanned_Date IS NULL
	END
	ELSE IF (@attach_type = 1) --Invoice
	BEGIN
		UPDATE tblExtractionQueueAttachLog 
		SET dtProcessed=getDate(),IsProcessed=1,PagesAlreadyScanned=@alreadyScanned,PagesInPDF=@totalPages, PagesScanned=@pagesScanned
		WHERE (IsProcessed IS NULL OR IsProcessed=0) AND ProviderOfficeInvoice_PK=@id AND ExtractionQueue_PK=@fileId AND pageFrom=@from AND pageTo=@to

        UPDATE tblProviderOfficeInvoice SET IsExtracted=1,ProviderOfficeInvoiceBucket_PK=6 WHERE ProviderOfficeInvoice_PK=@id

        DELETE FROM tblProviderOfficeInvoiceSuspect WHERE ProviderOfficeInvoice_PK=@id

        INSERT INTO tblProviderOfficeInvoiceSuspect(ProviderOfficeInvoice_PK,Suspect_PK) 
		Select DISTINCT ProviderOfficeInvoice_PK,Suspect_PK FROM tblExtractionQueueAttachLog 
			WHERE IsProcessed=1 AND ProviderOfficeInvoice_PK=@id

		UPDATE S SET S.IsInvoiced = 1, S.InvoiceExt_Date = GETDATE()
		FROM tblSuspect S INNER JOIN tblProviderOfficeInvoiceSuspect POIS WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK AND POIS.ProviderOfficeInvoice_PK = @id
		WHERE S.InvoiceExt_Date IS NULL
	END
	ELSE IF (@attach_type = 2) --W9
		UPDATE tblExtractionQueueAttachLog 
		SET dtProcessed=getDate(),IsProcessed=1,PagesAlreadyScanned=@alreadyScanned,PagesInPDF=@totalPages, PagesScanned=@pagesScanned
		WHERE (IsProcessed IS NULL OR IsProcessed=0) AND Suspect_PK=@id AND ExtractionQueue_PK=@fileId AND pageFrom=@from AND pageTo=@to
END
GO
