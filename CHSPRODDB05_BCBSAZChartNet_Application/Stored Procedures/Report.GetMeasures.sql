SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMeasures]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Measures)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	M.HEDISMeasure AS Abbrev,
				M.HEDISMeasure + ' - ' + HEDISMeasureDescription AS Descr,
				M.MeasureID AS ID
		FROM	dbo.Measure AS M WITH(NOLOCK)
		WHERE	M.MeasureID IN (SELECT MeasureID FROM dbo.MeasureComponent AS MC WITH(NOLOCK) WHERE EnabledOnWebsite = 1) AND
				M.MeasureID IN (SELECT DISTINCT MeasureID FROM dbo.MemberMeasureSample WITH(NOLOCK))
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END

GO
GRANT EXECUTE ON  [Report].[GetMeasures] TO [Reporting]
GO
