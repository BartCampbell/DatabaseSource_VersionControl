SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getOffice '0','0',0,0,'','UO','ASC',0,1,0,0,''
--	[im_getOffice] 0,0,0,'','UO','ASC',9,9,0,0,''
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
	@mid bigint,
	@office bigint,
	@invoice varchar(20)
AS
BEGIN
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

	DECLARE @MemberID AS VARCHAR(100) = ''
	IF (@mid<>0)
		SELECT @MemberID=Member_ID FROM tblMember WHERE Member_PK=@mid

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UO' THEN POI.dtUpdate ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UO' THEN POI.dtUpdate ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'IN' THEN POI.InvoiceNumber WHEN 'IA' THEN POI.InvoiceAmount WHEN 'AD' THEN PO.Address ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'IN' THEN POI.InvoiceNumber WHEN 'IA' THEN POI.InvoiceAmount WHEN 'AD' THEN PO.Address ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AP' THEN POI.IsApproved WHEN 'PD' THEN IsNull(POI.IsPaid,0) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AP' THEN POI.IsApproved WHEN 'PD' THEN IsNull(POI.IsPaid,0) ELSE NULL END END DESC
		) AS RowNumber
			,PO.ProviderOffice_PK,POI.ProviderOfficeInvoice_PK
			,POI.InvoiceNumber,POI.InvoiceAmount,IV.InvoiceVendor,POI.dtUpdate [Uploaded Date]
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,CASE 
				WHEN POI.IsApproved=1 THEN 'Approved'
				WHEN POI.IsApproved=0 THEN 'Rejected'
				ELSE 'Pending'
			END [Status]
			,IsNull(POI.IsPaid,0) IsPaid
			,Count(DISTINCT S.Suspect_PK) Charts
			,POI.InvoiceVendor_PK, InvoiceAccountNumber, Check_Transaction_Number, PaymentType_PK, Inv_File
		INTO #tbl
		FROM 
			tblProviderOfficeInvoice POI WITH (NOLOCK)
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=POI.ProviderOffice_PK 
			INNER JOIN tblExtractionQueueAttachLog EQAL ON EQAL.ProviderOfficeInvoice_PK = POI.ProviderOfficeInvoice_PK
			INNER JOIN tblSuspect S ON S.Suspect_PK = EQAL.Suspect_PK
			INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
			LEFT JOIN tblInvoiceVendor IV ON IV.InvoiceVendor_PK = POI.InvoiceVendor_PK
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			AND (@office=0 OR PO.ProviderOffice_PK=@office)
--			AND (@mid=0 OR P.ProviderOffice_PK IS NOT NULL)
--			AND (@invoice='' OR P.ProviderOffice_PK IS NOT NULL)

--			AND (@filter_type<>0 OR POI.IsApproved Is NULL) --Pending
--			AND (@filter_type<>1 OR POI.IsApproved=0) -- Rejected
--			AND (@filter_type<>2 OR POI.IsApproved=1) -- Approved
--			AND (@filter_type<>4 OR (POI.IsApproved=1 AND IsNull(IsPaid,0)=0)) -- Approved & Not Paid
--			AND (@filter_type<>5 OR (POI.IsApproved=1 AND IsPaid=1)) -- Approved & Paid

--			AND (@mid=0 OR M.Member_ID=@MemberID)
--			AND (@invoice='' OR POI.InvoiceNumber Like '%'+@invoice+'%')
		GROUP BY PO.ProviderOffice_PK,POI.ProviderOfficeInvoice_PK
			,POI.InvoiceNumber,POI.InvoiceAmount,IV.InvoiceVendor,POI.dtUpdate
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,POI.IsApproved, POI.IsPaid
			,POI.InvoiceVendor_PK, InvoiceAccountNumber, Check_Transaction_Number, PaymentType_PK, Inv_File
	IF (@Page<>0) 
	BEGIN
		SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber

		SELECT UPPER(LEFT(Address,1)) alpha1, UPPER(RIGHT(LEFT(Address,2),1)) alpha2,Count(DISTINCT ProviderOffice_PK) records
			FROM #tbl
			GROUP BY LEFT(Address,1), RIGHT(LEFT(Address,2),1)			
			ORDER BY alpha1, alpha2
	END
	ELSE
		SELECT * FROM #tbl ORDER BY RowNumber

	Drop Table #tbl
END
GO
