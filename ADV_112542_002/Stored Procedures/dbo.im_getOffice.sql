SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getOffice '0','0',0,25,'','UO','ASC',0,1,'','','','','','',12
--	im_getOffice '0','0',0,0,'','UO','ASC',0,1,'','','','','','',107
Create PROCEDURE [dbo].[im_getOffice] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@filter_type int,
	@user int,
	@chase varchar(100),
	@member varchar(100),
	@address varchar(100),
	@invoice varchar(100),
	@provider varchar(100),
	@vendor varchar(100),
	@officePK int
AS
BEGIN
	If (@officePK>0)
		SET @PageSize = 1000
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	CREATE INDEX idxProjectPK ON #tmpProject (Project_PK)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');
	-- PROJECT SELECTION

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UO' THEN POI.dtUpdate ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UO' THEN POI.dtUpdate ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'IN' THEN POI.InvoiceNumber WHEN 'IV' THEN IV.InvoiceVendor WHEN 'AD' THEN PO.Address WHEN 'ST' THEN POIB.Bucket ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'IN' THEN POI.InvoiceNumber WHEN 'IV' THEN IV.InvoiceVendor WHEN 'AD' THEN PO.Address WHEN 'ST' THEN POIB.Bucket ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CHT' THEN Count(DISTINCT S.Suspect_PK) WHEN 'IA' THEN POI.AmountPaid ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CHT' THEN Count(DISTINCT S.Suspect_PK) WHEN 'IA' THEN POI.AmountPaid ELSE NULL END END DESC
		) AS RowNumber
			,PO.ProviderOffice_PK,POI.ProviderOfficeInvoice_PK
			,POI.InvoiceNumber,POI.InvoiceAmount,IV.InvoiceVendor,POI.dtUpdate [Uploaded Date]
			,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode
			,POIB.Bucket [Status], POIB.ProviderOfficeInvoiceBucket_PK
			,Count(DISTINCT S.Suspect_PK) Charts
			,POI.InvoiceVendor_PK, InvoiceAccountNumber, Check_Transaction_Number, PaymentType_PK, Inv_File,POI.AmountPaid
		INTO #tbl
		FROM 
			tblProviderOfficeInvoice POI WITH (NOLOCK)
			INNER JOIN tblProviderOfficeInvoiceBucket POIB WITH (NOLOCK) ON POIB.ProviderOfficeInvoiceBucket_PK = POI.ProviderOfficeInvoiceBucket_PK
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=POI.ProviderOffice_PK 
			INNER JOIN tblProviderOfficeInvoiceSuspect POIS ON POIS.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Suspect_PK = POIS.Suspect_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			LEFT JOIN tblInvoiceVendor IV WITH (NOLOCK) ON IV.InvoiceVendor_PK = POI.InvoiceVendor_PK
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			AND (@officePK=0 OR PO.ProviderOffice_PK=@officePK)
			AND (@filter_type=0 OR POI.ProviderOfficeInvoiceBucket_PK=@filter_type)
			AND (@chase='' OR S.ChaseID Like '%'+@chase+'%')
			AND (@member='' OR M.Member_ID  + ' ' + M.Lastname + ' ' + M.Firstname Like '%'+@member+'%')
			AND (@invoice='' OR POI.InvoiceNumber Like '%'+@invoice+'%')
			AND (@address='' OR PO.Address Like '%'+@address+'%')
			AND (@provider='' OR PM.Provider_ID  + ' ' + PM.Lastname + ' ' + IsNull(PM.Firstname,'') Like '%'+@provider+'%')
			AND (@vendor='' OR IV.InvoiceVendor Like '%'+@vendor+'%')
		GROUP BY PO.ProviderOffice_PK,POI.ProviderOfficeInvoice_PK
			,POI.InvoiceNumber,POI.InvoiceAmount,IV.InvoiceVendor,POI.dtUpdate
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,POIB.Bucket, POIB.ProviderOfficeInvoiceBucket_PK
			,POI.InvoiceVendor_PK, InvoiceAccountNumber, Check_Transaction_Number, PaymentType_PK, Inv_File,POI.AmountPaid
	IF (@Page<>0) 
	BEGIN
		SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber

		SELECT UPPER(LEFT(Address,1)) alpha1, UPPER(RIGHT(LEFT(Address,2),1)) alpha2,Count(DISTINCT ProviderOffice_PK) records
			FROM #tbl
			GROUP BY LEFT(Address,1), RIGHT(LEFT(Address,2),1)			
			ORDER BY alpha1, alpha2
	END
	ELSE
	BEGIN
		ALTER TABLE #tbl DROP COLUMN ProviderOffice_PK
		ALTER TABLE #tbl DROP COLUMN ProviderOfficeInvoice_PK
		ALTER TABLE #tbl DROP COLUMN ProviderOfficeInvoiceBucket_PK
		ALTER TABLE #tbl DROP COLUMN PaymentType_PK
		ALTER TABLE #tbl DROP COLUMN InvoiceVendor_PK

		SELECT * FROM #tbl ORDER BY RowNumber
	END
	Drop Table #tbl
END
GO
