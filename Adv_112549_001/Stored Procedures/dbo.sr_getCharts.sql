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
			,CAST(S.IsScanned AS TINYINT) Scanned,Scanned_Date
			,CASE WHEN S.Scanned_Date IS NULL THEN CAST(S.IsCNA AS TINYINT) ELSE 0 END CNA
			,CASE WHEN S.Scanned_Date IS NULL THEN S.CNA_Date ELSE NULL END CNA_Date
			--,IsNull(IsNull(SN.Note_Text+' by Scan Tech',OCNA.CNA_Note+' by Scheduler'),'') [CNA Note]
			--,IsNull(IsNull(' by Scan Tech',OCNA.CNA_Note+' by Scheduler'),'') [CNA Note]
			,'' [CNA Note]
			,CAST(S.IsCoded AS TINYINT) Coded,Coded_Date
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider	
			INTO #tbl		
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK
			--INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@segment=0 OR M.Segment_PK=@segment)
			AND (@mid=0 OR S.Member_PK=@mid)
			AND IsNull(M.Lastname+IsNull(', '+M.Firstname,''),0) Like @Alpha+'%'
			--AND (@bucket=0 OR PO.ProviderOfficeBucket_PK=@bucket)
			--AND (@followup_bucket=0 OR follow_up<=GetDate())

	SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber;

	SELECT UPPER(LEFT(Member,1)) alpha1, UPPER(RIGHT(LEFT(Member,2),1)) alpha2,Count(DISTINCT Suspect_PK) records
		FROM #tbl
		GROUP BY UPPER(LEFT(Member,1)), UPPER(RIGHT(LEFT(Member,2),1))		
		ORDER BY alpha1, alpha2;
			
	--Total
	SELECT 
			SUM(Scanned) Scanned
			,SUM(CNA) CNA
			,SUM(Coded) Coded
		FROM #tbl
END
GO
