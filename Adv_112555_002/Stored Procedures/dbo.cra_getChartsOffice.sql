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
CREATE PROCEDURE [dbo].[cra_getChartsOffice] 
	@Suspect bigint,
	@Office bigint,
	@OnlyIC int
AS
BEGIN
	IF (@OnlyIC=2) --CNA
	BEGIN
		SELECT 
			ROW_NUMBER() OVER(ORDER BY IsNull(IsHighPriority,0) DESC,M.Lastname+IsNull(', '+M.Firstname,'') ASC) AS RowNumber
			,S.Suspect_PK,S.Provider_PK,P.ProviderOffice_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider	
			,S.IsCNA,CNA_Date,U.Lastname+IsNull(', '+U.Firstname,'') CNA_User,SN.Note_Text CNA_Reason
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK				
			LEFT JOIN tblUser U WITH (NOLOCK) ON U.User_PK = S.CNA_User_PK
			LEFT JOIN tblSuspectScanningNotes SSC WITH (NOLOCK) ON SSC.Suspect_PK = S.Suspect_PK
			LEFT JOIN tblScanningNotes SN ON SN.ScanningNote_PK =  SSC.ScanningNote_PK
		WHERE P.ProviderOffice_PK=@Office
			AND IsScanned=0
		ORDER BY Case WHEN @Suspect = S.Suspect_PK THEN 0 ELSE 1 END,S.IsCNA DESC,Member
	END
	ELSE	--Incomplete
	BEGIN
		SELECT 
			ROW_NUMBER() OVER(ORDER BY IsNull(IsHighPriority,0) DESC,M.Lastname+IsNull(', '+M.Firstname,'') ASC) AS RowNumber
			,S.Suspect_PK,S.Provider_PK,P.ProviderOffice_PK,M.Member_ID,M.Lastname+IsNull(', '+M.Firstname,'') Member,M.DOB
			,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider			
		FROM 
			tblSuspect S WITH (NOLOCK)
			INNER JOIN tblMember M WITH (NOLOCK) ON M.Member_PK = S.Member_PK
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK				
		WHERE P.ProviderOffice_PK=@Office
		AND S.Suspect_PK<>@Suspect
		AND (
		(@OnlyIC=0 AND IsCNA=0 AND IsScanned=0 AND S.ChartRec_FaxIn_Date IS NULL AND S.ChartRec_MailIn_Date IS NULL)
		OR
		(@OnlyIC=1 AND S.ChartRec_InComp_Date IS NOT NULL)
		)
	END
END
GO
