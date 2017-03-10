SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProviderSiteNames]
AS
BEGIN

    SET NOCOUNT ON;
	
    SELECT  '(All Provider Sites)' AS Descr,
            CONVERT(int, NULL) AS ID
    UNION
    SELECT  PS.ProviderSiteName AS Descr,
            PS.ProviderSiteID AS ID
    FROM    dbo.ProviderSite AS PS WITH(NOLOCK)
    WHERE   (PS.ProviderSiteName <> '')
    ORDER BY Descr
	
END


GO
GRANT EXECUTE ON  [Report].[GetProviderSiteNames] TO [Reporting]
GO
