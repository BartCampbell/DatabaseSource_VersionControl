SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProviderSites]
(
	@IncludeAllOption bit = 1
)
AS
BEGIN

	SET NOCOUNT ON;
	
	WITH Results AS
	(
		SELECT	'(All Provider Sites)' AS Descr,
				CONVERT(int, NULL) AS ID
		UNION
		SELECT	PS.CustomerProviderSiteID + ' - ' + PS.ProviderSiteName AS Descr,
				PS.ProviderSiteID AS ID
		FROM	dbo.ProviderSite AS PS WITH(NOLOCK)
		WHERE	(PS.ProviderSiteName <> '')
    )
    SELECT	*
    FROM	Results
    WHERE	((@IncludeAllOption = 1) OR (ID IS NOT NULL))
    ORDER BY Descr
    OPTION	(OPTIMIZE FOR (@IncludeAllOption = 1));
	
END


GO
GRANT EXECUTE ON  [Report].[GetProviderSites] TO [Reporting]
GO
