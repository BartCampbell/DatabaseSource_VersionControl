SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProviders]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;
	
	WITH Results AS
	(
		SELECT	'(All Providers)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	P.CustomerProviderID + ' - ' + P.NameEntityFullName AS Descr,
				P.ProviderID AS ID
		FROM	dbo.Providers AS P WITH(NOLOCK)
		WHERE	(NameEntityFullName <> '')
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetProviders] TO [Reporting]
GO
