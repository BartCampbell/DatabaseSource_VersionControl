SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractors]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;
	
	WITH Results AS
	(
		SELECT	'(All Abstractors)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	'(Unassigned)' AS Descr,
				CONVERT(int, -1) AS ID
		UNION
		SELECT	AbstractorName AS Descr,
				AbstractorID AS ID
		FROM	dbo.Abstractor WITH(NOLOCK)
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION (OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END
GO
GRANT EXECUTE ON  [Report].[GetAbstractors] TO [Reporting]
GO
