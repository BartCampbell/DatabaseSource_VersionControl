SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetChangedSites]
(
	@LastChangedRangeStartDate datetime = NULL,
	@LastChangedRangeEndDate datetime = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

		
	IF @LastChangedRangeStartDate IS NULL
		SET @LastChangedRangeStartDate = 0;

	IF @LastChangedRangeEndDate IS NULL
		SET @LastChangedRangeEndDate = DATEADD(ss, 1, GETDATE());

	
	SELECT	PS.ProviderSiteID,
            PS.CustomerProviderSiteID,
            PS.ProviderSiteName,
			PS.OriginalAddress1,
            PS.OriginalAddress2,
            PS.OriginalCity,
            PS.OriginalState,
            PS.OriginalZip AS OriginalZipCode,
            PS.OriginalPhone,
            PS.OriginalFax,
            PS.OriginalContact,
            PS.OriginalCounty,
            PS.Address1 AS CurrentAddress1,
            PS.Address2 AS CurrentAddress2,
            PS.City AS CurrentCity,
            PS.[State] AS CurrentState,
            PS.Zip AS CurrentZipCode,
            PS.Phone AS CurrentPhone,
            PS.Fax AS CurrentFax,
            PS.Contact AS CurrentContact,
            PS.County AS CurrentCounty,
            PS.LastChangedDate,
            PS.LastChangedUser
	FROM	dbo.ProviderSite AS PS WITH(NOLOCK)
	WHERE	(PS.Changed = 1) AND
			(PS.LastChangedDate BETWEEN @LastChangedRangeStartDate AND @LastChangedRangeEndDate);
	
END

GO
GRANT EXECUTE ON  [Report].[GetChangedSites] TO [Reporting]
GO
