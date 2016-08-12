SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	im_getOffice 0,0,0,'','UO','ASC',9,1,0,0,''
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
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'UO' THEN tSII.dtInsert ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'UO' THEN tSII.dtInsert ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'IN' THEN tSII.InvoiceNumber WHEN 'IA' THEN tSII.InvoiceAmount WHEN 'AD' THEN PO.Address WHEN 'M' THEN M.Lastname WHEN 'P' THEN PM.Lastname ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'IN' THEN tSII.InvoiceNumber WHEN 'IA' THEN tSII.InvoiceAmount WHEN 'AD' THEN PO.Address WHEN 'M' THEN M.Lastname WHEN 'P' THEN PM.Lastname ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AP' THEN tSII.IsApproved WHEN 'PD' THEN IsNull(tSII.IsPaid,0) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AP' THEN tSII.IsApproved WHEN 'PD' THEN IsNull(tSII.IsPaid,0) ELSE NULL END END DESC
		) AS RowNumber
			,S.Project_PK,S.Provider_PK,S.Suspect_PK,P.ProviderOffice_PK
			,tSII.InvoiceNumber,tSII.InvoiceAmount,tSII.dtInsert [Uploaded Date]
			,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.Member_ID
			,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider,PM.Provider_ID
			,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,CASE 
				WHEN IsApproved=1 THEN 'Approved'
				WHEN IsApproved=0 THEN 'Rejected'
				ELSE 'Pending'
			END [Status]
			,IsNull(tSII.IsPaid,0) IsPaid
			,InvoiceVendor_PK,InvoiceAccountNumber,Check_Transaction_Number,PaymentType_PK,Inv_File,Invoice_PK
		INTO #tbl
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
			INNER JOIN tblSuspectInvoiceInfo tSII ON tSII.Suspect_PK = S.Suspect_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=P.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			AND (@office=0 OR P.ProviderOffice_PK=@office)
			AND (@mid=0 OR P.ProviderOffice_PK IS NOT NULL)
			AND (@invoice='' OR P.ProviderOffice_PK IS NOT NULL)

			AND (@filter_type<>0 OR tSII.IsApproved Is NULL) --Pending
			AND (@filter_type<>1 OR tSII.IsApproved=0) -- Rejected
			AND (@filter_type<>2 OR tSII.IsApproved=1) -- Approved
			AND (@filter_type<>4 OR (tSII.IsApproved=1 AND IsNull(IsPaid,0)=0)) -- Approved & Not Paid
			AND (@filter_type<>5 OR (tSII.IsApproved=1 AND IsPaid=1)) -- Approved & Paid

			AND (@mid=0 OR M.Member_ID=@MemberID)
			AND (@invoice='' OR tSII.InvoiceNumber Like '%'+@invoice+'%')

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
