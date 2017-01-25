SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Guidance].[GetABA]
(	
	@PursuitEventID int
)
RETURNS TABLE 
AS
RETURN 
(
	WITH ListBase AS
	(
		SELECT TOP 1
				R.PursuitID, 
				RV.PursuitEventID,
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				DATEADD(year, 18, MBR.DateOfBirth) AS Date18YearsOld,
				DATEADD(year, 19, MBR.DateOfBirth) AS Date19YearsOld,
				DATEADD(year, 20, MBR.DateOfBirth) AS Date20YearsOld,
				DATEADD(year, 21, MBR.DateOfBirth) AS Date21YearsOld,
				dbo.GetAgeAsOf(MBR.DateOfBirth, dbo.MeasureYearEndDate()) AS MemberAge,
				dbo.MeasureYearStartDate() AS StartOfYear,
				DATEADD(year, -1, dbo.MeasureYearStartDate()) AS StartOfPriorYear,
				dbo.MeasureYearEndDate() AS EndOfYear,
				CONVERT(varchar, YEAR(dbo.MeasureYearEndDate())) AS MeasureYear
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Measure AS M
						ON M.MeasureID = RV.MeasureID AND
							M.HEDISMeasure = 'ABA'
				INNER JOIN dbo.Member AS MBR
						ON R.MemberID = MBR.MemberID
		WHERE	RV.PursuitEventID = @PursuitEventID  
	)
	SELECT	'Member''s Date of Birth' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' ' + DOBEdited AS [Value],
			1.0 AS SortOrder
	FROM	ListBase
	UNION 
	SELECT	'Member''s Age as of 12/31/' + MeasureYear AS Title,
			CONVERT(varchar, MemberAge) AS [Value],
			2.0 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'BMI Value Date Range' AS Title, -- turns 20 or 21 this year or is older than 21
			dbo.ConvertDateToVarchar(CASE WHEN DATEADD(day, -1, Date20YearsOld) > StartOfYear THEN dbo.ConvertDateToVarchar(Date20YearsOld) ELSE StartOfPriorYear END) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
	WHERE	((DATEADD(day, -1, Date20YearsOld) BETWEEN StartOfPriorYear AND EndOfYear)
			OR MemberAge > 21)
	UNION
	SELECT	'BMI Percentile or Age-Growth Chart Date Range' AS Title, -- turns 20 this year
			dbo.ConvertDateToVarchar(StartOfPriorYear) + ' - ' + dbo.ConvertDateToVarchar(DATEADD(day, -1, Date20YearsOld)) AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
	WHERE	DATEADD(day, -1, Date20YearsOld) BETWEEN StartOfYear AND EndOfYear
	UNION
	SELECT	'BMI Percentile or Age-Growth Chart Date Range' AS Title, -- turns 18 or 19 this year
			dbo.ConvertDateToVarchar(StartOfPriorYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear),
			3.1 AS SortOrder
	FROM	ListBase
	WHERE	DATEADD(day, -1, Date18YearsOld) BETWEEN StartOfPriorYear AND EndOfYear
)
GO
