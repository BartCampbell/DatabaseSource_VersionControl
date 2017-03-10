SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetFaxLogDetail]
(
	@CustomerProviderSiteID varchar(25) = NULL,
	@FaxLogDocID int = NULL,
	@FaxLogStatusID int = NULL,
	@FaxLogType char(1) = NULL,
	@MinLogDate datetime = NULL,
	@MaxLogDate datetime = NULL,
	@ProviderSiteName varchar(75) = NULL,
	@ProviderSiteAddress1 varchar(50) = NULL,  
	@ProviderSiteAddress2 varchar(50) = NULL,
	@ProviderSiteCity varchar(50) = NULL,
	@ProviderSiteState varchar(2) = NULL,
	@ProviderSiteZip varchar(9) = NULL,
	@ProviderSitePhone varchar(25) = NULL,
	@ProviderSiteFax varchar(25) = NULL,
	@ProviderSiteContact varchar(50) = NULL,
	@ProviderSiteCounty varchar(50) = NULL,
	@ProviderSiteTaxID varchar(11) = NULL	
)
AS
BEGIN
	SET NOCOUNT ON;

	SET @CustomerProviderSiteID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerProviderSiteID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteName, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteAddress1 = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteAddress1, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteAddress2 = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteAddress2, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteCity = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteCity, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteState = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteState, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteZip = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteZip, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSitePhone = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSitePhone, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteFax = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteFax, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteContact = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteContact, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteCounty = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteCounty, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderSiteTaxID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteTaxID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');

	WITH FaxLogRelationships AS
	(
		SELECT	FL.FaxLogID,
				ISNULL(FL.OriginalFaxLogID, FaxLogID) AS OriginalFaxLogID
		FROM	dbo.FaxLog AS FL WITH(NOLOCK)
	)
	SELECT	t.OriginalFaxLogID AS IMIRefNumber,
			MIN(FL.FaxLogDocID) AS FaxLogDocID,
			MIN(FLD.[Description]) AS FaxLogDocDescription,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.CreatedDate END) AS SentCreatedDate,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.CreatedUser END) AS SentCreatedUser,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.LastChangedDate END) AS SentLastChangedDate,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.LastChangedUser END) AS SentLastChangedUser,
			MIN(CASE FL.FaxLogType WHEN 'R' THEN FL.CreatedDate END) AS ReceivedCreatedDate,
			MIN(CASE FL.FaxLogType WHEN 'R' THEN FL.CreatedUser END) AS ReceivedCreatedUser,
			MIN(CASE FL.FaxLogType WHEN 'R' THEN FL.LastChangedDate END) AS ReceivedLastChangedDate,
			MIN(CASE FL.FaxLogType WHEN 'R' THEN FL.LastChangedUser END) AS ReceivedLastChangedUser,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.LogDate END) AS SentLogDate, 
			MIN(CASE FL.FaxLogType WHEN 'R' THEN FL.LogDate END) AS ReceivedLogDate, 
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.Contact END) AS FaxLogContact,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.Phone END) AS FaxLogPhone,
			MIN(CASE FL.FaxLogType WHEN 'S' THEN FL.Fax END) AS FaxLogFax, 
			FL.ProviderSiteID,
			MIN(PS.CustomerProviderSiteID) AS CustomerProviderSiteID,
			MIN(PS.ProviderSiteName) AS ProviderSiteName,
			MIN(PS.Address1) AS ProviderSiteAddress1,
			MIN(PS.Address2) AS ProviderSiteAddress2,
			MIN(PS.City) AS ProviderSiteAddressCity,
			MIN(PS.County) AS ProviderSiteAddressCounty,
			MIN(PS.[State]) AS ProviderSiteAddressState,
			MIN(PS.Zip) AS ProviderSiteAddressZip,
			MIN(PS.Contact) AS ProviderSiteContact,
			MIN(PS.Fax) AS ProviderSiteFax,
			MIN(PS.Phone) AS ProviderSitePhone,
			MIN(PS.TaxID) AS ProviderSiteTaxID,
			MAX(DISTINCT CASE WHEN FL.FaxLogType = 'R'  AND FLS.IsReceived = 0 THEN 1 ELSE 0 END) AS IsOpenReceived,
			MAX(DISTINCT CASE WHEN FL.FaxLogType = 'S' AND FLS.IsSent = 0 THEN 1 ELSE 0 END) AS IsOpenSent,
			MAX(DISTINCT CASE WHEN FL.FaxLogType = 'R'  AND FLS.IsReceived = 1 THEN 1 ELSE 0 END) AS IsReceived,
			MAX(DISTINCT CASE WHEN FL.FaxLogType = 'S' AND FLS.IsSent = 1 THEN 1 ELSE 0 END) AS IsSent,
			COUNT(DISTINCT CASE WHEN FLP.Selected = 1 AND FL.FaxLogType = 'R' THEN FLP.PursuitID END) AS CountPursuitReceived,
			COUNT(DISTINCT CASE WHEN FLP.Selected = 1 AND FL.FaxLogType = 'S' AND FLS.IsSent = 1 THEN FLP.PursuitID END) - COUNT(DISTINCT CASE WHEN FLP.Selected = 1 AND FL.FaxLogType = 'R' AND FLS.IsReceived = 1 THEN FLP.PursuitID END) AS CountPursuitNotReceived,
			COUNT(DISTINCT CASE WHEN FLP.Selected = 1 AND FL.FaxLogType = 'S' AND FLS.IsSent = 1 THEN FLP.PursuitID END) AS CountPursuitSent
	FROM	dbo.FaxLog AS FL WITH(NOLOCK)
			INNER JOIN FaxLogRelationships AS t
					ON t.FaxLogID = FL.FaxLogID
			INNER JOIN dbo.FaxLogPursuits AS FLP WITH(NOLOCK)
					ON FLP.FaxLogID = FL.FaxLogID
			INNER JOIN dbo.FaxLogDocument AS FLD WITH(NOLOCK)
					ON FLD.FaxLogDocID = FL.FaxLogDocID
			INNER JOIN dbo.FaxLogStatus AS FLS WITH(NOLOCK)
					ON FLS.FaxLogStatusID = FL.FaxLogStatusID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = FL.ProviderSiteID
	WHERE	((@FaxLogDocID IS NULL) OR (FL.FaxLogDocID = @FaxLogDocID)) AND
			((@FaxLogStatusID IS NULL) OR (FL.FaxLogStatusID = @FaxLogStatusID)) AND
			((@FaxLogType IS NULL) OR (FL.FaxLogType = @FaxLogType)) AND
			((@CustomerProviderSiteID IS NULL) OR (PS.CustomerProviderSiteID = @CustomerProviderSiteID) OR (PS.CustomerProviderSiteID LIKE @CustomerProviderSiteID)) AND 
			((@ProviderSiteName IS NULL) OR (PS.ProviderSiteName = @ProviderSiteName) OR (PS.ProviderSiteName LIKE @ProviderSiteName)) AND 
			((@ProviderSiteAddress1 IS NULL) OR (PS.Address1 = @ProviderSiteAddress1) OR (PS.Address1 LIKE @ProviderSiteAddress1)) AND 
			((@ProviderSiteAddress2 IS NULL) OR (PS.Address2 = @ProviderSiteAddress2) OR (PS.Address2 LIKE @ProviderSiteAddress2)) AND 
			((@ProviderSiteCity IS NULL) OR (PS.City = @ProviderSiteCity) OR (PS.City LIKE @ProviderSiteCity)) AND 
			((@ProviderSiteState IS NULL) OR (PS.[State] = @ProviderSiteState) OR (PS.[State] LIKE @ProviderSiteState)) AND 
			((@ProviderSiteZip IS NULL) OR (PS.Zip = @ProviderSiteZip) OR (PS.Zip LIKE @ProviderSiteZip)) AND 
			((@ProviderSitePhone IS NULL) OR (PS.Phone = @ProviderSitePhone) OR (PS.Phone LIKE @ProviderSitePhone)) AND 
			((@ProviderSiteFax IS NULL) OR (PS.Fax = @ProviderSiteFax) OR (PS.Fax LIKE @ProviderSiteFax)) AND 
			((@ProviderSiteContact IS NULL) OR (PS.Contact = @ProviderSiteContact) OR (PS.Contact LIKE @ProviderSiteContact)) AND 
			((@ProviderSiteCounty IS NULL) OR (PS.County = @ProviderSiteCounty) OR (PS.County LIKE @ProviderSiteCounty)) AND
			((@ProviderSiteTaxID IS NULL) OR (PS.TaxID = @ProviderSiteTaxID) OR (PS.TaxID LIKE @ProviderSiteTaxID)) AND
			(FL.LogDate BETWEEN ISNULL(@MinLogDate, FL.LogDate) AND ISNULL(@MaxLogDate, FL.LogDate))
	GROUP BY FL.ProviderSiteID,
			FL.FaxLogDocID,
			t.OriginalFaxLogID
	ORDER BY 1;

END

GO
GRANT EXECUTE ON  [Report].[GetFaxLogDetail] TO [Reporting]
GO
