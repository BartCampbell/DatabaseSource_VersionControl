SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetCDC]
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
				RV.AbstractionStatusID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				dbo.GetAgeAsOf(MBR.DateOfBirth, dbo.MeasureYearEndDate()) AS MemberAge,
				dbo.MeasureYearStartDate() AS StartOfYear,
				DATEADD(YEAR, -1, dbo.MeasureYearStartDate()) AS StartOfPriorYear,
				dbo.MeasureYearEndDate() AS EndOfYear,
				CONVERT(varchar, YEAR(dbo.MeasureYearEndDate())) AS MeasureYear
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				INNER JOIN dbo.Measure AS M
						ON M.MeasureID = RV.MeasureID AND
							M.HEDISMeasure = 'CDC'
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
	SELECT	'HbA1c Test Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartOfYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Retinal/Dilated Eye Exam Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartOfYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.1 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Negative Retinal/Dilated Eye Exam Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartOfPriorYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.2 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Nephropathy Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartOfYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.3 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Blood Pressure Reading Date Range' AS Title,
			dbo.ConvertDateToVarchar(StartOfYear) + ' - ' + dbo.ConvertDateToVarchar(EndOfYear) AS [Value],
			3.4 AS SortOrder
	FROM	ListBase
)


GO
