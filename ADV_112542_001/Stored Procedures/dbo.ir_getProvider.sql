SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ir_getProvider 1,1,100,'','AD','DESC',0,0,1,0
CREATE PROCEDURE [dbo].[ir_getProvider] 
	@Project int,
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Office int,
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

	CREATE TABLE #tmpSearch (Provider_PK BIGINT)
	IF @mid<>0
	BEGIN
		INSERT INTO #tmpSearch(Provider_PK)
		SELECT DISTINCT Provider_PK FROM tblSuspect S WHERE S.Member_PK=@MID
	END
;
	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'IA' THEN SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) WHEN 'IR' THEN SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) WHEN 'IP' THEN SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) WHEN 'CH' THEN Count(S.Member_PK) WHEN 'OS' THEN cPO.office_status ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'IA' THEN SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) WHEN 'IR' THEN SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) WHEN 'IP' THEN SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) WHEN 'CH' THEN Count(S.Member_PK) WHEN 'OS' THEN cPO.office_status ELSE NULL END END DESC
		) AS RowNumber
			,cPO.office_status OfficeStatus		
			,S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,Count(S.Member_PK) Charts
			,SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND IsNull(PM.Lastname+IsNull(', '+PM.Firstname,''),0) Like @Alpha+'%'
			--AND (cPO.office_status=@filter_type OR @filter_type=0)
			AND (@mid=0 OR tS.Provider_PK IS NOT NULL)
		GROUP BY S.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,''),cPO.office_status
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber
	
	SELECT UPPER(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)) alpha2,Count(DISTINCT P.Provider_PK) records
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			--AND (cPO.office_status=@filter_type OR @filter_type=0)	
			AND (@mid=0 OR tS.Provider_PK IS NOT NULL)		
		GROUP BY LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1), RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)			
		ORDER BY alpha1, alpha2
		
	--Totals
	SELECT
			Count(S.Member_PK) Charts
			,SUM(CASE WHEN SII.IsApproved=1 THEN 1 ELSE 0 END) Approved
			,SUM(CASE WHEN SII.IsApproved=0 THEN 1 ELSE 0 END) Rejected
			,SUM(CASE WHEN SII.IsApproved IS NULL THEN 1 ELSE 0 END) Pending
		FROM 
			tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblSuspectInvoiceInfo SII WITH (NOLOCK) ON SII.Suspect_PK = S.Suspect_PK
			INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON cPO.ProviderOffice_PK = P.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
			LEFT JOIN #tmpSearch tS ON tS.Provider_PK = P.Provider_PK
		WHERE --(@Office=0 OR P.ProviderOffice_PK=@Office)
			--AND 
			(@mid=0 OR tS.Provider_PK IS NOT NULL)
			AND (cPO.office_status=@filter_type OR @filter_type=0)
END
GO
