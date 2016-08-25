SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-14-2014
-- Description:	RA Coder will use this sp to pull list of members details in a project
-- =============================================
--	qa_getDiag4Edit  96525,23727,'05/27/2014',1

CREATE PROCEDURE [dbo].[qa_getDiag4Edit]  
	@Suspect BigInt,
	@Member BigInt,
	@DOS DateTime,
	@Vld tinyint
AS
BEGIN
		--Diagnosis Data
		SELECT CD.CodedData_PK,CD.DiagnosisCode,Code_Description,DOS_From,DOS_Thru,CPT,Coded_User_PK User_PK,CD.IsICD10,CD.CodedSource_PK 
			,CD.Provider_PK, PM.Lastname+IsNull(', '+PM.Firstname,'')+' ('+PM.Provider_ID+')' Provider
			,dbo.tmi_udf_GetChartNotes(CD.CodedData_PK) Notes
			,IsNull(CDNT.Note_Text,'') NoteText
			,CD.OpenedPage,CD.ScannedData_PK			
		FROM tblCodedData CD WITH (NOLOCK)
			INNER JOIN tblModelCode MC WITH (NOLOCK) ON MC.DiagnosisCode = CD.DiagnosisCode --AND MC.IsICD10 = CD.IsICD10
			LEFT JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = CD.Provider_PK
			LEFT JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblCodedDataNoteText CDNT WITH (NOLOCK) ON CDNT.CodedData_PK = CD.CodedData_PK
			WHERE CD.Suspect_PK=@Suspect AND CD.DOS_Thru = @DOS AND IsNull(CD.Is_Deleted,0)=0 --AND P.Provider_ID=@Provider
END
GO
