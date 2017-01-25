SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetIMA]
(	
	@PursuitEventID int
)
RETURNS table 
AS
RETURN 
	WITH ListBase AS
	(
		SELECT TOP 1
				R.PursuitID, 
				RV.PursuitEventID,
				R.MemberID,
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				DATEADD(YEAR, 9, MBR.DateOfBirth) AS Date09YearsOld,
				DATEADD(YEAR, 10, MBR.DateOfBirth) AS Date10YearsOld,
				DATEADD(YEAR, 11, MBR.DateOfBirth) AS Date11YearsOld,
				DATEADD(YEAR, 13, MBR.DateOfBirth) AS Date13YearsOld,
				dbo.GetAgeAsOf(MBR.DateOfBirth, dbo.MeasureYearEndDate()) AS MemberAge,
				dbo.MeasureYearStartDate() AS StartOfYear,
				DATEADD(YEAR, -1, dbo.MeasureYearStartDate()) AS StartOfPriorYear,
				dbo.MeasureYearEndDate() AS EndOfYear,
				CONVERT(varchar, YEAR(dbo.MeasureYearEndDate())) AS MeasureYear
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
		WHERE	RV.PursuitEventID = @PursuitEventID  
	)
	SELECT	1.0 AS SortOrder,
			'Member''s Date of Birth' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' ' + DOBEdited AS [Value]
	FROM	ListBase
	UNION 
	SELECT	2.0 AS SortOrder,
			'Member''s Age as of 12/31/' + MeasureYear AS Title,
			CONVERT(varchar, MemberAge) AS [Value]
	FROM	ListBase
	UNION SELECT
			3.0 AS SortOrder,
			'Meningococcal Vaccination Date Range' AS Title,
			dbo.ConvertDateToVarchar(Date11YearsOld) + ' - ' + dbo.ConvertDateToVarchar(Date13YearsOld) AS [Value]
	FROM	ListBase
	UNION SELECT
			4.0 AS SortOrder,
			'Tdap Vaccination Date Range' AS Title,
			dbo.ConvertDateToVarchar(Date10YearsOld) + ' - ' + dbo.ConvertDateToVarchar(Date13YearsOld) AS [Value]
	FROM	ListBase
	UNION SELECT
			5.0 AS SortOrder,
			'HPV Vaccination Date Range' AS Title,
			dbo.ConvertDateToVarchar(Date09YearsOld) + ' - ' + dbo.ConvertDateToVarchar(Date13YearsOld) AS [Value]
	FROM	ListBase
	--ORDER BY SortOrder--, Title 
GO
