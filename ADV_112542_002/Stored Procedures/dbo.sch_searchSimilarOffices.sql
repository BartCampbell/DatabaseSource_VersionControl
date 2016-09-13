SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	sch_searchSimilarOffices 7,1
CREATE PROCEDURE [dbo].[sch_searchSimilarOffices] 
	@OFFICE BIGINT,
	@user int
AS
BEGIN
	-- PROJECT SELECTION
	CREATE TABLE #tmpProject (Project_PK INT)

	IF Exists (SELECT * FROM tblUser WHERE IsAdmin=1 AND User_PK=@user)	--For Admins
		INSERT INTO #tmpProject(Project_PK)
		SELECT Project_PK FROM tblProject P WHERE P.IsRetrospective=1
	ELSE
		INSERT INTO #tmpProject(Project_PK)
		SELECT P.Project_PK FROM tblProject P LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
		WHERE P.IsRetrospective=1 AND UP.User_PK=@user
	
	--Office can merge
	SELECT LEFT(PO.Address,5)+'%',cPO.Project_PK,cPO.ProviderOffice_PK,IsNull(PO.GroupName+' ','')+PO.Address [Address],PO.ZipCode_PK,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber,PO.Email_Address,PO.EMR_Type
			,cPO.Providers
			,cPO.Charts
			,CASE WHEN cPO.extracted_count+cPO.cna_count>=cPO.Charts THEN 9999 ELSE DATEDIFF(day,GetDate(),follow_up) END followup_days
			,schedule_type,cPO.extracted_count extracted,cPO.coded_count coded,cPO.cna_count cna
			,cPO.office_status OfficeStatus
		FROM 
			cacheProviderOffice cPO WITH (NOLOCK)
			INNER JOIN #tmpProject P ON P.Project_PK = cPO.Project_PK
			INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON cPO.ProviderOffice_PK=PO.ProviderOffice_PK
			--INNER JOIN tblProviderOffice PO2 WITH (NOLOCK) ON PO2.Address LIKE LEFT(PO.Address,5)+'%'
			INNER JOIN tblProviderOffice PO2 WITH (NOLOCK) ON (Replace(Replace(Replace(Replace(PO2.ContactNumber,' ',''),'-',''),')',''),'(','') LIKE Replace(Replace(Replace(Replace(PO.ContactNumber,' ',''),'-',''),')',''),'(','')
				OR (PO2.GroupName = PO.GroupName AND IsNull(PO2.GroupName,'') NOT LIKE ''))
				AND PO2.ProviderOffice_PK = @OFFICE AND PO.ProviderOffice_PK <> @OFFICE

	--Linked Office
	SELECT tPO.Providers,tPO.Charts, tPO.Charts-tPO.extracted_count-tPO.cna_count Remaining,dtLastContact LastContact,follow_up follow_up,tPO.office_status OfficeStatus,P.Project_Name,P.ProjectGroup
	FROM cacheProviderOffice tPO WITH (NOLOCK) 
	INNER JOIN tblProject P ON P.Project_PK = tPO.Project_PK 
	WHERE tPO.ProviderOffice_PK = @OFFICE
	ORDER BY P.Project_Name,P.ProjectGroup
END
GO
