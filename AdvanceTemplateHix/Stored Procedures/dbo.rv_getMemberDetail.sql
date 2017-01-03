SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Sajid Ali
-- Create date: Jun-25-2014
-- Description:	To get Retrospective Validation Detail
-- =============================================
/* Sample Executions
rv_getMemberDetail @Member=115
*/
CREATE PROCEDURE [dbo].[rv_getMemberDetail]
	@Member BigInt
AS
BEGIN
	SELECT DiagnosisCode,IsICD10,CPT
		,DOS_Thru DOS
		,1 RAPS,0 Claim,0 Captured,Provider_PK
		INTO #tmp
	FROM tblRAPSData WHERE Member_PK=@Member AND YEAR(DOS_Thru)>=YEAR(GetDate())-1
	UNION
	SELECT DiagnosisCode,IsICD10,CPT
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,Provider_PK
	FROM tblClaimData WHERE Member_PK=@Member AND YEAR(DOS_Thru)>=YEAR(GetDate())-1
	UNION
	SELECT DiagnosisCode,IsICD10,CPT
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,Provider_PK
	FROM tblCodedData C INNER JOIN tblSuspect S ON S.Suspect_PK = C.Suspect_PK WHERE Member_PK=@Member AND YEAR(DOS_Thru)>=YEAR(GetDate())-1
	
	SELECT T.DiagnosisCode,MC.Code_Description
		,MAX(CPT) CPT,DOS
		,MAX(RAPS) RAPS,MAX(Claim) Claim,MAX(Captured) Captured,MAX(P.Lastname+', '+P.Firstname) Provider
		,V12HCC,V21HCC,V22HCC,RxHCC
	FROM #tmp T
		INNER JOIN tblModelCode MC ON MC.DiagnosisCode = T.DiagnosisCode AND MC.IsICD10 = T.IsICD10
		LEFT JOIN tblProvider P ON P.Provider_PK = T.Provider_PK
	GROUP BY T.DiagnosisCode,MC.Code_Description,DOS,V12HCC,V21HCC,V22HCC,RxHCC
	ORDER BY DOS,T.DiagnosisCode
END

GO
