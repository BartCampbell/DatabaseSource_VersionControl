SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-14-2014
-- Description:	RA Coder will use this sp to pull list of members details in a project
-- =============================================
--	qa_getDiag4Edit  541,1610,'01/01/2015',1

CREATE PROCEDURE [dbo].[qa_getDiag4Edit]  
	@Suspect BigInt,
	@Member BigInt,
	@DOS DateTime,
	@Vld tinyint
AS
BEGIN
		--Diagnosis Data
		SELECT CD.CodedData_PK,CD.DiagnosisCode,MC.Code_Description,DOS_From,DOS_Thru,CPT,Coded_User_PK User_PK,CD.IsICD10,CD.CodedSource_PK 
			,CD.Provider_PK, PM.Lastname+IsNull(', '+PM.Firstname,'')+' ('+PM.Provider_ID+')' Provider
			,dbo.tmi_udf_GetChartNotes(CD.CodedData_PK,0) Notes
			,dbo.tmi_udf_GetChartNotes(CD.CodedData_PK,1) QANotes
			,IsNull(CDNT.Note_Text,'') QANoteText
			,IsNull(CDNT.BeforeQANote_Text,CDNT.Note_Text) NoteText
			,CD.OpenedPage,CD.ScannedData_PK,IsNull(CD.BeforeQA_OpenedPage,CD.OpenedPage) BeforeQA_OpenedPage,IsNull(CD.BeforeQA_ScannedData_PK,CD.ScannedData_PK) BeforeQA_ScannedData_PK
			,QA.Old_ICD9 DiagnosisCode1, MC_QA.Code_Description Code_Description1
			,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM tblCodedData CD WITH (NOLOCK)
			INNER JOIN tblModelCode MC WITH (NOLOCK) ON MC.DiagnosisCode = CD.DiagnosisCode --AND MC.IsICD10 = CD.IsICD10
			LEFT JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = CD.Provider_PK
			LEFT JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblCodedDataNoteText CDNT WITH (NOLOCK) ON CDNT.CodedData_PK = CD.CodedData_PK
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.CodedData_PK
			LEFT JOIN tblModelCode MC_QA WITH (NOLOCK) ON MC_QA.DiagnosisCode = QA.Old_ICD9
			WHERE CD.Suspect_PK=@Suspect AND CD.DOS_Thru = @DOS --AND IsNull(CD.Is_Deleted,0)=0 --AND P.Provider_ID=@Provider
			 AND (CD.Is_Deleted IS NULL OR CD.Is_Deleted=0 OR QA.IsRemoved=1)
END
GO
