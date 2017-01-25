SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetFaxLogTypes]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Types)' AS Descr,
				CONVERT(char(1), NULL) AS ID,
				1 AS SortOrder
		UNION
		SELECT	[Description] AS Abbrev,
				[Description] AS Descr,
				FaxLogType AS ID,
				2 AS SortOrder
		FROM	dbo.FaxLogTypes WITH(NOLOCK)
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY SortOrder, Descr DESC
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END

GO
GRANT EXECUTE ON  [Report].[GetFaxLogTypes] TO [Reporting]
GO
