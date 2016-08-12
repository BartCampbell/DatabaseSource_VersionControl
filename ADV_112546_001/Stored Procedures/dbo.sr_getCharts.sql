SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sr_getCharts 0,1,225,'','AD','DESC',0,0,5,1,0,0
CREATE PROCEDURE [dbo].[sr_getCharts] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Office int,
	@Provider int,
	@filter_type int,
	@user int,
	@mid bigint,
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

	--SELECT MAX(CN.ContactNote_Text) CNA_Note,CNO.Project_PK,CNO.Office_PK INTO #OfficeCNA FROM tblContactNote CN WITH (NOLOCK) INNER JOIN tblContactNotesOffice CNO WITH (NOLOCK) ON CNO.ContactNote_PK = CN.ContactNote_PK INNER JOIN #tmpProject P ON P.Project_PK = CNO.Project_PK WHERE CN.IsCNA=1 GROUP BY CNO.Project_PK,CNO.Office_PK
;
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'MID' THEN M.Member_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'M' THEN M.Lastname+IsNull(', '+M.Firstname,'') WHEN 'MID' THEN M.Member_ID WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CD' THEN S.Coded_User_PK WHEN 'CNA' THEN S.CNA_User_PK WHEN 'SC' THEN S.Scanned_User_PK ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CD' THEN S.Coded_User_PK WHEN 'CNA' THEN S.CNA_User_PK WHEN 'SC' THEN S.Scanned_User_PK ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'DOB' THEN M.DOB ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'DOB' THEN M.DOB ELSE NULL END END DESC
		) AS RowNumber
			--,cPO.office_status OfficeStatus
			,S.Suspect_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,S.IsScanned Scanned,Scanned_Date
			,S.IsCNA CNA,CNA_Date
			--,IsNull(IsNull(SN.Note_Text+' by Scan Tech',OCNA.CNA_Note+' by Scheduler'),'') [CNA Note]
			--,IsNull(IsNull(' by Scan Tech',OCNA.CNA_Note+' by Scheduler'),'') [CNA Note]
			,'' [CNA Note]
			,S.IsCoded Coded,Coded_Date
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			--LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
			--LEFT JOIN tblScanningNotes SN WITH (NOLOCK) ON SSN.ScanningNote_PK = SN.ScanningNote_PK
			--LEFT JOIN #OfficeCNA OCNA WITH (NOLOCK) ON cPO.Project_PK = OCNA.Project_PK AND cPO.ProviderOffice_PK = OCNA.Office_PK
			
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@segment=0 OR M.Segment_PK=@segment)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND IsNull(M.Lastname+IsNull(', '+M.Firstname,''),0) Like @Alpha+'%'
			AND (@filter_type=0
				OR (@filter_type=1 AND office_status IN (1,2,3,4)) --Offices Contacted
				OR (@filter_type=2 AND office_status IN (1,2,3,4) AND charts=cna_count)	--Offices Not Available
				OR (@filter_type=3 AND office_status=4 AND charts<>cna_count)	--Offices Not Scheduled
				OR (@filter_type=4 AND office_status IN (1,2,3)) --Offices Scheduled
				OR (@filter_type=5 AND office_status=3 AND charts=cna_count) --Offices Not Available
				OR (@filter_type=6 AND office_status=3 AND charts<>cna_count) --Offices Not Scanned
				OR (@filter_type=7 AND office_status IN (1,2)) --Offices Scanned
				OR (@filter_type=8 AND office_status=2) --Offices Not Coded
					OR (@filter_type=21 AND office_status=2 AND S.IsCNA=1)								-- Charts Not Available		21
					OR (@filter_type=22 AND office_status=2 AND IsScanned=1)							-- Charts Scanned			22
					OR (@filter_type=23 AND office_status=2 AND IsScanned=0 AND S.IsCNA=0)				-- Charts Remaining			23
				OR (@filter_type=9 AND office_status=1) --Offices Coded
					OR (@filter_type=24 AND office_status=1 AND IsCoded=1)								-- Charts Coded				24
					OR (@filter_type=25 AND office_status=1 AND S.IsCNA=1)									-- Charts Not Available		25
					OR (@filter_type=26 AND office_status=1 AND IsCoded=1)								-- Charts Scanned			26
					OR (@filter_type=27 AND office_status=1 AND IsScanned=0 AND S.IsCNA=0 AND IsCoded=0)	-- Charts Remaining			27
				 OR (@filter_type=10 AND office_status=5) --Offices Not Contacted
				 OR (@filter_type=11 AND office_status=5 AND charts=cna_count) --Offices Not Contacted
				 OR (@filter_type=12 AND office_status=5 AND charts<>cna_count) --Offices Not Contacted
			)
	)
				
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber;

	SELECT UPPER(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),2),1)) alpha2,Count(DISTINCT S.Suspect_PK) records
		FROM tblProvider P WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
		AND (@Provider=0 OR P.Provider_PK=@Provider)
		AND (@segment=0 OR M.Segment_PK=@segment)
		AND (@mid=0 OR S.Member_PK=@mid)
			AND (@filter_type=0
				OR (@filter_type=1 AND office_status IN (1,2,3,4)) --Offices Contacted
				OR (@filter_type=2 AND office_status IN (1,2,3,4) AND charts=cna_count)	--Offices Not Available
				OR (@filter_type=3 AND office_status=4 AND charts<>cna_count)	--Offices Not Scheduled
				OR (@filter_type=4 AND office_status IN (1,2,3)) --Offices Scheduled
				OR (@filter_type=5 AND office_status=3 AND charts=cna_count) --Offices Not Available
				OR (@filter_type=6 AND office_status=3 AND charts<>cna_count) --Offices Not Scanned
				OR (@filter_type=7 AND office_status IN (1,2)) --Offices Scanned
				OR (@filter_type=8 AND office_status=2) --Offices Not Coded
					OR (@filter_type=21 AND office_status=2 AND IsCNA=1)								-- Charts Not Available		21
					OR (@filter_type=22 AND office_status=2 AND IsScanned=1)							-- Charts Scanned			22
					OR (@filter_type=23 AND office_status=2 AND IsScanned=0 AND IsCNA=0)				-- Charts Remaining			23
				OR (@filter_type=9 AND office_status=1) --Offices Coded
					OR (@filter_type=24 AND office_status=1 AND IsCoded=1)								-- Charts Coded				24
					OR (@filter_type=25 AND office_status=1 AND IsCNA=1)									-- Charts Not Available		25
					OR (@filter_type=26 AND office_status=1 AND IsCoded=1)								-- Charts Scanned			26
					OR (@filter_type=27 AND office_status=1 AND IsScanned=0 AND IsCNA=0 AND IsCoded=0)	-- Charts Remaining			27
				 OR (@filter_type=10 AND office_status=5) --Offices Not Contacted
				 OR (@filter_type=11 AND office_status=5 AND charts=cna_count) --Offices Not Contacted
				 OR (@filter_type=12 AND office_status=5 AND charts<>cna_count) --Offices Not Contacted
			)
		GROUP BY LEFT(M.Lastname+IsNull(', '+M.Firstname,''),1), RIGHT(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),2),1)			
		ORDER BY alpha1, alpha2;
			
	--Total
	SELECT 
			COUNT(Scanned_Date) Scanned
			,COUNT(CNA_Date) CNA
			,COUNT(Coded_Date) Coded
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK	
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@segment=0 OR M.Segment_PK=@segment)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND (@filter_type=0
				OR (@filter_type=1 AND office_status IN (1,2,3,4)) --Offices Contacted
				OR (@filter_type=2 AND office_status IN (1,2,3,4) AND charts=cna_count)	--Offices Not Available
				OR (@filter_type=3 AND office_status=4 AND charts<>cna_count)	--Offices Not Scheduled
				OR (@filter_type=4 AND office_status IN (1,2,3)) --Offices Scheduled
				OR (@filter_type=5 AND office_status=3 AND charts=cna_count)		--Offices Not Available
				OR (@filter_type=6 AND office_status=3 AND charts<>cna_count)		--Offices Not Scanned
				OR (@filter_type=7 AND office_status IN (1,2)) --Offices Scanned
				OR (@filter_type=8 AND office_status=2) --Offices Not Coded
					OR (@filter_type=21 AND office_status=2 AND IsCNA=1)								-- Charts Not Available		21
					OR (@filter_type=22 AND office_status=2 AND IsScanned=1)							-- Charts Scanned			22
					OR (@filter_type=23 AND office_status=2 AND IsScanned=0 AND IsCNA=0)				-- Charts Remaining			23
				OR (@filter_type=9 AND office_status=1) --Offices Coded
					OR (@filter_type=24 AND office_status=1 AND IsCoded=1)								-- Charts Coded				24
					OR (@filter_type=25 AND office_status=1 AND IsCNA=1)									-- Charts Not Available		25
					OR (@filter_type=26 AND office_status=1 AND IsCoded=1)								-- Charts Scanned			26
					OR (@filter_type=27 AND office_status=1 AND IsScanned=0 AND IsCNA=0 AND IsCoded=0)	-- Charts Remaining			27
				 OR (@filter_type=10 AND office_status=5) --Offices Not Contacted
				 OR (@filter_type=11 AND office_status=5 AND charts=cna_count) --Offices Not Contacted
				 OR (@filter_type=12 AND office_status=5 AND charts<>cna_count) --Offices Not Contacted
			)
END
GO
