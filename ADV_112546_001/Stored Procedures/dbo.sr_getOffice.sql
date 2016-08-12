SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	sr_getOffice 0,0,1,25,'','AD','DESC',0,1,0,0
CREATE PROCEDURE [dbo].[sr_getOffice] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@filter_type int,
	@user int,
	@oid bigint,
	@segment int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)
	IF @Projects='0'
	BEGIN
		IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@User)	--For Admins
			INSERT INTO #tmpProject(Project_PK)
			SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1 AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
		ELSE
			INSERT INTO #tmpProject(Project_PK)
			SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
			WHERE P.IsRetrospective=1 AND UP.User_PK=@User AND (@ProjectGroup=0 OR ProjectGroup_PK=@ProjectGroup)
	END
	ELSE
		EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');	
	-- PROJECT SELECTION

	CREATE TABLE #tmpSearch (ProviderOffice_PK INT)
	IF (@oid<>0 OR @segment<>0)
	BEGIN
		INSERT INTO #tmpSearch(ProviderOffice_PK)
		SELECT DISTINCT ProviderOffice_PK 
		FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
		WHERE (@OID=0 OR P.Provider_PK=@OID) AND (@segment=0 OR M.Segment_PK=@segment)
	END

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'CN' THEN ZC.County WHEN 'ST' THEN ZC.State WHEN 'ZC' THEN ZC.Zipcode ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CD' THEN SUM(cPO.charts) WHEN 'SC' THEN SUM(cPO.extracted_count) WHEN 'CH' THEN SUM(cPO.coded_count)  WHEN 'OS' THEN MIN(cPO.office_status) WHEN 'PRV' THEN SUM(cPO.providers) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CD' THEN SUM(cPO.charts) WHEN 'SC' THEN SUM(cPO.extracted_count) WHEN 'CH' THEN SUM(cPO.coded_count)  WHEN 'OS' THEN MIN(cPO.office_status) WHEN 'PRV' THEN SUM(cPO.providers) ELSE NULL END END DESC --,
		) AS RowNumber
			,MIN(cPO.office_status) OfficeStatus		
			,0 Project_PK,IsNull(PO.ProviderOffice_PK,0) ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
			,SUM(cPO.providers) Providers
			,SUM(cPO.charts) charts
			,SUM(cPO.extracted_count) Scanned
			,SUM(cna_count) CNA
			,SUM(cPO.coded_count) Coded
		INTO #tbl
		FROM 
			cacheProviderOffice cPO WITH (NOLOCK)
			INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK=cPO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK	
			LEFT JOIN #tmpSearch S ON S.ProviderOffice_PK = cPO.ProviderOffice_PK
		WHERE IsNull(PO.Address,0) Like @Alpha+'%'
			AND (@filter_type=0
				OR (@filter_type=1 AND office_status IN (1,2,3,4)) --Offices Contacted
				OR (@filter_type=2 AND office_status IN (1,2,3,4) AND charts=cna_count)	--Offices Not Available
				OR (@filter_type=3 AND office_status=4 AND charts<>cna_count)	--Offices Not Scheduled
				OR (@filter_type=4 AND office_status IN (1,2,3)) --Offices Scheduled
				OR (@filter_type=5 AND office_status=3 AND charts=cna_count) --Offices Not Available
				OR (@filter_type=6 AND office_status=3 AND charts<>cna_count) --Offices Not Scanned
				OR (@filter_type=7 AND office_status IN (1,2)) --Offices Scanned
				OR (@filter_type=8 AND office_status IN (2)) --Offices Not Coded
				 --Charts Not Available		21
				 --Charts Scanned			22
				 --Charts Remaining			23
				 OR (@filter_type=9 AND office_status IN (1)) --Offices Coded
				 --Charts Coded				24
				 --Charts Not Available		25
				 --Charts Scanned			26
				 --Charts Remaining			27
				 OR (@filter_type=10 AND office_status=5) --Offices Not Contacted
				 OR (@filter_type=11 AND office_status=5 AND charts=cna_count) --Offices Not Contacted
				 OR (@filter_type=12 AND office_status=5 AND charts<>cna_count) --Offices Not Contacted
			)
			AND (@oid=0 OR S.ProviderOffice_PK IS NOT NULL)
			AND (@segment=0 OR S.ProviderOffice_PK IS NOT NULL)
		GROUP BY PO.ProviderOffice_PK,PO.Address,ZC.City,ZC.County,ZC.State,PO.ZipCode_PK,ZC.Zipcode
	
	SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Address,1)) alpha1, UPPER(RIGHT(LEFT(Address,2),1)) alpha2,Count(DISTINCT ProviderOffice_PK) records
		FROM #tbl
		GROUP BY LEFT(Address,1), RIGHT(LEFT(Address,2),1)			
		ORDER BY alpha1, alpha2

	--Totals		
	SELECT		
			SUM(Providers) Providers
			,SUM(Charts) Charts
			,SUM(Scanned) Scanned
			,SUM(CNA) CNA
			,SUM(Coded) Coded
		FROM #tbl
		
	Drop Table #tbl
END
GO
