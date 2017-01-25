SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProductLines]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH ProductLines AS
	(  
		SELECT DISTINCT ProductLine FROM dbo.Member WITH(NOLOCK)
		UNION
		SELECT DISTINCT ProductLine FROM dbo.MemberMeasureSample WITH(NOLOCK)    
	),
	Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Product Lines)' AS Descr,
				CONVERT(varchar(20), NULL) AS ID
		UNION
		SELECT	ProductLine AS Abbrev,
				ProductLine AS Descr,
				ProductLine AS ID
		FROM	ProductLines
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetProductLines] TO [Reporting]
GO
