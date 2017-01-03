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
CREATE PROCEDURE [dbo].[sr_exportOfficeDrill] 
	@Project int,
	@Office int
AS
BEGIN
	SELECT M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB 
	,CASE WHEN S.IsScanned=1 THEN 'YES' ELSE '' END Scanned 
	,CASE WHEN S.IsCNA=1 THEN 'YES' ELSE '' END CNA 
	,CASE WHEN S.IsCoded=1 THEN 'YES' ELSE '' END Coded 
	,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider 
	FROM tblProvider P WITH (NOLOCK) 
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK 
	 	INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
	 	INNER JOIN tblMember M WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
     WHERE P.ProviderOffice_PK = @Office
		AND (@Project=0 OR S.Project_PK = @Project)
END
GO
