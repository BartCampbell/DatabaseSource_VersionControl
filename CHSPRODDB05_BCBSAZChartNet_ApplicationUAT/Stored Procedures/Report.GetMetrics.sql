SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMetrics]
(
	@IncludeAllOption bit = 1,
	@MeasureID int = NULL,
	@ShowMeasureAbbrev bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				--'2' AS Descr2,
				'(All Metrics)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	X.HEDISSubMetricCode AS Abbrev,
				CASE WHEN @ShowMeasureAbbrev = 1 THEN X.HEDISMeasureInit + ', ' ELSE '' END +
				--CASE WHEN X.HEDISSubMetricCode = X.DisplayName AND
				--		  X.HEDISSubMetricCode = X.HEDISMeasureInit
				--	 THEN 'Numerator' 
				--	 ELSE X.DisplayName 
				--	 END AS Descr2,
				X.ReportName AS Descr,
				X.HEDISSubMetricID AS ID
		FROM	dbo.Measure AS M WITH(NOLOCK)
				INNER JOIN dbo.HEDISSubMetric AS X WITH(NOLOCK)
						ON M.MeasureID = X.MeasureID
		WHERE	M.MeasureID IN (SELECT MeasureID FROM dbo.MeasureComponent AS MC WITH(NOLOCK) WHERE EnabledOnWebsite = 1) AND
				M.MeasureID IN (SELECT DISTINCT MeasureID FROM dbo.MemberMeasureSample WITH(NOLOCK)) AND
				X.DisplayInScoringPanel = 1 AND
				((@MeasureID IS NULL) OR (M.MeasureID = @MeasureID))
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Abbrev, Descr
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1, @MeasureID = NULL, @ShowMeasureAbbrev = 1));
	
END

GO
GRANT EXECUTE ON  [Report].[GetMetrics] TO [Reporting]
GO
