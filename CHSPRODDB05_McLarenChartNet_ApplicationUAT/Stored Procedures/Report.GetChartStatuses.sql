SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetChartStatuses]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All Statuses)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	'None' AS Descr,    
				-1 AS ID  
		UNION
		SELECT DISTINCT
				ISNULL(CSVP.Title + ': ', '') + CSV.Title AS Descr,
				CSV.ChartStatusValueID AS ID
		FROM	dbo.ChartStatusValue AS CSV WITH(NOLOCK)
				LEFT OUTER JOIN dbo.ChartStatusValue AS CSVP WITH(NOLOCK)
						ON CSVP.ChartStatusValueID = CSV.ParentID
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY ID
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END


GO
GRANT EXECUTE ON  [Report].[GetChartStatuses] TO [Reporting]
GO
