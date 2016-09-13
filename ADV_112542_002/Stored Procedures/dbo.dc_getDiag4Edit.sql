SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-14-2014
-- Description:	RA Coder will use this sp to pull list of members details in a project
-- =============================================
--	dc_getDiag4Edit  60078,20354,'03/18/2014',1
--suspect_pk: 60078,member_pk: 20354,DOS:'03/18/2014',vld:1}
CREATE PROCEDURE [dbo].[dc_getDiag4Edit]  
	@Suspect BigInt,
	@Member BigInt,
	@DOS DateTime,
	@Vld tinyint
AS
BEGIN
	DECLARE @Provider AS VARCHAR(20)
	SELECT @Provider=Provider_ID FROM tblSuspect S INNER JOIN tblProvider P ON P.Provider_PK = S.Provider_PK INNER JOIN tblProviderMaster PM ON PM.ProviderMaster_PK=P.ProviderMaster_PK WHERE S.Suspect_PK=@Suspect
	SELECT MAX(CodedData_PK) CodedData_PK,DiagnosisCode,Code_Description,DOS_From,DOS_Thru,MAX(CPT) CPT,MAX(User_PK) User_PK,IsICD10,MAX(CodedSource_PK) CodedSource_PK
			,MAX(Provider_PK) Provider_PK, MAX(Provider) Provider
			,dbo.tmi_udf_GetChartNotes(MAX(CodedData_PK)) Notes
			,MAX(NoteText) NoteText
			,MAX(OpenedPage) OpenedPage,MAX(ScannedData_PK) ScannedData_PK
	FROM (
		--Diagnosis Data
		SELECT CD.CodedData_PK,CD.DiagnosisCode,Code_Description,DOS_From,DOS_Thru,CPT,Coded_User_PK User_PK,CD.IsICD10,CD.CodedSource_PK 
			,CD.Provider_PK, PM.Lastname+IsNull(', '+PM.Firstname,'')+' ('+PM.Provider_ID+')' Provider
			--,dbo.tmi_udf_GetChartNotes(CD.CodedData_PK) Notes
			,IsNull(CDNT.Note_Text,'') NoteText
			,CD.OpenedPage, CD.ScannedData_PK
		FROM tblCodedData CD WITH (NOLOCK)
			INNER JOIN tblModelCode MC WITH (NOLOCK) ON MC.DiagnosisCode = CD.DiagnosisCode --AND MC.IsICD10 = CD.IsICD10
			LEFT JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = CD.Provider_PK
			LEFT JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = P.ProviderMaster_PK
			LEFT JOIN tblCodedDataNoteText CDNT WITH (NOLOCK) ON CDNT.CodedData_PK = CD.CodedData_PK
			WHERE CD.Suspect_PK=@Suspect AND CD.DOS_Thru = @DOS AND IsNull(CD.Is_Deleted,0)=0 --AND P.Provider_ID=@Provider
		UNION
		--Claim Data for Validation
		SELECT 
			0 CodedData_PK,CD.DiagnosisCode,Code_Description,CD.DOS_From,CD.DOS_Thru,CD.CPT,0 User_PK,0 IsICD10,0 CodedSource_PK 
			,CD.ProviderMaster_PK, PM.Lastname+IsNull(', '+PM.Firstname,'')+' ('+PM.Provider_ID+')' Provider
			--,0 Notes	
			,'' NoteText				
			,0 OpenedPage,0 ScannedData_PK
			FROM tblClaimData CD 
				LEFT JOIN tblProviderMaster PM ON PM.ProviderMaster_PK = CD.ProviderMaster_PK
				LEFT JOIN tblModelCode MC ON MC.DiagnosisCode = CD.DiagnosisCode
		WHERE CD.Member_PK = @Member AND CD.DOS_Thru =  @DOS--	AND PM.Provider_ID=@Provider	
	) T GROUP By DiagnosisCode,Code_Description,DOS_From,DOS_Thru,IsICD10
END
GO
