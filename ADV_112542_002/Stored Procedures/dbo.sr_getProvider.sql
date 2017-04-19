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
	@bucket int,
	@followup_bucket int,
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

	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'CD' THEN COUNT(DISTINCT S.Suspect_PK) WHEN 'SC' THEN COUNT(DISTINCT CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) WHEN 'CH' THEN COUNT(DISTINCT CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) WHEN 'OS' THEN CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END WHEN 'PRV' THEN COUNT(DISTINCT S.Provider_PK) ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'CD' THEN COUNT(DISTINCT S.Suspect_PK) WHEN 'SC' THEN COUNT(DISTINCT CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) WHEN 'CH' THEN COUNT(DISTINCT CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) WHEN 'OS' THEN CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END WHEN 'PRV' THEN COUNT(DISTINCT S.Provider_PK) ELSE NULL END END DESC --,
		) AS RowNumber
			,CASE WHEN SUM(CASE WHEN S.IsScanned=0 AND S.IsCNA=0 THEN 1 ELSE 0 END)=0 THEN 6 ELSE MAX(CS.ProviderOfficeBucket_PK) END OfficeStatus		
			,0 Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,COUNT(DISTINCT S.Suspect_PK) Charts
			,COUNT(DISTINCT CASE WHEN S.IsScanned=1 THEN S.Suspect_PK ELSE NULL END) Scanned
			,COUNT(DISTINCT CASE WHEN S.IsScanned=0 AND S.IsCNA=1 THEN S.Suspect_PK ELSE NULL END) CNA
			,COUNT(DISTINCT CASE WHEN S.IsCoded=1 THEN S.Suspect_PK ELSE NULL END) Coded
		INTO #tbl
		FROM tblProviderMaster PM WITH (NOLOCK)
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.ProviderMaster_PK = PM.ProviderMaster_PK
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblChaseStatus CS WITH (NOLOCK) ON CS.ChaseStatus_PK = S.ChaseStatus_PK
			INNER JOIN #tmpProject FP ON FP.Project_PK = S.Project_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND IsNull(PM.Lastname+IsNull(', '+PM.Firstname,''),0) Like @Alpha+'%'
			AND (@pid=0 OR P.Provider_PK=@pid) 
			AND (@segment=0 OR M.Segment_PK=@segment)
		GROUP BY S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'')--,PO.ProviderOfficeBucket_PK

	
	SELECT * FROM #tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(Provider+IsNull(', '+Provider,''),1)) alpha1, UPPER(RIGHT(LEFT(Provider+IsNull(', '+Provider,''),2),1)) alpha2,Count(DISTINCT Provider_PK) records
		FROM #tbl			
		GROUP BY LEFT(Provider+IsNull(', '+Provider,''),1), RIGHT(LEFT(Provider+IsNull(', '+Provider,''),2),1)			
		ORDER BY alpha1, alpha2
		
	--Totals
	SELECT
			SUM(Charts) Charts
			,SUM(Scanned) Scanned
			,SUM(CNA) CNA
			,SUM(Coded) Coded
		FROM #tbl
END
GO
