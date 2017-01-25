SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractionReviewSets]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Review Sets)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	'(Most Recent)' AS Abbrev,
				'(Most Recent Review Set)' AS Descr,
				CONVERT(int, -1) AS ID
		UNION
		SELECT	dbo.ConvertDateToYYYYMMDD(EndDate) + '?' + dbo.ConvertDateToYYYYMMDD(StartDate) + '|' + CreatedUser AS Abbrev,
				CONVERT(varchar(128), Description + ', ' + dbo.ConvertDateToVarchar(StartDate) + ' - ' + dbo.ConvertDateToVarchar(EndDate) + ', By: ' + CreatedUser) AS Descr,
				AbstractionReviewSetID AS ID
		FROM	dbo.AbstractionReviewSet WITH(NOLOCK)
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY CASE WHEN ID IS NULL THEN 1 WHEN ID = -1 THEN 2 ELSE 3 END, Abbrev DESC
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetAbstractionReviewSets] TO [Reporting]
GO
