SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ir_getOffice 0,1,25,'','AD','DESC',0,1,0
CREATE PROCEDURE [dbo].[ir_getOffice] 
	@Project int,
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@filter_type int,
	@user int,
	@mid bigint
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Project=0
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT DISTINCT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@user
	END
	ELSE
		INSERT INTO #tmpProject(Project_PK) VALUES(@Project)		
	-- PROJECT SELECTION

	CREATE TABLE #tmpSearch (ProviderOffice_PK INT)
	IF @mid<>0
	BEGIN
		INSERT INTO #tmpSearch(ProviderOffice_PK)
		SELECT DISTINCT ProviderOffice_PK 
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
		WHERE S.Member_PK=@MID
	END

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode WHEN 'CP' THEN PO.ContactPerson WHEN 'CNU' THEN PO.ContactNumber WHEN 'FN' THEN PO.FaxNumber ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CD' THEN cPO.charts WHEN 'IA' THEN INV.Approved WHEN 'IR' THEN INV.Rejected WHEN 'IR' THEN INV.Pending WHEN 'OS' THEN cPO.office_status WHEN 'PRV' THEN cPO.providers ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CD' THEN cPO.charts WHEN 'IA' THEN INV.Approved WHEN 'IR' THEN INV.Rejected WHEN 'IR' THEN INV.Pending WHEN 'OS' THEN cPO.office_status WHEN 'PRV' THEN cPO.providers ELSE NULL END END DESC --,
		) AS RowNumber
			,cPO.office_status OfficeStatus		
			,cPO.Project_PK,IsNull(PO.ProviderOffice_PK,0) ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,cPO.providers Providers
			,cPO.charts
			,INV.Approved
			,INV.Rejected
			,INV.Pending
		INTO #tbl
		FROM 
			cacheProviderOffice cPO WITH (NOLOCK)
			INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=cPO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			LEFT JOIN #tmpSearch S ON S.ProviderOffice_PK = cPO.ProviderOffice_PK
			CROSS APPLY (SELECT COUNT(*) Invoices,
				SUM(CASE WHEN IsApproved=1 THEN 1 ELSE 0 END) Approved, 
				SUM(CASE WHEN IsApproved=0 THEN 1 ELSE 0 END) Rejected, 
				SUM(CASE WHEN IsApproved IS NULL THEN 1 ELSE 0 END) Pending 
				FROM tblSuspect tS 
					INNER JOIN tblSuspectInvoiceInfo tSII ON tSII.Suspect_PK = tS.Suspect_PK
					INNER JOIN tblProvider tP ON tP.Provider_PK = tS.Provider_PK
					WHERE tP.ProviderOffice_PK = cPO.ProviderOffice_PK AND tS.Project_PK = cPO.Project_PK
				) INV
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			--AND (cPO.office_status=@filter_type OR @filter_type=0)
			AND (@mid=0 OR S.ProviderOffice_PK IS NOT NULL)
			AND Invoices>0

	SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Address,1)) alpha1, UPPER(RIGHT(LEFT(Address,2),1)) alpha2,Count(DISTINCT ProviderOffice_PK) records
		FROM #tbl
		GROUP BY LEFT(Address,1), RIGHT(LEFT(Address,2),1)			
		ORDER BY alpha1, alpha2
/*
SELECT * FROM tblSuspectInvoiceInfo

SELECT TOP 10 S.Suspect_PK,P.* FROm tblProvider P 
	INNER JOIN tblProviderOffice PM ON PM.ProviderOffice_PK = P.ProviderOffice_PK
	INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK
WHERE S.Suspect_PK IN (16,42,45)
*/
	--Totals		
	SELECT		
			SUM(Providers) Providers
			,SUM(Charts) Charts
			,SUM(Approved) Approved
			,SUM(Rejected) Rejected
			,SUM(Pending) Pending
		FROM #tbl
		
	Drop Table #tbl
END
GO
