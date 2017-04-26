SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
--	ifax_getOfficeProviderMember @Office=101
Create PROCEDURE [dbo].[ifax_getOfficeProviderMember] 
	@Office bigint
AS
BEGIN
	SELECT DISTINCT PO.Address,ZC.ZipCode,ZC.City,ZC.County,ZC.State,PO.ContactPerson,PO.ContactNumber,PO.FaxNumber
	FROM tblProviderOffice PO
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
	WHERE PO.ProviderOffice_PK = @Office	

	--To List All Members of each Provider
	SELECT DISTINCT P.Provider_PK,PM.Provider_ID [Provider ID],PM.Lastname+', '+PM.FirstName Provider,Count(DISTINCT Suspect_PK) Charts 
	FROM tblProvider P
		INNER JOIN tblSuspect S WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN cacheProviderOffice cPO WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND P.ProviderOffice_PK = cPO.ProviderOffice_PK
	WHERE P.ProviderOffice_PK = @Office	AND S.IsScanned=0 AND S.IsCNA=0 --AND S.Project_PK=@Project
		AND cPO.office_status<=4
	GROUP BY P.Provider_PK,PM.Provider_ID,PM.Lastname+', '+PM.FirstName
	ORDER BY Provider

	SELECT DISTINCT P.Provider_PK, M.Member_ID,M.Lastname+', '+M.FirstName Member,M.DOB,Suspect_PK, [dbo].[tmi_udf_GetMemberProviderDOSs](M.Member_PK,PM.Provider_ID) DOSs
		,M.Ref_Number [Patient Reference #]
	FROM tblProvider P 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		LEFT JOIN cacheProviderOffice cPO WITH (NOLOCK) ON S.Project_PK = cPO.Project_PK AND P.ProviderOffice_PK = cPO.ProviderOffice_PK
	WHERE P.ProviderOffice_PK = @Office	AND S.IsScanned=0 AND S.IsCNA=0 --AND S.Project_PK=@Project
		AND cPO.office_status<=4
	ORDER BY P.Provider_PK,Member
	
	SELECT MIN(Sch_Start) Sch_Start FROM tblProviderOfficeSchedule 
		WHERE Sch_Start>GetDate()
		AND ProviderOffice_PK = @Office	--AND Project_PK=@Project	
END
GO
