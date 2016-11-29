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
fa_getDiagnosisDetail @Member=115,@DiagnosisCode='4019'
*/
CREATE PROCEDURE [dbo].[fa_getDiagnosisDetail]
	@Member BigInt,
	@DiagnosisCode varchar(10)
AS
BEGIN
	SELECT DiagnosisCode
		,DOS_Thru DOS
		,1 RAPS,0 Claim,0 Captured,ProviderMaster_PK
		INTO #tmp
	FROM tblRAPSData WHERE Member_PK=@Member AND DiagnosisCode=@DiagnosisCode
	UNION
	SELECT DiagnosisCode
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,ProviderMaster_PK
	FROM tblClaimData WHERE Member_PK=@Member AND DiagnosisCode=@DiagnosisCode
	UNION
	SELECT DiagnosisCode
		,DOS_Thru DOS
		,0 RAPS,1 Claim,0 Captured,P.ProviderMaster_PK
	FROM tblCodedData C INNER JOIN tblSuspect S ON S.Suspect_PK = C.Suspect_PK INNER JOIN tblProvider P ON P.Provider_PK = C.Provider_PK
	WHERE Member_PK=@Member AND DiagnosisCode=@DiagnosisCode
	
	SELECT
		DOS,0 RAPS,1 Claim,0 Captured,P.Lastname+', '+P.Firstname Prv
	FROM #tmp T
	LEFT JOIN tblProviderMaster P ON T.ProviderMaster_PK = P.ProviderMaster_PK
	ORDER BY DOS DESC
	
	SELECT MC.DiagnosisCode,Code_Description,MC.V12HCC,MC.V21HCC,MC.V22HCC FROM tblModelCode MC WHERE DiagnosisCode=@DiagnosisCode
END

GO
