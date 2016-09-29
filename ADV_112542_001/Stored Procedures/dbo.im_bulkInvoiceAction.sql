SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	im_bulkInvoiceAction 0,'25,26,24'
Create PROCEDURE [dbo].[im_bulkInvoiceAction] 
	@action tinyint,
	@invoices varchar(MAX),
	@user int
AS
BEGIN
	Create TABLE #Invoice (ProviderOfficeInvoice_PK INT)
	CREATE INDEX idxProviderOfficeInvoice_PK ON #Invoice (ProviderOfficeInvoice_PK) 
	SET @invoices = 'INSERT INTO #Invoice SELECT ProviderOfficeInvoice_PK FROM tblProviderOfficeInvoice WHERE ProviderOfficeInvoice_PK IN ('+@invoices+')'
	EXEC (@invoices);

	IF (@action=0)
	BEGIN
		SELECT ROW_NUMBER() OVER(ORDER BY POI.ProviderOfficeInvoice_PK,M.Lastname) AS RowNumber
				,POI.InvoiceNumber,POI.InvoiceAmount,IV.InvoiceVendor,POI.dtUpdate [Uploaded Date],POIB.Bucket [Invoice Status]
				,S.ChaseID,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
				,S.IsScanned Scanned,Scanned_Date
				,S.IsCNA CNA,CNA_Date
				,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
				,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			FROM 
				tblProviderOfficeInvoice POI WITH (NOLOCK)
				INNER JOIN #Invoice tI ON tI.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
				INNER JOIN tblProviderOfficeInvoiceBucket POIB WITH (NOLOCK) ON POIB.ProviderOfficeInvoiceBucket_PK = POI.ProviderOfficeInvoiceBucket_PK
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=POI.ProviderOffice_PK 
				INNER JOIN tblProviderOfficeInvoiceSuspect POIS ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
				INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
				LEFT JOIN tblInvoiceVendor IV WITH (NOLOCK) ON IV.InvoiceVendor_PK = POI.InvoiceVendor_PK
				LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
	END
	ELSE 
	BEGIN
		UPDATE POI SET Update_User_PK=@user, dtUpdate = GETDATE(), 
			ProviderOfficeInvoiceBucket_PK = @action
		FROM tblProviderOfficeInvoice POI INNER JOIN #Invoice tI ON tI.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK

		IF (@action=4)
		BEGIN
			--PAID
			INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
			SELECT 0,POI.ProviderOffice_PK,ContactNote_PK,'Invoice '+POI.InvoiceNumber+' in the amount of $'+POI.InvoiceAmount+' is paid',@user,GETDATE(),0 
				FROM tblContactNote CN, #Invoice tI,tblProviderOfficeInvoice POI WHERE CN.sortOrder = 804 AND tI.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
		END
		ELSE IF (@action=5)
		BEGIN
			--Reimbursement initiated
			INSERT INTO tblContactNotesOffice(Project_PK,Office_PK,ContactNote_PK,ContactNoteText,LastUpdated_User_PK,LastUpdated_Date,contact_num)
			SELECT 0,POI.ProviderOffice_PK,ContactNote_PK,'Invoice '+POI.InvoiceNumber+' in the amount of $'+POI.InvoiceAmount+' moved for reimbursement',@user,GETDATE(),0 
				FROM tblContactNote CN, #Invoice tI,tblProviderOfficeInvoice POI WHERE CN.sortOrder = 805 AND tI.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
		END
	END
END
GO
