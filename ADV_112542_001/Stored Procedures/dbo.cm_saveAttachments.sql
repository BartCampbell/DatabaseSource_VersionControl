SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_saveAttachments 1,1
CREATE PROCEDURE [dbo].[cm_saveAttachments] 
	@suspect varchar(max),
	@fileID int,
	@pgFrom smallint,
	@pgTo smallint,
	@usr smallint,
	@invoice tinyint,
	@invoiceAmount int,
	@invoiceNumber varchar(20),
	@invoiceVendor int,
	@office int,
	@cna int,
	@dup int
AS
BEGIN
	DECLARE @InvoicePK AS INT = 0
	IF (@invoice=1)
	BEGIN
		SELECT TOP 1 @InvoicePK=ProviderOfficeInvoice_PK FROM tblExtractionQueueAttachLog WITH (NOLOCK) WHERE IsProcessed=0 AND IsInvoice=1 AND ExtractionQueue_PK=@fileID AND PageFrom=@pgFrom AND PageTo=@pgTo
		IF (@InvoicePK IS NULL)
		BEGIN
			INSERT INTO tblProviderOfficeInvoice(InvoiceAmount,InvoiceNumber,InvoiceVendor_PK,ProviderOffice_PK,dtUpdate,UploadDate,Update_User_PK) VALUES(@invoiceAmount,@invoiceNumber,@invoiceVendor,@office,GETDATE(),GetDate(),@usr)
			SELECT @InvoicePK = @@IDENTITY
		END
		ELSE
		BEGIN
			UPDATE tblProviderOfficeInvoice SET InvoiceAmount=@invoiceAmount, InvoiceNumber=@invoiceNumber, InvoiceVendor_PK=@invoiceVendor, ProviderOffice_PK=@office WHERE ProviderOfficeInvoice_PK = @InvoicePK
		END
	END
	DECLARE @SQL AS VARCHAR(MAX)	
	SET @SQL = 'INSERT INTO tblExtractionQueueAttachLog(Suspect_PK,User_PK,ExtractionQueue_PK,PageFrom,PageTo,dtInsert,IsProcessed,IsInvoice,ProviderOfficeInvoice_PK,IsCNA,IsDuplicate) '; 
	IF (@dup=1) 
		SET @SQL = @SQL + 'SELECT 0 Suspect_PK,'+CAST(@usr AS VARCHAR)+','+CAST(@fileID AS VARCHAR)+','+CAST(@pgFrom AS VARCHAR)+','+CAST(@pgTo AS VARCHAR)+',getDate(),1,'+CAST(@invoice AS VARCHAR)+','+CAST(@InvoicePK AS VARCHAR)+','+CAST(@cna AS VARCHAR)+','+CAST(@dup AS VARCHAR)+';';
	ELSE 
		SET @SQL = @SQL + 'SELECT Suspect_PK,'+CAST(@usr AS VARCHAR)+','+CAST(@fileID AS VARCHAR)+','+CAST(@pgFrom AS VARCHAR)+','+CAST(@pgTo AS VARCHAR)+',getDate(),0,'+CAST(@invoice AS VARCHAR)+','+CAST(@InvoicePK AS VARCHAR)+','+CAST(@cna AS VARCHAR)+','+CAST(@dup AS VARCHAR)+' FROM tblSuspect WITH (NOLOCK) WHERE Suspect_PK IN ('+ @suspect +');';
	IF (@dup=0 AND @cna=0)
	BEGIN
		SET @SQL = @SQL + 'UPDATE tblSuspect WITH (ROWLOCK) SET IsCNA=0,CNA_User_PK=NULL,CNA_Date=NULL,'+CASE WHEN @invoice=1 THEN 'InvoiceRec_Date' ELSE 'ChartRec_Date' END+'=GETDATE() WHERE Suspect_PK IN ('+ @suspect +');'
	END

	--PRINT @SQL
	EXEC (@SQL);
END
GO
