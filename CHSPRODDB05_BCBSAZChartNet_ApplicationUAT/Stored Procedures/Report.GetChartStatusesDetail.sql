SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetChartStatusesDetail]
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All Chart Status Descriptions)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT b.Title + ', ' + a.Title AS Descr, a.ChartStatusValueID AS ID
		FROM dbo.ChartStatusValue a WITH(NOLOCK)
		JOIN dbo.ChartStatusValue b WITH(NOLOCK) ON a.ParentID = b.ChartStatusValueID    
	)
    SELECT	*
    FROM	Results
    
END


GO
GRANT EXECUTE ON  [Report].[GetChartStatusesDetail] TO [Reporting]
GO
