SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProducts]
(
	@IncludeAllOption bit = 1,
	@ProductLine varchar(20) = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Products AS
	(  
		SELECT DISTINCT Product, ProductLine FROM dbo.Member WITH(NOLOCK)
		UNION
		SELECT DISTINCT Product, ProductLine FROM dbo.MemberMeasureSample WITH(NOLOCK)    
	),
	Results AS
	(
		SELECT	'(All)' AS Abbrev,
				'(All Products)' AS Descr,
				CONVERT(varchar(20), NULL) AS ID
		UNION
		SELECT	Product AS Abbrev,
				Product AS Descr,
				Product AS ID
		FROM	Products
		WHERE	((@ProductLine IS NULL) OR (ProductLine = @ProductLine))
	)
	SELECT	*
	FROM	Results
	WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetProducts] TO [Reporting]
GO
