SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--qar_getCodedChart 1
CREATE PROCEDURE [dbo].[qar_getCodedChart]
	@Suspect bigINT
AS
BEGIN
	SELECT CD.DiagnosisCode [Dx]
		,CD.DOS_From, CD.DOS_Thru
		,qa.IsConfirmed [Confirmed]
		,qa.IsChanged [Changed]
		,qa.IsAdded [Added]
		,qa.IsRemoved [Removed]
		,qa.Old_ICD9 [Old Dx]
	FROM tblCodedData CD 
		LEFT JOIN tblCodedDataQA QA WITH (NOLOCK) ON CD.CodedData_PK = QA.CodedData_PK  
	where CD.Suspect_PK=@Suspect
END
GO
