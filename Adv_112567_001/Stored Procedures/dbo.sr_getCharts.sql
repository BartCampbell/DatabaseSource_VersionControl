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
	@bucket int,
	@followup_bucket int,
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
			,CASE WHEN S.Scanned_Date IS NULL THEN S.IsCNA ELSE 0 END CNA,CASE WHEN S.Scanned_Date IS NULL THEN S.CNA_Date ELSE NULL END CNA_Date
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
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND PO.ProviderOffice_PK = cPO.ProviderOffice_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@segment=0 OR M.Segment_PK=@segment)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND IsNull(M.Lastname+IsNull(', '+M.Firstname,''),0) Like @Alpha+'%'
			AND (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
			AND (@followup_bucket=0 OR follow_up<=GetDate())
	)
				
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber;

	SELECT UPPER(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(M.Lastname+IsNull(', '+M.Firstname,''),2),1)) alpha2,Count(DISTINCT S.Suspect_PK) records
		FROM tblProvider P WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND PO.ProviderOffice_PK = cPO.ProviderOffice_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
		AND (@Provider=0 OR P.Provider_PK=@Provider)
		AND (@segment=0 OR M.Segment_PK=@segment)
		AND (@mid=0 OR S.Member_PK=@mid)
		AND (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
		AND (@followup_bucket=0 OR follow_up<=GetDate())
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
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND PO.ProviderOffice_PK = cPO.ProviderOffice_PK
						
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@segment=0 OR M.Segment_PK=@segment)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
			AND (@followup_bucket=0 OR follow_up<=GetDate())
END
GO
