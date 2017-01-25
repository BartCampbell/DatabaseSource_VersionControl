SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractionReviewStatuses]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Statuses)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	[Description] AS Abbrev,
				[Description] AS Descr,
				AbstractionReviewStatusID AS ID
		FROM	dbo.AbstractionReviewStatus WITH(NOLOCK)
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetAbstractionReviewStatuses] TO [Reporting]
GO
