SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Guidance].[GetFPC]
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
				t.*
		FROM	dbo.Pursuit AS R
				INNER JOIN dbo.PursuitEvent AS RV
						ON R.PursuitID = RV.PursuitID
				OUTER APPLY (SELECT TOP 1 * FROM dbo.GetFPCDateRanges(R.MemberID) AS tA WHERE tA.MeasureID = RV.MeasureID AND tA.EventDate = RV.EventDate) AS t
		WHERE	RV.PursuitEventID = @PursuitEventID  
	)
	SELECT	'Delivery Date' AS Title,
			dbo.ConvertDateToVarchar(AdminDeliveryDate) + ' (Administrative)' + COALESCE(', ' + dbo.ConvertDateToVarchar(MRDeliveryDate) + ' (Medical Record)', '') AS [Value],
			1.0 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Prenatal Qualifying Date Range' AS Title,
			dbo.ConvertDateToVarchar(LastSegBeginDate) + ' - ' + dbo.ConvertDateToVarchar(DeliveryDate) AS [Value],
			2.0 AS SortOrder
	FROM	ListBase
	UNION
	SELECT	'Expected Number of Visits' AS Title,
			CONVERT(varchar, CountExpected) AS [Value],
			3.0 AS SortOrder
	FROM	ListBase
)
GO
