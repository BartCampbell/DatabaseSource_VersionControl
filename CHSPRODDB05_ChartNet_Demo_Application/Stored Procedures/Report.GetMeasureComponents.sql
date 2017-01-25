SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMeasureComponents]
(
	@IncludeAllOption bit = 1,
	@MeasureID int = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Measure Components)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	MC.ComponentName AS Abbrev,
				M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription + ': ' + MC.Title AS Descr,
				MC.MeasureComponentID AS ID
		FROM	dbo.Measure AS M WITH(NOLOCK)
				INNER JOIN dbo.MeasureComponent AS MC WITH(NOLOCK)
						ON MC.MeasureID = M.MeasureID
		WHERE	(MC.EnabledOnWebsite = 1) AND
				((@MeasureID IS NULL) OR (MC.MeasureID = @MeasureID)) AND
				(M.MeasureID IN (SELECT DISTINCT MeasureID FROM dbo.MemberMeasureSample WITH(NOLOCK)))
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetMeasureComponents] TO [Reporting]
GO
