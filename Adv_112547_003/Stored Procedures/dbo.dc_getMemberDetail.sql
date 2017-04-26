SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	dc_getMemberDetail 0,13661,5197,0,0,'NPL',1,0
CREATE PROCEDURE [dbo].[dc_getMemberDetail]  
	@Provider BigInt,
	@Member BigInt,
	@Suspect BigInt,
	@DetailType tinyint,
	@DetailInfo smallint,
	@ValidateType varchar(3),
	@UserPK int,
	@IsBlindCoding tinyint
AS
BEGIN
--	DECLARE @ProviderMaster_PK AS BIGINT
--	SELECT TOP 1 @ProviderMaster_PK=ProviderMaster_PK FROM tblProvider WHERE Provider_PK=@Provider

	DECLARE @level AS tinyint
	SELECT @level=CoderLevel FROM tblUser WHERE User_PK=@UserPK

	--Diagnosis Data
	SELECT MAX(Data_PK) Data_PK
		,T.DiagnosisCode DiagnosisCode,MIN(DOS_From) DOS_From,DOS_Thru,MIN(DataType) DataType,Year(DOS_Thru) DOS_Year, MAX(NoteType) NoteType
		,V12HCC,V21HCC,V22HCC,RxHCC,IsICD10,CASE WHEN MIN(DataType)=1 THEN CASE WHEN @ValidateType='HCC' THEN CAST(V21HCC AS varchar) ELSE T.DiagnosisCode END END Validated 
	FROM (
		SELECT CodedData_PK Data_PK,DiagnosisCode,DOS_From,DOS_Thru,1 DataType,Coded_User_PK User_PK, NT.NoteType NoteType 
			FROM tblCodedData CD WITH (NOLOCK)  LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			WHERE Suspect_PK=@Suspect AND Year(DOS_Thru)>=Year(GetDate())-2 AND IsNull(CD.Is_Deleted,0)=0 AND CD.CoderLevel = @level
		UNION
		SELECT CodedData_PK Data_PK,DiagnosisCode,DOS_From,DOS_Thru,2 DataType,Coded_User_PK User_PK, NT.NoteType NoteType 
			FROM tblCodedData CD WITH (NOLOCK)  LEFT JOIN tblNoteType NT WITH (NOLOCK) ON CD.CodedSource_PK = NT.NoteType_PK  
			WHERE Suspect_PK=@Suspect AND Year(DOS_Thru)>=Year(GetDate())-2 AND IsNull(CD.Is_Deleted,0)=0 AND CD.CoderLevel <> @level AND @IsBlindCoding=0
		UNION
		SELECT ClaimData_PK Data_PK,DiagnosisCode,DOS_From,DOS_Thru,3 DataType,0 User_PK, '' NoteType  FROM tblClaimData CD WITH (NOLOCK) 			
			WHERE CD.Suspect_PK=@Suspect AND Year(DOS_Thru)>=Year(GetDate())-2 --AND CD.ProviderMaster_PK=@ProviderMaster_PK

		--SELECT ClaimData_PK Data_PK,DiagnosisCode,DOS_From,DOS_Thru,3 DataType,0 User_PK, '' NoteType  FROM tblClaimData WITH (NOLOCK) WHERE Member_PK=@Member AND Year(DOS_Thru)>=Year(GetDate())-2
		--UNION
		--SELECT RAPSData_PK  Data_PK,DiagnosisCode,DOS_From,DOS_Thru,2 DataType,0 User_PK, '' NoteType  FROM tblRAPSData WITH (NOLOCK) WHERE Member_PK=@Member AND Year(DOS_Thru)>=Year(GetDate())-2
	) T
	LEFT JOIN tblModelCode C WITH (NOLOCK) ON C.DiagnosisCode = T.DiagnosisCode AND C.start_date<=DOS_From AND C.end_date>=DOS_From
	GROUP BY T.DiagnosisCode,V12HCC,V21HCC,V22HCC,RxHCC, DOS_Thru,IsICD10
	ORDER BY DOS_Thru,MAX(Data_PK) DESC

	IF (@DetailType=1)
		RETURN;
	--Captured Source
	SELECT * FROM tblCodedSource WITH (NOLOCK) ORDER BY sortOrder
	
	SELECT COUNT(*) FROM tblScannedData WITH (NOLOCK) WHERE Suspect_PK=@Suspect
	
	SELECT NoteText_PK FROM tblSuspectNote WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	SELECT Note_Text FROM tblSuspectNoteText WITH (NOLOCK) WHERE Suspect_PK = @Suspect
	
	SELECT NoteType_PK CodedSource_PK, NoteType CodedSource FROM tblNoteType WITH (NOLOCK)

	SELECT distinct HM.measure_description FROM tblHEDIS_Suspect HS 
		INNER JOIN tblHEDIS_Measure HM ON HM.Measure_PK = HS.Measure_PK
		INNER JOIN tblSuspect S ON S.Suspect_PK = HS.Suspect_PK
	WHERE S.Member_PK=@Member
/*
	if (@Provider=0)
	BEGIN 
		SELECT P.Provider_PK,PM.Provider_ID,PM.Lastname+IsNull(', '+PM.Firstname,'') Provider_Name
			FROM tblProvider P WITH (NOLOCK) 
				INNER JOIN tblSuspect S WITH (NOLOCK) ON S.Provider_PK = P.Provider_PK 
				INNER JOIN tblProviderMaster PM WITH (NOLOCK) ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			WHERE S.Suspect_PK = @Suspect
	END
*/

	SELECT IsQA FROM tblSuspect WHERE Suspect_PK=@Suspect

	IF (@ValidateType='HCC')
		SELECT DISTINCT V.HCC Code,H.HCC_Desc Code_Desc FROM tblHCC2Validate V INNER JOIN tblHCC H ON H.HCC = V.HCC AND H.PaymentModel = V.PaymentModel WHERE V.Member_PK = @Member
	ELSE IF (@ValidateType='NLP')
		SELECT DISTINCT MC.DiagnosisCode Code,MC.Code_Description Code_Desc FROM tblNPL2Validate V INNER JOIN tblModelCode MC ON MC.DiagnosisCode = V.DiagnosisCode WHERE V.Suspect_PK = @Suspect

END
GO
