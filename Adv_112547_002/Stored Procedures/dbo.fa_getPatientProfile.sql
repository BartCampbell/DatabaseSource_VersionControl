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
fa_getPatientProfile @Member=115
*/
CREATE PROCEDURE [dbo].[fa_getPatientProfile]
	@Member BigInt
AS
BEGIN
	SELECT DiagnosisCode,IsICD10
		,DOS_Thru DOS
		,1 RAPS,0 Claim,0 Captured,ProviderMaster_PK
		INTO #tmp
	FROM tblRAPSData
	WHERE Member_PK=@Member
	UNION
	SELECT DiagnosisCode,IsICD10
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,ProviderMaster_PK
	FROM tblClaimData WHERE Member_PK=@Member
	UNION
	SELECT DiagnosisCode,IsICD10
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,P.ProviderMaster_PK
	FROM tblCodedData C INNER JOIN tblSuspect S ON S.Suspect_PK = C.Suspect_PK 
		 INNER JOIN tblProvider P ON C.Provider_PK = P.Provider_PK
	WHERE Member_PK=@Member
	
	SELECT T.DiagnosisCode,Code_Description,MC.V12HCC,MC.V21HCC,MC.V22HCC
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN YEAR(DOS) ELSE NULL END) ServiceYear1 
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN RAPS ELSE NULL END) RAPS1
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN Claim ELSE NULL END) Claim1
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN Captured ELSE NULL END) Captured1
		,MIN(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN DOS ELSE NULL END) FromDOS1
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN DOS ELSE NULL END) ThruDOS1
		,Count(CASE WHEN YEAR(DOS)=YEAR(GetDate())-3 THEN DOS ELSE NULL END) Occurrence1
		
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN YEAR(DOS) ELSE NULL END) ServiceYear2 
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN RAPS ELSE NULL END) RAPS2
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN Claim ELSE NULL END) Claim2
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN Captured ELSE NULL END) Captured2	
		,MIN(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN DOS ELSE NULL END) FromDOS2
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN DOS ELSE NULL END) ThruDOS2
		,Count(CASE WHEN YEAR(DOS)=YEAR(GetDate())-2 THEN DOS ELSE NULL END) Occurrence2
		
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN YEAR(DOS) ELSE NULL END) ServiceYear3 
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN RAPS ELSE NULL END) RAPS3
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN Claim ELSE NULL END) Claim3
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN Captured ELSE NULL END) Captured3
		,MIN(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN DOS ELSE NULL END) FromDOS3
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN DOS ELSE NULL END) ThruDOS3
		,Count(CASE WHEN YEAR(DOS)=YEAR(GetDate())-1 THEN DOS ELSE NULL END) Occurrence3
		
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN YEAR(DOS) ELSE NULL END) ServiceYear4 
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN RAPS ELSE NULL END) RAPS4
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN Claim ELSE NULL END) Claim4
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN Captured ELSE NULL END) Captured4
		,MIN(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN DOS ELSE NULL END) FromDOS4
		,MAX(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN DOS ELSE NULL END) ThruDOS4
		,Count(CASE WHEN YEAR(DOS)=YEAR(GetDate())-0 THEN DOS ELSE NULL END) Occurrence4
		,MAX(DOS) LastDOS
	INTO #tmp3
	FROM #tmp T INNER JOIN tblModelCode MC ON MC.DiagnosisCode = T.DiagnosisCode AND T.IsICD10 = MC.IsICD10
	GROUP BY T.DiagnosisCode,Code_Description,MC.V12HCC,MC.V21HCC,MC.V22HCC
	ORDER BY MC.V12HCC,MC.V21HCC,MC.V22HCC
	
	SELECT T.*,Prv1,Prv2,Prv3,Prv4,Prv,PrvDOS FROM #tmp3 T
		Outer Apply (SELECT TOP 1 P.Lastname+', '+P.Firstname Prv1 FROM tblProviderMaster P INNER JOIN #tmp X ON X.ProviderMaster_PK = P.ProviderMaster_PK WHERE YEAR(DOS)=YEAR(GetDate())-3 AND T.DiagnosisCode = X.DiagnosisCode ORDER BY DOS DESC) P1
		Outer Apply (SELECT TOP 1 P.Lastname+', '+P.Firstname Prv2 FROM tblProviderMaster P INNER JOIN #tmp X ON X.ProviderMaster_PK = P.ProviderMaster_PK WHERE YEAR(DOS)=YEAR(GetDate())-2 AND T.DiagnosisCode = X.DiagnosisCode ORDER BY DOS DESC) P2
		Outer Apply (SELECT TOP 1 P.Lastname+', '+P.Firstname Prv3 FROM tblProviderMaster P INNER JOIN #tmp X ON X.ProviderMaster_PK = P.ProviderMaster_PK WHERE YEAR(DOS)=YEAR(GetDate())-1 AND T.DiagnosisCode = X.DiagnosisCode ORDER BY DOS DESC) P3
		Outer Apply (SELECT TOP 1 P.Lastname+', '+P.Firstname Prv4 FROM tblProviderMaster P INNER JOIN #tmp X ON X.ProviderMaster_PK = P.ProviderMaster_PK WHERE YEAR(DOS)=YEAR(GetDate())-0 AND T.DiagnosisCode = X.DiagnosisCode ORDER BY DOS DESC) P4
		Outer Apply (SELECT TOP 1 P.Lastname+', '+P.Firstname Prv,DOS PrvDOS FROM tblProviderMaster P INNER JOIN #tmp X ON X.ProviderMaster_PK = P.ProviderMaster_PK WHERE T.DiagnosisCode = X.DiagnosisCode ORDER BY DOS DESC) P
END

GO
