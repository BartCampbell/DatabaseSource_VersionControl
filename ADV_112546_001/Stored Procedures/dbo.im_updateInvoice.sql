SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_updateInvoice @invoice=2,@invoice_status=1,@usr=1,@invVendor=1,@invNum='ABC',@invAmt=100,@payType=1,@invTransNum='AHHHG',@invAcc='',@addInfo='Test',@inv_file='',@suspects='0,7152,7975',@office=2,@project=1
CREATE PROCEDURE [dbo].[im_updateInvoice] 
	@invoice int,
	@invoice_status tinyint,
	@usr int,
	@invVendor tinyint,
	@invNum varchar(20),
	@invAmt money,
	@payType tinyint,
	@invTransNum varchar(50),
	@invAcc varchar(20),
	@addInfo varchar(200),
	@inv_file varchar(50),
	@suspects varchar(1000),
	@office int,
	@project int
AS
BEGIN
	UPDATE tblSuspectInvoiceInfo SET Update_User_PK=@usr, dtUpdate = GETDATE(), 
		InvoiceVendor_PK=@invVendor,
		InvoiceNumber=@invNum,
		InvoiceAmount=@invAmt,
		AmountPaid=@invAmt,
		PaymentType_PK=@payType,
		Check_Transaction_Number=@invTransNum,
		InvoiceAccountNumber=@invAcc,
		Inv_File=@inv_file
	WHERE Invoice_PK = @invoice

	DELETE FROM tblSuspectInvoiceDetail WHERE Invoice_PK = @invoice

	EXEC('INSERT INTO tblSuspectInvoiceDetail(Invoice_PK,Suspect_PK) SELECT '+@invoice+',Suspect_PK FROM tblSuspect WHERE Suspect_PK IN ('+@suspects+')')

	IF (@invoice_status=5)
	BEGIN
		--PAID
		DECLARE @default_note AS varchar(1000) = 'Invoice# '+@invNum+' in the amount of $'+CAST(@invAmt AS VARCHAR)+' paid on '+ CAST(MONTH(GETDATE()) AS VARCHAR) +'-'+ CAST(DAY(GETDATE()) AS VARCHAR) +'-'+ CAST(YEAR(GETDATE()) AS VARCHAR) +' via '
		if (@payType=1)
			SET @default_note = @default_note + 'Credit Card with Confirmation#'
		else if (@payType=2)
			SET @default_note = @default_note + 'Check #'
		else if (@payType=3)
			SET @default_note = @default_note + 'EFT with Confirmation#'
		
		SET @default_note = @default_note + '  '+@invTransNum

		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
		VALUES(@project,@office,50,@default_note,@usr,GETDATE(),0)

		Update tblSuspectInvoiceInfo SET IsApproved = 1, IsPaid=1 WHERE Invoice_PK = @invoice
	END
	ELSE IF (@invoice_status=1)
	BEGIN
		--REJECTED
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
		VALUES(@project,@office,51,'Invoice '+@invNum+' in the amount of $'+CAST(@invAmt AS VARCHAR)+' rejected',@usr,GETDATE(),0)	
		
		Update tblSuspectInvoiceInfo SET IsApproved = 0, IsPaid=0 WHERE Invoice_PK = @invoice	
	END
	ELSE IF (@invoice_status=2)
	BEGIN
		--REJECTED
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
		VALUES(@project,@office,53,'Invoice '+@invNum+' in the amount of $'+CAST(@invAmt AS VARCHAR)+' approved',@usr,GETDATE(),0)		

		Update tblSuspectInvoiceInfo SET IsApproved = 1 WHERE Invoice_PK = @invoice	
	END

	IF (@addInfo<>'')
	BEGIN
		INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
		VALUES(@project,@office,52,@addInfo,@usr,GETDATE(),0)
	END
END
GO
