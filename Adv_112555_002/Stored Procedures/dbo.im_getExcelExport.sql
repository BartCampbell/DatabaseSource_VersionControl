SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getExcelExport 0,0,0,0,'','UO','ASC',9,1,0,0,''
--	[im_getOffice] 0,0,0,'','UO','ASC',9,9,0,0,''
Create PROCEDURE [dbo].[im_getExcelExport] 
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

	--DROP TABLE #tmpInv
	CREATE TABLE #tmpInv (Invoice_PK BIGINT,Suspect_PK BIGINT)
	CREATE INDEX idxInvIPK ON #tmpInv (Invoice_PK)
	CREATE INDEX idxInvSPK ON #tmpInv (Suspect_PK)
	INSERT INTO #tmpInv SELECT DISTINCT SII.Invoice_PK,tSID.Suspect_PK FROM tblSuspectInvoiceInfo SII INNER JOIN tblSuspectInvoiceDetail tSID ON SII.Invoice_PK = tSID.Invoice_PK WHERE IsPaid=1
	INSERT INTO #tmpInv SELECT DISTINCT SII.Invoice_PK,SII.Suspect_PK FROM tblSuspectInvoiceInfo SII 
		LEFT JOIN tblSuspectInvoiceDetail tSID ON SII.Invoice_PK = tSID.Invoice_PK 
		LEFT JOIN #tmpInv Inv ON SII.Suspect_PK = Inv.Suspect_PK
		WHERE tSID.Invoice_PK IS NULL AND Inv.Suspect_PK IS NULL


	SELECT ROW_NUMBER() OVER(ORDER BY SII.dtInsert) AS RowNumber
			--,S.Project_PK,S.Provider_PK,S.Suspect_PK,P.ProviderOffice_PK
			,SII.InvoiceNumber,SII.InvoiceAmount,SII.dtInsert [Uploaded Date]
			,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.Member_ID
			,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.Provider_ID
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,CASE 
				WHEN SII.IsApproved=1 THEN 'Approved'
				WHEN SII.IsApproved=0 THEN 'Rejected'
				ELSE 'Pending'
			END [Status]
			,IsNull(SII.IsPaid,0) IsPaid
			--,SII.InvoiceVendor_PK,SII.InvoiceAccountNumber,SII.Check_Transaction_Number,SII.PaymentType_PK,SII.Inv_File,tInv.Invoice_PK
		--INTO #tbl
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
			INNER JOIN #tmpInv tInv ON tInv.Suspect_PK = S.Suspect_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Invoice_PK = tInv.Invoice_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=P.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			AND (@office=0 OR P.ProviderOffice_PK=@office)
			AND (@mid=0 OR P.ProviderOffice_PK IS NOT NULL)
			AND (@invoice='' OR P.ProviderOffice_PK IS NOT NULL)

			AND (@filter_type<>0 OR SII.IsApproved Is NULL) --Pending
			AND (@filter_type<>1 OR SII.IsApproved=0) -- Rejected
			AND (@filter_type<>2 OR SII.IsApproved=1) -- Approved
			AND (@filter_type<>4 OR (SII.IsApproved=1 AND IsNull(IsPaid,0)=0)) -- Approved & Not Paid
			AND (@filter_type<>5 OR (SII.IsApproved=1 AND IsPaid=1)) -- Approved & Paid

			AND (@mid=0 OR M.Member_ID=@MemberID)
			AND (@invoice='' OR SII.InvoiceNumber Like '%'+@invoice+'%')
/*
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
	*/
END
GO
