SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-12-2014
-- Description:	RA Coder will use this sp to pull list of providers in a project
-- =============================================
-- qa_scannning_searchMember 'A',1
CREATE PROCEDURE [dbo].[qa_scannning_searchMember] 
	@search varchar(200)
AS
BEGIN
	SELECT DISTINCT TOP 50 M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') MemberName,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') ProviderName,S.Suspect_PK
	FROM tblMember M 
		INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Member_PK = M.Member_PK 
		INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
		INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON P.ProviderMaster_PK = PM.ProviderMaster_PK
	WHERE S.LinkedSuspect_PK IS NULL AND S.IsScanned=1 AND M.Member_ID+' '+M.Lastname+IsNull(', '+M.Firstname,'') LIKE '%'+@search+'%'
END
GO
