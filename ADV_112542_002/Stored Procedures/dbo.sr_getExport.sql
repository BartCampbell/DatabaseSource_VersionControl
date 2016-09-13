SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report Summary for Dashboad
-- =============================================
/* Sample Executions
sr_getExport 0,0,'1,7,8,9'
PrepareCacheProviderOffice
*/
CREATE PROCEDURE [dbo].[sr_getExport]
	@Project int,
	@IsValidation bit,
	@allowed_projects varchar(500)
AS
BEGIN	
	SELECT TOP 0 1000 Proj_PK INTO #tmpProj
	IF @Project<>0
		SET @allowed_projects = CAST(@Project AS VARCHAR)
	EXEC ('INSERT INTO #tmpProj SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+ @allowed_projects +')');

	SELECT M.ChaseID,M.Member_ID,M.Lastname+ISNULL(', '+M.Firstname,'') MemberName 
		,CAST(IsScanned AS SmallInt) [Scanned],CAST(Scanned_Date AS VARCHAR) [Scanned Date]
		,CAST(IsCoded AS SmallInt) [Coded],CAST(Coded_Date AS VARCHAR) [Coded Date]
		,CAST(IsCNA AS SmallInt) [CNA],CAST(CNA_Date AS VARCHAR) [CNA Date]
		,PM.Provider_ID,PM.Lastname+ISNULL(', '+PM.Firstname,'') ProviderName
		,PO.[Address] [Office Address],ZC.City,ZC.ZipCode,ZC.State
		,CASE office_status 
			WHEN 4 THEN 'Contacted'
			WHEN 3 THEN 'Scheduled'
			WHEN 2 THEN 'Scanned'
			WHEN 1 THEN 'Coded'
			ELSE 'Not Conctacted'
		END [Office Status]
	FROM tblSuspect S
		INNER JOIN tblMember M ON M.Member_PK = S.Member_PK
		INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		INNER JOIN tblProject PR ON PR.Project_PK = S.Project_PK
		INNER JOIN #tmpProj tPR ON PR.Project_PK = tPR.Proj_PK
		LEFT JOIN tblProviderOffice PO ON PO.ProviderOffice_PK = P.ProviderOffice_PK
		LEFT JOIN cacheProviderOffice cPO ON cPO.ProviderOffice_PK = PO.ProviderOffice_PK AND cPO.Project_PK = S.Project_PK
		LEFT JOIN tblZipCode ZC ON ZC.ZipCode_PK = PO.ZipCode_PK
END
GO
