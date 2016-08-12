SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sr_getProvider 1,1,100,'','AD','DESC',0,5,1,0
CREATE PROCEDURE [dbo].[sr_getProvider] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Office int,
	@filter_type int,
	@user int,
	@pid bigint,
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

	CREATE TABLE #tmpSearch (Provider_PK BIGINT)
	IF @pid<>0
	BEGIN
		INSERT INTO #tmpSearch(Provider_PK)
		SELECT DISTINCT Provider_PK FROM tblSuspect S WHERE S.Provider_PK=@pid
	END
;
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CD' THEN Count(S.Coded_User_PK) WHEN 'CNA' THEN Count(S.CNA_User_PK) WHEN 'SC' THEN Count(S.Scanned_User_PK) WHEN 'CH' THEN Count(S.Member_PK) WHEN 'OS' THEN cPO.office_status ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CD' THEN Count(S.Coded_User_PK) WHEN 'CNA' THEN Count(S.CNA_User_PK) WHEN 'SC' THEN Count(S.Scanned_User_PK) WHEN 'CH' THEN Count(S.Member_PK) WHEN 'OS' THEN cPO.office_status ELSE NULL END END DESC
		) AS RowNumber
			,cPO.office_status OfficeStatus		
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,Count(S.Member_PK) Charts
			,Count(S.Scanned_User_PK) Scanned
			,Count(S.CNA_User_PK) CNA
			,Count(S.Coded_User_PK) Coded
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND IsNull(PM.Lastname+IsNull(', '+PM.Firstname,''),0) Like @Alpha+'%'
			AND (@pid=0 OR tS.Provider_PK IS NOT NULL)
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
			AND (@segment=0 OR M.Segment_PK=@segment)
		GROUP BY S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,''),cPO.office_status
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)) alpha2,Count(DISTINCT P.Provider_PK) records
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = cPO.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@pid=0 OR tS.Provider_PK IS NOT NULL)	
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
			AND (@segment=0 OR M.Segment_PK=@segment)			
		GROUP BY LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1), RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)			
		ORDER BY alpha1, alpha2
		
	--Totals
	SELECT
			Count(S.Member_PK) Charts
			,Count(S.Scanned_User_PK) Scanned
			,Count(S.CNA_User_PK) CNA
			,Count(S.Coded_User_PK) Coded
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@pid=0 OR tS.Provider_PK IS NOT NULL)
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
			AND (@segment=0 OR M.Segment_PK=@segment)
END
GO
