SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetReviewers]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All Reviewers)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	'(Unassigned)' AS Descr,
				CONVERT(int, -1) AS ID
		UNION
		SELECT	ReviewerName AS Descr,
				ReviewerID AS ID
		FROM	dbo.Reviewer WITH(NOLOCK)
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));
    
END
GO
GRANT EXECUTE ON  [Report].[GetReviewers] TO [Reporting]
GO
