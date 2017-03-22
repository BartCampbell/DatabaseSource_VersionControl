SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cnm_getChaseInfo 546
Create PROCEDURE [dbo].[cnm_getChaseInfo] 
	@suspect bigint
AS
BEGIN
	--Chase Status
	SELECT IsCNA,CNA_Date,IsScanned,Scanned_Date,IsCoded,Coded_Date FROM tblSuspect WHERE Suspect_PK=@suspect

	--Historical Claims and Coding
	SELECT T.DiagnosisCode,MC.Code_Description,T.DOS,MC.V12HCC,MC.V21HCC,MC.V22HCC,MAX([Validation]) [Validation],MAX(Claim) Claim,MAX(Coded) Coded
	FROM (
		SELECT DiagnosisCode,DOS_Thru DOS,NULL [Validation],1 Claim,0 Coded
		FROM tblClaimData WHERE Suspect_PK=@suspect
		UNION
		SELECT DiagnosisCode,DOS_Thru DOS,NT.NoteType [Validation],0 Claim,1 Coded
		FROM tblCodedData C LEFT JOIN tblNoteType NT ON NT.NoteType_PK = CodedSource_PK
		WHERE Suspect_PK=@suspect AND (C.Is_Deleted IS NULL OR C.Is_Deleted=0)
	) T LEFT JOIN tblModelCode MC ON MC.DiagnosisCode = T.DiagnosisCode
	GROUP BY T.DiagnosisCode,MC.Code_Description,T.DOS,MC.V12HCC,MC.V21HCC,MC.V22HCC
	ORDER BY T.DOS

	--Channel Log
	SELECT C_From.Channel_Name From_Channel, C_To.Channel_Name To_Channel, U.Lastname+IsNull(', '+U.Firstname,'') ByUser, CL.dtUpdate FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblChannelLog CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChannel C_To WITH (NOLOCK) ON C_To.Channel_PK = CL.To_Channel_PK
			INNER JOIN tblChannel C_From WITH (NOLOCK) ON C_From.Channel_PK = CL.From_Channel_PK
			INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = CL.User_PK
	WHERE S.Suspect_PK = @suspect
	ORDER BY CL.dtUpdate ASC

	--Chase Status Log
	SELECT C_From.ChaseStatus+' ('+C_From.ChartResolutionCode+')' From_Status, C_To.ChaseStatus+' ('+C_To.ChartResolutionCode+')' To_Status, U.Lastname+IsNull(', '+U.Firstname,'') ByUser, CL.dtUpdate FROM tblProvider P WITH (NOLOCK)
			INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK	
			INNER JOIN tblChaseStatusLog CL WITH (NOLOCK) ON CL.Suspect_PK = S.Suspect_PK
			INNER JOIN tblChaseStatus C_To WITH (NOLOCK) ON C_To.ChaseStatus_PK = CL.To_ChaseStatus_PK
			INNER JOIN tblChaseStatus C_From WITH (NOLOCK) ON C_From.ChaseStatus_PK = CL.From_ChaseStatus_PK
			INNER JOIN tblUser U WITH (NOLOCK) ON U.User_PK = CL.User_PK
	WHERE S.Suspect_PK = @suspect
	ORDER BY CL.dtUpdate ASC

	--Scanned Data Info
	SELECT TOP 1 * FROM tblScannedData WHERE Suspect_PK = @suspect AND (is_deleted IS NULL OR is_deleted=0)
END
GO
