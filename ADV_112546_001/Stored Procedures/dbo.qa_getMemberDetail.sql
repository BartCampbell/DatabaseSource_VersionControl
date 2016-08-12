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

	SELECT DISTINCT Provider_PK,ProviderMaster_PK INTO #Prv FROM tblProvider WHERE ProviderMaster_PK IN (SELECT DISTINCT ProviderMaster_PK FROM tblProvider P INNER JOIN tblSuspect S ON S.Provider_PK = P.Provider_PK WHERE S.Suspect_PK = @Suspect)
	/*
	--Diagnosis Data without Historical Data - Start

		SELECT CD.CodedData_PK Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,1 DataType,Year(DOS_Thru) DOS_Year, NoteType
			,V12HCC,V21HCC,V22HCC,RxHCC,C.IsICD10,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM tblCodedData CD WITH (NOLOCK)  
			LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.CodedData_PK
			LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = CD.DiagnosisCode
		WHERE Suspect_PK=@Suspect 
			AND IsNull(CD.Is_Deleted,0)=0
		ORDER BY DOS_Thru DESC

	--Diagnosis Data without Historical Data - End
	*/
	--Diagnosis Data with Historical Data - Start	
		SELECT MAX(Data_PK) Data_PK,DiagnosisCode,DOS_From DOS_From,DOS_Thru,MIN(DataType) DataType,Year(DOS_Thru) DOS_Year,MAX(CodedSource_PK) CodedSource_PK INTO #tmpData FROM (
			SELECT CD.CodedData_PK Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,1 DataType,Year(DOS_Thru) DOS_Year,CD.CodedSource_PK
				FROM tblCodedData CD WITH (NOLOCK)
				WHERE Suspect_PK=@Suspect AND IsNull(CD.Is_Deleted,0)=0
			UNION
			SELECT -1 Data_PK,DiagnosisCode,DOS_From,DOS_Thru,3 DataType,Year(DOS_Thru) DOS_Year,0 CodedSource_PK
				FROM tblClaimData CD WITH (NOLOCK) 
				INNER JOIN #Prv P ON P.ProviderMaster_PK = CD.ProviderMaster_PK 
				WHERE Member_PK=@Member AND Year(DOS_Thru)>=Year(GetDate())-2 AND DiagnosisCode<>''
		) T GROUP BY DiagnosisCode,DOS_From,DOS_Thru

		SELECT CD.Data_PK,CD.DiagnosisCode,DOS_From DOS_From,DOS_Thru,DataType,Year(DOS_Thru) DOS_Year, NoteType
			,V12HCC,V21HCC,V22HCC,RxHCC,C.IsICD10,IsNull(IsConfirmed,0) IsConfirmed,IsNull(IsAdded,0) IsAdded,IsNull(IsRemoved,0) IsRemoved,IsNull(IsChanged,0) IsChanged
		FROM #tmpData CD   
			LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON QA.CodedData_PK = CD.Data_PK
			LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = CD.DiagnosisCode
		ORDER BY DOS_Thru DESC
		--Diagnosis Data with Historical Data - Ends
		

	IF (@DetailType=1)
		RETURN;
	--Captured Source
	SELECT * FROM tblCodedSource WITH (NOLOCK) ORDER BY sortOrder
	
	SELECT COUNT(*) FROM tblScannedData WITH (NOLOCK) WHERE Suspect_PK=@Suspect
	
	SELECT NoteText_PK FROM tblSuspectNote WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	SELECT Note_Text FROM tblSuspectNoteText WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	
	SELECT NoteType_PK CodedSource_PK, NoteType CodedSource FROM tblNoteType WITH (NOLOCK)
END
GO
