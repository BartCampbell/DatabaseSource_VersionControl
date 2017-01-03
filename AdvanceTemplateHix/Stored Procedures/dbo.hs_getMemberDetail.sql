SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Finance Report List
-- =============================================
/* Sample Executions
hs_getMemberDetail @Suspect=305677
*/
CREATE PROCEDURE [dbo].[hs_getMemberDetail]
	@Suspect BigInt
AS
BEGIN
	--Question
	SELECT M.measure_PK,M.measure_description
		,Q.question_pk,Q.question_description,Q.is_CPT,Q.is_Diastolic,Q.is_Systolic,Q.is_LDC,Q.is_ICD9
		,Q.aditional_info
		,dos,icd9,cpt,Claim_PK,is_confirmed,IsNull(ScannedData_PK,0) ScannedData_PK
		FROM tblHEDIS_suspect S
		INNER JOIN tblHEDIS_measure M ON M.measure_PK = S.measure_pk
		INNER JOIN tblHEDIS_question Q ON M.measure_PK = Q.measure_PK
		OUTER APPLY (SELECT MAX(feedback_pk) feedback_pk FROM tblHEDIS_feedback WHERE suspect_pk = @Suspect) F
		LEFT JOIN tblHEDIS_feedback_detail FD ON F.feedback_pk = FD.feedback_pk AND FD.question_pk=Q.question_pk
	WHERE S.suspect_pk = @Suspect
	ORDER BY M.measure_PK,Q.question_pk

	--CPT
	SELECT M.measure_PK,Q.question_pk,C.cpt
		FROM tblHEDIS_suspect S
		INNER JOIN tblHEDIS_measure M ON M.measure_PK = S.measure_pk
		INNER JOIN tblHEDIS_question Q ON M.measure_PK = Q.measure_PK
		LEFT JOIN tblHEDIS_cpt C ON C.question_pk = Q.question_pk
	WHERE S.suspect_pk = @Suspect
	ORDER BY M.measure_PK,Q.question_pk	
	
	--ICD9
	SELECT M.measure_PK,Q.question_pk,C.ICD9
		FROM tblHEDIS_suspect S
		INNER JOIN tblHEDIS_measure M ON M.measure_PK = S.measure_pk
		INNER JOIN tblHEDIS_question Q ON M.measure_PK = Q.measure_PK
		LEFT JOIN tblHEDIS_ICD9 C ON C.question_pk = Q.question_pk
	WHERE S.suspect_pk = @Suspect
	ORDER BY M.measure_PK,Q.question_pk		

	--Claim CPT
	SELECT DISTINCT Q.question_pk,HC.Claim_PK,HC.To_Date ,HC_CPT.CPT
		FROM tblHEDIS_suspect HS
		INNER JOIN tblSuspect S ON S.Suspect_PK = HS.suspect_pk
		INNER JOIN tblHEDIS_measure M ON M.measure_PK = HS.measure_pk 
		INNER JOIN tblHEDIS_question Q ON M.measure_PK = Q.measure_PK
		INNER JOIN tblHEDIS_cpt cpt ON cpt.question_pk = Q.question_pk
		INNER JOIN tblHEDIS_dates D ON cpt.date_pk = D.date_pk
		INNER JOIN tblHEDIS_Claim HC ON HC.Member_PK = S.Member_PK AND HC.To_Date>=D.StartDate AND HC.To_Date<=D.EndDate
		INNER JOIN tblHEDIS_ClaimCPT HC_CPT ON HC_CPT.Claim_PK = HC.Claim_PK --AND HC_CPT.CPT = cpt.cpt
	WHERE S.suspect_pk = @Suspect
	ORDER BY Q.question_pk,HC.To_Date

	--Claim ICD9
	SELECT DISTINCT Q.question_pk,HC.Claim_PK,HC.To_Date,HC_icd9.icd9
		FROM tblHEDIS_suspect HS
		INNER JOIN tblSuspect S ON S.Suspect_PK = HS.suspect_pk
		INNER JOIN tblHEDIS_measure M ON M.measure_PK = HS.measure_pk 
		INNER JOIN tblHEDIS_question Q ON M.measure_PK = Q.measure_PK
		INNER JOIN tblHEDIS_ICD9 icd9 ON icd9.question_pk = Q.question_pk
		INNER JOIN tblHEDIS_dates D ON icd9.date_pk = D.date_pk
		INNER JOIN tblHEDIS_Claim HC ON HC.Member_PK = S.Member_PK AND HC.To_Date>=D.StartDate AND HC.To_Date<=D.EndDate
		INNER JOIN tblHEDIS_ClaimICD9 HC_icd9 ON HC_icd9.Claim_PK = HC.Claim_PK --AND HC_icd9.ICD9 = icd9.icd9
	WHERE S.suspect_pk = @Suspect
	ORDER BY Q.question_pk,HC.To_Date
END
GO
