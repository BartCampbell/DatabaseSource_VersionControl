SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	cra_getCharts 0,0,5498,1,1,25,0,0,0
CREATE PROCEDURE [dbo].[cra_getCharts] 
	@Member bigint,
	@Provider bigint,
	@Office bigint,
	@User int,
	@Page int,
	@PageSize int,
	@filter int,
	@Projects varchar(100),
	@ProjectGroup varchar(10),
	@scan_tech int,
	@member_id varchar(25)
AS
BEGIN
	if @Member<>0
		SET @PageSize = 500

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

	;
	With tbl AS(
		SELECT 
			ROW_NUMBER() OVER(ORDER BY IsNull(IsHighPriority,0) DESC,M.Lastname+IsNull(', '+M.Firstname,'') ASC) AS RowNumber
			,S.Suspect_PK,S.Provider_PK,P.ProviderOffice_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
			,PO.Address,ZC.City,ZC.State,ZC.ZipCode

			,S.IsScanned Scanned,S.Scanned_Date,UScanned.Lastname+', '+IsNull(UScanned.Firstname,'') ScannedUser
			,S.IsCNA CNA--,S.CNA_Date,UCNA.Lastname+', '+IsNull(UCNA.Firstname,'') CNAUser
			,SSN.ScanningNote_PK
			,S.IsInvoiced Invoiced
			,S.InvoiceRec_Date
			,S.ChartRec_FaxIn_Date
			,S.ChartRec_MailIn_Date
			,S.ChartRec_InComp_Date
			,USA.Lastname+', '+IsNull(USA.Firstname,'') Assigned_ST, SA.LastUpdated_Date Assigned_Date
			,USch.Lastname+', '+IsNull(USch.Firstname,'') Scheduled_By, POS.Sch_Start Scheduled_On
			,S.IsHighPriority,dbo.tmi_udf_GetMemberProviderDOSs(S.Member_PK,PM.Provider_ID) DOSs
			,0 IncompleteNote_pk,'' Note,IsNull(S.IsInComp_Replied,0) IsInComp_Replied
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			Outer APPLY (SELECT TOP 1 * FROM tblProviderOfficeSchedule X WHERE X.ProviderOffice_PK = PO.ProviderOffice_PK AND X.Project_PK = S.Project_PK) POS
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			LEFT JOIN tblSuspectAssignment SA WITH (NOLOCK) ON SA.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblUser USA WITH (NOLOCK) ON USA.User_PK = SA.User_PK
			--LEFT JOIN tblUser UCNA WITH (NOLOCK) ON UCNA.User_PK = S.CNA_User_PK
			LEFT JOIN tblSuspectScanningNotes SSN WITH (NOLOCK) ON SSN.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblUser UScanned WITH (NOLOCK) ON UScanned.User_PK = S.Scanned_User_PK
			LEFT JOIN tblUser USch WITH (NOLOCK) ON USch.User_PK = POS.LastUpdated_User_PK
			--LEFT JOIN tblSuspectIncompleteNotes SInN WITH (NOLOCK) ON SInN.Suspect_PK = S.Suspect_PK
			--LEFT JOIN tblMember MSearch WITH (NOLOCK) ON MSearch.Member_PK = @Member AND M.Member_ID = MSearch.Member_ID
			
			
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			--AND (@Member=0 OR MSearch.Member_PK IS NOT NULL)
			AND (@Member=0 OR M.Member_PK = @Member)
			AND (@member_id='' OR M.Member_ID=@member_id)
			AND (@filter<>1 OR S.IsHighPriority=1)
			AND (@filter<>2 OR SA.User_PK=@scan_tech)
			AND (@filter<>3 OR (IsNull(S.ChartRec_FaxIn_Date,S.ChartRec_MailIn_Date) IS NOT NULL AND S.Scanned_Date IS NULL))
			AND (@filter<>4 OR S.IsInComp_Replied=1)

	)
	SELECT * FROM tbl WHERE RowNumber>@PageSize*(@Page-1) AND RowNumber<=@PageSize*@Page ORDER BY RowNumber

		SELECT '' alpha1, '' alpha2,Count(DISTINCT S.Suspect_PK) records
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			INNER JOIN #tmpProject Pr ON Pr.Project_PK = S.Project_PK
			LEFT JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
			Outer APPLY (SELECT TOP 1 * FROM tblProviderOfficeSchedule X WHERE X.ProviderOffice_PK = PO.ProviderOffice_PK AND X.Project_PK = S.Project_PK) POS
			LEFT JOIN tblZipCode ZC WITH (NOLOCK) ON ZC.ZipCode_PK = PO.ZipCode_PK
			LEFT JOIN tblSuspectAssignment SA WITH (NOLOCK) ON SA.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblUser USA WITH (NOLOCK) ON USA.User_PK = SA.User_PK
			LEFT JOIN tblUser UCNA WITH (NOLOCK) ON UCNA.User_PK = S.CNA_User_PK
			LEFT JOIN tblUser UScanned WITH (NOLOCK) ON UScanned.User_PK = S.Scanned_User_PK
			LEFT JOIN tblUser USch WITH (NOLOCK) ON USch.User_PK = POS.LastUpdated_User_PK
			
		WHERE (@Office=0 OR P.ProviderOffice_PK=@Office)
			AND (@Provider=0 OR P.Provider_PK=@Provider)
			AND (@Member=0 OR S.Member_PK=@Member)
			AND (@member_id='' OR M.Member_ID=@member_id)
			AND (@filter<>1 OR S.IsHighPriority=1)
			AND (@filter<>2 OR SA.User_PK=@scan_tech)
			AND (@filter<>3 OR (IsNull(S.ChartRec_FaxIn_Date,S.ChartRec_MailIn_Date) IS NOT NULL AND S.Scanned_Date IS NULL))
			AND (@filter<>4 OR S.IsInComp_Replied=1)
END
GO
