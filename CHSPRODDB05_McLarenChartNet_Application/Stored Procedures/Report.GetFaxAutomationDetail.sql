SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetFaxAutomationDetail]
(
	@FaxLogID int = NULL,
	@FaxLogSubID int = NULL
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
				REPLACE(MIN(CASE WHEN ParamName = 'FaxAutomation_MailAddress' THEN ISNULL(ParamCharValue, CONVERT(nvarchar(256), ParamIntValue)) END), CHAR(13) + CHAR(10), '<br />') AS FaxAutomation_MailAddress,
				CONVERT(bit, ISNULL(MIN(CASE WHEN ParamName = 'FaxAutomation_AllowMailRequest' THEN ParamIntValue END), 1)) AS FaxAutomation_AllowMailRequest
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
			SP.Client,
			SP.MeasureYear,
			SP.ReportYear,
			SP.FaxAutomation_Administrator,
			SP.FaxAutomation_AdminContact,
			SP.FaxAutomation_LogoImage,
			SP.FaxAutomation_PhoneNumber,
			SP.FaxAutomation_FaxNumber,
			CASE WHEN SP.FaxAutomation_AllowMailRequest = 1 THEN  SP.FaxAutomation_MailAddress ELSE '<strong>*** DO NOT MAIL ***</strong><br /><em>' + SP.Client + '</em> does not permit mailing records.' END AS FaxAutomation_MailAddress,
			PursuitNumber,
			CustomerMemberID,
			MBR.NameLast,
			MBR.NameFirst,
			MBR.DateOfBirth,
			NameEntityFullName,
			AbstractorName,
			HEDISMeasure,
			HEDISMeasureDescription,
			DischargeDate,
			PPCDeliveryDate,
			FMC.FaxMeasureInstruction,
			RTRIM(MBR.NameLast) + ', ' + RTRIM(MBR.NameFirst) AS MemberFullName,
			ISNULL(dischargedate, ppcdeliverydate) DischargeOrDeliveryDate
	FROM    dbo.FaxLog AS FL WITH(NOLOCK)
			INNER JOIN dbo.FaxLogPursuits AS FLP WITH(NOLOCK)
					ON FLP.FaxLogID = FL.FaxLogID
			INNER JOIN dbo.Pursuit AS R WITH(NOLOCK)
					ON R.PursuitID = FLP.PursuitID AND
						R.ProviderSiteID = FL.ProviderSiteID
			INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON RV.PursuitID = R.PursuitID
			INNER JOIN dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
					ON MMS.EventDate = RV.EventDate AND
						MMS.MeasureID = RV.MeasureID AND
						MMS.MemberID = R.MemberID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON MBR.MemberID = R.MemberID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = FL.ProviderSiteID
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON M.MeasureID = RV.MeasureID
			INNER JOIN dbo.FaxMeasureContent AS FMC WITH(NOLOCK)
					ON FMC.MeasureID = RV.MeasureID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON A.AbstractorID = R.AbstractorID
			INNER JOIN dbo.Providers AS P WITH(NOLOCK)
					ON P.ProviderID = R.ProviderID
			CROSS JOIN SystemParams AS SP
	WHERE   ((@FaxLogSubID IS NULL) OR (FL.FaxLogID  IN (SELECT FLS.FaxLogID FROM dbo.FaxLogSubmissions AS FLS WITH(NOLOCK) WHERE FLS.FaxLogSubID = @FaxLogSubID))) AND
			((@FaxLogID IS NULL) OR (FL.FaxLogID = @FaxLogID)) AND
			((@FaxLogID IS NOT NULL) OR (@FaxLogSubID IS NOT NULL) OR (1 = 2)) AND --Prevent all rows from returning if both parameters are NULL
			(FLP.Selected = 1);

	-------------------------------------------------------------------------------------------------------------------------------
	--Added for Fax Log Submission sample SSRS report...
	IF @FaxLogSubID IS NOT NULL
		BEGIN;
			EXEC dbo.MarkReadyFaxLogSubmission @FaxLogSubID = @FaxLogSubID;
		END;
	-------------------------------------------------------------------------------------------------------------------------------
END
GO
GRANT EXECUTE ON  [Report].[GetFaxAutomationDetail] TO [Reporting]
GO
