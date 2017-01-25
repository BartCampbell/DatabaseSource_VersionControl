SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Guidance].[GetW15]
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
				R.MemberID,
				RV.LastChangedDate,
				MBR.DateOfBirth,
				CASE WHEN ISNULL(MBR.DateOfBirth, 0) = ISNULL(MBR.OriginalDateOfBirth, 0) THEN '(Administrative)' ELSE '(Medical Record)' END AS DOBEdited,
				DATEADD(day, 90, DATEADD(month, 12, MBR.DateOfBirth)) AS Date15MonthsOld
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
	UNION
	SELECT	'Well-Care Visit Date Range' AS Title,
			dbo.ConvertDateToVarchar(DateOfBirth) + ' - ' + dbo.ConvertDateToVarchar(Date15MonthsOld) AS [Value],
			2.0 AS SortOrder
	FROM	ListBase
	UNION
	SELECT TOP 100 PERCENT
			W15.Descr AS Title,
			W15.ServiceDates AS Value,
			2 + (W15.SortOrder * 0.1) AS SortOrder
	FROM	ListBase AS LB
			CROSS APPLY dbo.GetW15ServiceDates(LB.MemberID) AS W15
	ORDER BY SortOrder, Title
)
GO
