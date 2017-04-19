SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-14-2014
-- Description:	RA Coder will use this sp to pull list of members details in a project
-- =============================================
--	qa_getMemberDetail 13129,15620,0,0
CREATE PROCEDURE [dbo].[qa_getMemberDetail]  
	@Member BigInt,
	@Suspect BigInt,
	@DetailType tinyint,
	@DetailInfo smallint
AS
BEGIN
	SELECT CD.CodedData_PK Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,Year(DOS_Thru) DOS_Year,NT.NoteType ValidationNote
			,V12HCC,V21HCC,V22HCC,RxHCC,C.IsICD10,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM tblCodedData CD WITH (NOLOCK)
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.CodedData_PK
			LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK
			LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = CD.DiagnosisCode
		WHERE Suspect_PK=@Suspect AND (CD.Is_Deleted IS NULL OR CD.Is_Deleted=0 OR QA.IsRemoved=1)
		ORDER BY DOS_Thru DESC

	IF (@DetailType=1)
		RETURN;
	--Captured Source
	SELECT * FROM tblCodedSource WITH (NOLOCK) ORDER BY sortOrder
	
	SELECT TOP 1 * FROM tblScannedData WITH (NOLOCK) WHERE Suspect_PK=@Suspect
	
	SELECT NoteText_PK,IsConfirmed,IsRemoved,IsAdded FROM tblSuspectNote WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	SELECT Note_Text,IsNull(BeforeQANote_Text,Note_Text) BeforeQANote_Text,QANote_Text FROM tblSuspectNoteText WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	
	SELECT NoteType_PK CodedSource_PK, NoteType CodedSource FROM tblNoteType WITH (NOLOCK)

	SELECT S.ChaseID,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider
		FROM 
			tblSuspect TS WITH (NOLOCK) 
			INNER JOIN tblSuspect S WITH (NOLOCK) ON TS.Suspect_PK = S.LinkedSuspect_PK 
			INNER JOIN tblProvider P WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
			INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
		WHERE TS.Suspect_PK = @Suspect
END
GO
