SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractionStatuses]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;

	WITH Results AS
	(
		SELECT	'(All Statuses)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	[Description] AS Descr,
				AbstractionStatusID AS ID
		FROM	dbo.AbstractionStatus WITH(NOLOCK)
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY ID
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));    
    
END

GO
GRANT EXECUTE ON  [Report].[GetAbstractionStatuses] TO [Reporting]
GO
