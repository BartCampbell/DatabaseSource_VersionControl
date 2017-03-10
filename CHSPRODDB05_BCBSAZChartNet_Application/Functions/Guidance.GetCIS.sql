SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Guidance].[GetCIS]
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
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				DATEADD(YEAR, 2, MBR.DateOfBirth) AS Date2YearsOld,
				DATEADD(DAY, 42, MBR.DateOfBirth) AS Date42DaysOld,
				DATEADD(DAY, 180, MBR.DateOfBirth) AS Date180DaysOld,
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
	SELECT	'Member''s Date of Birth' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' ' + DOBEdited AS [Value],
			1.0 AS SortOrder
	FROM	ListBase
	UNION SELECT TOP 100 PERCENT
			'DTaP/HiB/IPV/Pneum/Rota Date Range' AS Title,
			dbo.ConvertDateToVarchar(Date42DaysOld) + ' - ' + dbo.ConvertDateToVarchar(Date2YearsOld) AS [Value],
			1.1 AS SortOrder
	FROM	ListBase
	UNION
	SELECT TOP 100 PERCENT	
			'HepA/HepB/MMR/VZV Date Range' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' - ' + dbo.ConvertDateToVarchar(Date2YearsOld) AS [Value],
			1.2 AS SortOrder
	FROM	ListBase
	UNION
	SELECT TOP 100 PERCENT	
			'Influenza Date Range' AS Title,
			dbo.ConvertDateToVarchar(Date180DaysOld) + ' - ' + dbo.ConvertDateToVarchar(Date2YearsOld) AS [Value],
			1.3 AS SortOrder
	FROM	ListBase
	UNION
	SELECT TOP 100 PERCENT
			CIS.HEDISSubMetricComponentDesc AS Title,
			CIS.ServiceDates AS Value,
			2.1 AS SortOrder
	FROM	ListBase AS LB
			CROSS APPLY dbo.GetCISServiceDates(LB.MemberID) AS CIS
	ORDER BY SortOrder, Title
)

GO
