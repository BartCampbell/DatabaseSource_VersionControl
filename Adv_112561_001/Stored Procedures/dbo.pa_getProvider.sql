SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	pa_getProvider 0,0,1,25,'','AD','DESC',0,0,0,1
CREATE PROCEDURE [dbo].[pa_getProvider] 
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@Page int,
	@PageSize int,	
	@Alpha Varchar(2),
	@Sort Varchar(150),
	@Order Varchar(4),
	@Provider int,
	@filter int,
	@status_filter int,
	@User int
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

	With tbl AS(
	SELECT ROW_NUMBER() OVER(
		ORDER BY 		
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'ZC' THEN ZC.Zipcode WHEN 'Asgn' THEN IsNull(PA.Fullname,'') ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'P' THEN PM.Lastname+IsNull(', '+PM.Firstname,'') WHEN 'PID' THEN PM.Provider_ID WHEN 'AD' THEN PO.Address WHEN 'CT' THEN ZC.City WHEN 'ZC' THEN ZC.Zipcode WHEN 'Asgn' THEN IsNull(PA.Fullname,'') ELSE NULL END END DESC,
			CASE WHEN @Order='ASC'  THEN CASE @SORT WHEN 'RM' THEN COUNT(Scanned_User_PK) - COUNT(Coded_User_PK) WHEN 'CD' THEN COUNT(Coded_User_PK) WHEN 'CNA' THEN 0 WHEN 'SC' THEN COUNT(Scanned_User_PK) WHEN 'CH' THEN COUNT(*) WHEN 'OS' THEN cS.office_status ELSE NULL END END ASC,
			CASE WHEN @Order='DESC' THEN CASE @SORT WHEN 'RM' THEN COUNT(Scanned_User_PK) - COUNT(Coded_User_PK) WHEN 'CD' THEN COUNT(Coded_User_PK) WHEN 'CNA' THEN 0 WHEN 'SC' THEN COUNT(Scanned_User_PK) WHEN 'CH' THEN COUNT(*) WHEN 'OS' THEN cS.office_status ELSE NULL END END DESC
		) AS RowNumber
			,cS.office_status OfficeStatus		
			,cS.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
			,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode
			,COUNT(*) Charts
			,COUNT(Scanned_User_PK) Scanned			
			,0 CNA
			,COUNT(Coded_User_PK) Coded
			,SUM(CASE WHEN Isnull(IsCoded,0)=0 AND IsScanned=1 THEN 1 ELSE 0 END) Remaining
			,IsNull(PA.Fullname,'') AssignedTo
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN cacheProviderOffice cS WITH (NOLOCK) ON P.ProviderOffice_PK=cS.ProviderOffice_PK 
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK=PO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			OUTER APPLY (SELECT TOP 1 tU.Lastname+', '+tU.Firstname Fullname FROM tblProviderAssignment tP WITH (NOLOCK) INNER JOIN tblUser tU WITH (NOLOCK) ON tU.User_PK=tP.User_PK WHERE tP.Project_PK=cS.Project_PK AND tP.Provider_PK=P.Provider_PK) PA			
		WHERE (@Provider=0 OR P.Provider_PK=@Provider)
			AND PM.Lastname+IsNull(', '+PM.Firstname,'') Like @Alpha+'%'
			AND (
					@filter=0 
				OR (@filter=1 AND PA.Fullname IS NOT NULL) 
				OR (@filter=2 AND PA.Fullname IS NULL) 
				)
			AND (cS.office_status = @status_filter	OR @status_filter=0)
		GROUP BY cS.office_status		
			,cS.Project_PK,P.Provider_PK,PM.Provider_ID,PM.Lastname,PM.Firstname
			,PO.Address,ZC.City,ZC.County,ZC.State,ZC.Zipcode,PA.Fullname
	)
	
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber

	SELECT UPPER(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1)) alpha1, UPPER(RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)) alpha2,Count(DISTINCT P.Provider_PK) records
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN cacheProviderOffice cS WITH (NOLOCK) ON P.ProviderOffice_PK=cS.ProviderOffice_PK 
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK=PO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			OUTER APPLY (SELECT TOP 1 tU.Lastname+', '+tU.Firstname Fullname FROM tblProviderAssignment tP WITH (NOLOCK) INNER JOIN tblUser tU WITH (NOLOCK) ON tU.User_PK=tP.User_PK WHERE tP.Project_PK=S.Project_PK AND tP.Provider_PK=P.Provider_PK) PA
		WHERE (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@filter=0 
				OR (@filter=1 AND PA.Fullname IS NOT NULL) 
				OR (@filter=2 AND PA.Fullname IS NULL) )		
			AND (cS.office_status = @status_filter	OR @status_filter=0)
		GROUP BY LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),1), RIGHT(LEFT(PM.Lastname+IsNull(', '+PM.Firstname,''),2),1)			
		ORDER BY alpha1, alpha2
		
	--Totals
	SELECT
			COUNT(*) Charts
			,COUNT(Scanned_User_PK) Scanned
			,0 CNA
			,COUNT(Coded_User_PK) Coded
			,SUM(CASE WHEN Isnull(IsCoded,0)=0 AND IsScanned=1 THEN 1 ELSE 0 END) Remaining
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN #tmpProject Pr WITH (NOLOCK) ON Pr.Project_PK = S.Project_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN cacheProviderOffice cS WITH (NOLOCK) ON P.ProviderOffice_PK=cS.ProviderOffice_PK 
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON P.ProviderOffice_PK=PO.ProviderOffice_PK 
			LEFT JOIN tblZipcode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			OUTER APPLY (SELECT TOP 1 tU.Lastname+', '+tU.Firstname Fullname FROM tblProviderAssignment tP WITH (NOLOCK) INNER JOIN tblUser tU WITH (NOLOCK) ON tU.User_PK=tP.User_PK WHERE tP.Project_PK=cS.Project_PK AND tP.Provider_PK=P.Provider_PK) PA			
		WHERE (@Provider=0 OR P.Provider_PK=@Provider)
			AND IsNull(PM.Lastname+IsNull(', '+PM.Firstname,''),0) Like @Alpha+'%'
			AND (
					@filter=0 
				OR (@filter=1 AND PA.Fullname IS NOT NULL) 
				OR (@filter=2 AND PA.Fullname IS NULL) 
				)
			AND (cS.office_status = @status_filter	OR @status_filter=0)
END
GO
