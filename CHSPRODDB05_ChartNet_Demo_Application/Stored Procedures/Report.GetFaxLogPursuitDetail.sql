SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetFaxLogPursuitDetail]
(
	@CustomerProviderSiteID varchar(25) = NULL,
	@FaxLogDocID int = NULL,
	@MinLogDate datetime = NULL,
	@MaxLogDate datetime = NULL,
	@PursuitNumber varchar(25) = NULL,
	@CustomerMemberID varchar(25) = NULL,
	@ShowReceivedOnly bit = NULL,
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

	SET @PursuitNumber = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@PursuitNumber, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @CustomerMemberID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerMemberID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
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

	WITH FaxLogAndPursuits AS 
	(
		SELECT	FL.FaxLogID,
				FL.FaxLogType,
				FL.FaxLogStatusID,
				FL.OriginalFaxLogID,
				FL.LogDate,
				FL.FaxLogDocID,
				FL.Instructions,
				FL.ProviderSiteID,
				FL.Comments,
				FL.Phone,
				FL.Fax,
				FL.Contact,
				FL.CreatedDate,
				FL.CreatedUser,
				FL.LastChangedDate,
				FL.LastChangedUser,
				FLP.PursuitID,
				FLP.Selected
		FROM	dbo.FaxLog AS FL WITH(NOLOCK)
				INNER JOIN dbo.FaxLogPursuits AS FLP WITH(NOLOCK)
						ON FLP.FaxLogID = FL.FaxLogID
				INNER JOIN dbo.FaxLogStatus AS FLS WITH(NOLOCK)
						ON FLS.FaxLogStatusID = FL.FaxLogStatusID
		WHERE	FLS.IsSent = 1 OR FLS.IsReceived = 1
	)
	SELECT	CONVERT(varchar(32), FLAPS.FaxLogID + 10000) + '-' + ISNULL(CONVERT(varchar(32), FLAPR.FaxLogID + 10000), '00000') AS IMIRefNumber,
			FLAPS.FaxLogDocID,
			FLD.[Description] AS FaxLogDocDescription,
			PS.ProviderSiteID,
			PS.CustomerProviderSiteID AS CustomerProviderSiteID,
			PS.ProviderSiteName AS ProviderSiteName,
			PS.Address1 AS ProviderSiteAddress1,
			PS.Address2 AS ProviderSiteAddress2,
			PS.City AS ProviderSiteAddressCity,
			PS.County AS ProviderSiteAddressCounty,
			PS.[State] AS ProviderSiteAddressState,
			PS.Zip AS ProviderSiteAddressZip,
			PS.Contact AS ProviderSiteContact,
			PS.Fax AS ProviderSiteFax,
			PS.Phone AS ProviderSitePhone,
			PS.TaxID AS ProviderSiteTaxID,
			MBR.MemberID,
			MBR.CustomerMemberID,
			MBR.NameLast + ISNULL(', ' + MBR.NameFirst, '') + ISNULL(' ' + MBR.NameMiddleInitial, '') AS MemberName,
			MBR.DateOfBirth,
			MBR.Gender,
			R.PursuitNumber,
			R.PursuitCategory,
			FLAPS.LogDate AS SentLogDate,
			FLAPR.LogDate AS ReceivedLogDate,
			CASE FLAPS.Selected WHEN 1 THEN 'Y' ELSE 'N' END AS IsPursuitInSend,
			CASE ISNULL(FLAPR.Selected, 0) WHEN 1 THEN 'Y' ELSE 'N' END AS IsPursuitInReceive,
			CASE ISNULL(FLAPO.Selected, 0) WHEN 1 THEN 'Y' ELSE 'N' END AS IsPursuitInOtherReceive,
			FLAPS.CreatedDate AS SentCreatedDate,
			FLAPS.CreatedUser AS SentCreatedUser,
			FLAPS.LastChangedDate AS SentLastChangedDate,
			FLAPS.LastChangedUser AS SentLastChangedUser,
			FLAPR.CreatedDate AS ReceivedCreatedDate,
			FLAPR.CreatedUser AS ReceivedCreatedUser,
			FLAPR.LastChangedDate AS ReceivedLastChangedDate,
			FLAPR.LastChangedUser AS ReceivedLastChangedUser
	FROM	FaxLogAndPursuits AS FLAPS
			LEFT OUTER JOIN FaxLogAndPursuits AS FLAPR
					ON FLAPR.OriginalFaxLogID = FLAPS.FaxLogID AND
						FLAPR.PursuitID = FLAPS.PursuitID AND
						FLAPR.FaxLogType = 'R'
			OUTER APPLY	(
							SELECT TOP 1 
									tFLAP.Selected
							FROM	FaxLogAndPursuits AS tFLAP
							WHERE	(tFLAP.ProviderSiteID = FLAPS.ProviderSiteID) AND
									(tFLAP.PursuitID = FLAPS.PursuitID) AND
									(tFLAP.FaxLogType = 'R') AND
									(tFLAP.Selected = 1) AND
									(FLAPR.FaxLogID IS NULL OR tFLAP.FaxLogID <> FLAPR.FaxLogID)
						) AS FLAPO
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = FLAPS.ProviderSiteID
			INNER JOIN dbo.Pursuit AS R WITH(NOLOCK)
					ON R.PursuitID = FLAPS.PursuitID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON MBR.MemberID = R.MemberID
			INNER JOIN dbo.FaxLogDocument AS FLD WITH(NOLOCK)
					ON FLD.FaxLogDocID = FLAPS.FaxLogDocID
	WHERE	(FLAPS.FaxLogType = 'S') AND 
			(FLAPS.Selected = 1) AND
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
			((@FaxLogDocID IS NULL) OR (FLAPS.FaxLogDocID = @FaxLogDocID)) AND
			((@CustomerMemberID IS NULL) OR (MBR.CustomerMemberID = @CustomerMemberID) OR (MBR.CustomerMemberID LIKE @CustomerMemberID)) AND
			((@PursuitNumber IS NULL) OR (R.PursuitNumber = @PursuitNumber) OR (R.PursuitNumber LIKE @PursuitNumber)) AND
			(
				(FLAPS.LogDate BETWEEN ISNULL(@MinLogDate, FLAPS.LogDate) AND ISNULL(@MaxLogDate, FLAPS.LogDate)) OR
				(FLAPR.LogDate BETWEEN ISNULL(@MinLogDate, FLAPR.LogDate) AND ISNULL(@MaxLogDate, FLAPR.LogDate))
			) AND
			((@ShowReceivedOnly IS NULL) OR (@ShowReceivedOnly = 1 AND FLAPR.Selected = 1) OR (@ShowReceivedOnly = 0 AND (FLAPR.Selected = 0 OR FLAPR.Selected IS NULL)))
	ORDER BY 1, MemberName, CustomerMemberID, PursuitNumber;

END

GO
GRANT EXECUTE ON  [Report].[GetFaxLogPursuitDetail] TO [Reporting]
GO
