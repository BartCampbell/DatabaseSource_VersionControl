SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Report].[GetFaxAutomationCoverPage]
(
	@FaxLogSubID int
)
AS
BEGIN
	SET NOCOUNT ON;

    WITH SystemParams AS
	(
		SELECT	MIN(CASE WHEN ParamName = 'CurrentClient' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS Client,
				MIN(CASE WHEN ParamName = 'MeasureYear' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS MeasureYear,
				MIN(CASE WHEN ParamName = 'MeasureYear' THEN ISNULL(CONVERT(nvarchar(256), CONVERT(smallint, ParamCharValue) + 1), CONVERT(nvarchar(256), ParamIntValue + 1)) END) AS ReportYear,
				MIN(CASE WHEN ParamName = 'FaxAutomation_Administrator' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_Administrator,
				MIN(CASE WHEN ParamName = 'FaxAutomation_AdminContact' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_AdminContact,
				MIN(CASE WHEN ParamName = 'FaxAutomation_LogoImage' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_LogoImage,
				MIN(CASE WHEN ParamName = 'FaxAutomation_PhoneNumber' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_PhoneNumber,
				MIN(CASE WHEN ParamName = 'FaxAutomation_FaxNumber' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_FaxNumber,
				MIN(CASE WHEN ParamName = 'FaxAutomation_Email' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END) AS FaxAutomation_Email,
				REPLACE(MIN(CASE WHEN ParamName = 'FaxAutomation_MailAddress' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END), CHAR(13) + CHAR(10), '<br />') AS FaxAutomation_MailAddress
		FROM	dbo.SystemParams WITH(NOLOCK)
		WHERE	(
					(ClientName IS NULL) OR	
					(ClientName = dbo.GetCurrentClient())
				) AND
				(
					(ParamName IN ('MeasureYear', 'CurrentClient')) OR
					(ParamName LIKE 'FaxAutomation[_]%')
				)
	)
	SELECT  PS.CustomerProviderSiteID,
			PS.ProviderSiteID,
			PS.ProviderSiteName,
			FL.Phone AS ProviderSitePhone,
			FL.Fax AS ProviderSiteFax,
			FL.Contact AS ProviderSiteContact,
			FL.Instructions,
			SP.Client,
			SP.MeasureYear,
			SP.ReportYear,
			SP.FaxAutomation_Administrator,
			SP.FaxAutomation_AdminContact,
			SP.FaxAutomation_LogoImage,
			SP.FaxAutomation_PhoneNumber,
			SP.FaxAutomation_FaxNumber,
			SP.FaxAutomation_Email,
			SP.FaxAutomation_MailAddress
	FROM    dbo.FaxLogSubmissions AS FLS WITH(NOLOCK)
			INNER JOIN dbo.FaxLog AS FL WITH(NOLOCK)
					ON FL.FaxLogID = FLS.FaxLogID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = FL.ProviderSiteID
			CROSS JOIN SystemParams AS SP
	WHERE   FLS.FaxLogSubID = @FaxLogSubID;

	-------------------------------------------------------------------------------------------------------------------------------
	--Added for Fax Log Submission sample SSRS report...
	IF @FaxLogSubID IS NOT NULL
		BEGIN;
			EXEC dbo.MarkReadyFaxLogSubmission @FaxLogSubID = @FaxLogSubID;
		END;
	-------------------------------------------------------------------------------------------------------------------------------
END


GO
GRANT EXECUTE ON  [Report].[GetFaxAutomationCoverPage] TO [Reporting]
GO
