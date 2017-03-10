SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProviderNames]
AS
BEGIN

    SET NOCOUNT ON;
	
    SELECT  '(All Providers)' AS Descr,
            CONVERT(int, NULL) AS ID
    UNION
    SELECT  P.NameEntityFullName AS Descr,
            P.ProviderID AS ID
    FROM    dbo.Providers AS P WITH(NOLOCK)
    WHERE   (NameEntityFullName <> '')
    ORDER BY Descr
	
END


GO
GRANT EXECUTE ON  [Report].[GetProviderNames] TO [Reporting]
GO
