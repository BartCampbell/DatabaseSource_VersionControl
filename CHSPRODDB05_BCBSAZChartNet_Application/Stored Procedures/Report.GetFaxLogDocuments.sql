SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetFaxLogDocuments]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Document Types)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	[Description] AS Abbrev,
				[Description] AS Descr,
				FaxLogDocID AS ID
		FROM	dbo.FaxLogDocument WITH(NOLOCK)
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetFaxLogDocuments] TO [Reporting]
GO
