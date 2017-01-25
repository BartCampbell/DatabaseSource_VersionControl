SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetRISK]
(	
	@PursuitEventID int
)
RETURNS table 
AS
RETURN 
(
	WITH ListBase AS
	(
		SELECT TOP 1
				R.PursuitID, 
				RV.PursuitEventID,
				R.MemberID,
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				dbo.GetAgeAsOf(MBR.DateOfBirth, dbo.MeasureYearEndDate()) AS MemberAge,
				dbo.MeasureYearStartDate() AS StartOfYear,
				DATEADD(YEAR, -1, dbo.MeasureYearStartDate()) AS StartOfPriorYear,
				dbo.MeasureYearEndDate() AS EndOfYear,
				dbo.GetRiskYear() AS RiskYear
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
		WHERE	RV.PursuitEventID = @PursuitEventID  
	),
	ClaimCodes AS
	(
		SELECT DISTINCT
				LB.*, MRDR.Code, MRDR.CodeTypeID
		FROM	ListBase AS LB
				INNER JOIN dbo.MedicalRecordRISKDiag AS MRDR
						ON MRDR.PursuitEventID = LB.PursuitEventID AND
							MRDR.PursuitID = LB.PursuitID
	),
	HCCs AS
	(
		SELECT DISTINCT
				HCC.HCC, HCC.HCCDescription, 
				COUNT(DISTINCT QUOTENAME(CCT.CodeType) + '_' + CC.Code) AS CountCodes, 
				MIN(QUOTENAME(CCT.CodeType) + ' ' + CC.Code) + CASE WHEN COUNT(DISTINCT QUOTENAME(CCT.CodeType) + '_' + CC.Code) > 1 THEN '+' ELSE '' END AS Code,
				ROW_NUMBER() OVER (ORDER BY CASE WHEN ISNUMERIC(HCC.HCC) = 1 THEN CONVERT(int, HCC.HCC) ELSE -1 END, HCC.HCC) AS SortOrder
		FROM	ClaimCodes AS CC
				INNER JOIN dbo.ClaimCodeTypes AS CCT
						ON CCT.CodeTypeID = CC.CodeTypeID
				INNER JOIN dbo.ClaimCodeHCCs AS HCC
						ON HCC.Code = CC.Code AND
							HCC.CodeTypeID = CC.CodeTypeID AND
							HCC.RiskYear = CC.RiskYear
		WHERE	hcc.HasHCC = 1
		GROUP BY HCC.HCC, HCC.HCCDescription
	)
	SELECT	CASE WHEN t.SortOrder = 1 THEN 'List of HCC(s) - ' ELSE '' END + CONVERT(varchar(128), t.SortOrder) AS Title,
			'<em>' + t.HCC + '</em> - ' + t.HCCDescription + '&nbsp;&nbsp;&nbsp;<em>(' + t.Code + ')</em>'  AS [Value],
			1.00 + (t.SortOrder * 0.01) AS SortOrder
	FROM	HCCs AS t
	UNION 
	SELECT TOP 1
			'List of HCC(s)'  AS Title,
			'<em>(n/a - none identified)</em>'  AS [Value],
			1.00 AS SortOrder
	FROM	ListBase AS t
	WHERE	NOT EXISTS(SELECT TOP 1 1 FROM HCCs)
)
GO
