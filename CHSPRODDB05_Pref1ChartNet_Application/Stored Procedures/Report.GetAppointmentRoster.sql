SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAppointmentRoster]
(
	@AbstractorID int = NULL,
	@MinAppointmentDate datetime = NULL,
	@MaxAppointmentDate datetime = NULL,
	@AppointmentID int = NULL,
	@AppointmentStatusID int = NULL,
	@AppointmentTimeframeID int = NULL,
	-----------------------------------------------
	@CustomerProviderID varchar(25) = NULL,
	@ProviderName varchar(25) = NULL,
	@ProviderTaxID varchar(11) = NULL,
	-----------------------------------------------
	@CustomerProviderSiteID varchar(25) = NULL,
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
	-----------------------------------------------
	@FilterOnUserName bit = 0,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	--Based on Report.GetAbstractionRoster

	DECLARE @WebAddress nvarchar(512);
	SELECT @WebAddress = ParamCharValue FROM dbo.SystemParams WITH(NOLOCK) WHERE ParamName = 'WebAddress';

	IF @WebAddress IS NOT NULL AND RIGHT(@WebAddress, 1) <> '/'
		SET @WebAddress = @WebAddress + '/';

	SET @CustomerProviderID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerProviderID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderName, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProviderTaxID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderTaxID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
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

	SELECT	AST.[Description] AS AbstractionStatusDescr,
			AST.AbstractionStatusID,
			ISNULL(A.AbstractorID, -1) AS AbstractorID,
			ISNULL(A.AbstractorName, '(Unassigned)') AS AbstractorName,
			APPT.AppointmentDate,
			APPT.AppointmentDateTime,
			APPT.AppointmentNote,
			APPT.AppointmentID,
			'' AS AppointmentNote1,
			'' AS AppointmentNote2,
			ISNULL(CSV.Title, 'No Status') AS ChartStatusTitle,
			CSV.ChartStatusValueID,
			dbo.GetCurrentClient() AS CurrentClient,
			MBR.CustomerMemberID,
			P.CustomerProviderID,
			PS.CustomerProviderSiteID,
			M.HEDISMeasure AS MeasureAbbrev,
			M.HEDISMeasureDescription AS MeasureDescr,
			M.MeasureID,
			M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription AS MeasureLongDescr,
			MBR.DateOfBirth AS MemberDOB,
			MBR.Gender AS MemberGender,
			R.MemberID,
			MBR.NameFirst AS MemberNameFirst,
			MBR.NameLast AS MemberNameLast,
			MBR.NameMiddleInitial AS MemberNameMid,
			MBR.Product AS MemberProduct,
			MBR.ProductLine AS MemberProductLine,
			RV.NoDataFoundReason,
			R.ProviderID,
			ISNULL(P.NameEntityFullName, ISNULL(NULLIF(RTRIM(P.NameLast + ISNULL(', ' + P.NameFirst, '')), ''), '(no name listed)')) AS ProviderName,
			PS.Address1 AS ProviderSiteAddress1,
			PS.Address2 AS ProviderSiteAddress2,
			PS.City AS ProviderSiteAddressCity,
			PS.County AS ProviderSiteAddressCounty,
			PS.[State] AS ProviderSiteAddressState,
			PS.Zip AS ProviderSiteAddressZip,
			PS.Contact AS ProviderSiteContact,
			PS.Fax AS ProviderSiteFax,
			R.ProviderSiteID,
			PS.ProviderSiteName,
			PS.Phone AS ProviderSitePhone,		
			ISNULL(P.TaxID, PS.TaxID) AS ProviderTaxID,
			RV.PursuitEventID,
			RV.PursuitEventStatus,
			R.PursuitID,
			R.PursuitNumber,
			'###-##-' + RIGHT(MBR.SSN, 4) AS SSN,
			@WebAddress + 'AbstractionSummary.aspx?id=' + CONVERT(nvarchar(512), RV.PursuitEventID) AS WebAddress
	FROM	dbo.Pursuit AS R WITH(NOLOCK)
			INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON R.PursuitID = RV.PursuitID
			INNER JOIN dbo.ProviderSiteAppointment AS PSA WITH(NOLOCK)
					ON PSA.ProviderSiteID = R.ProviderSiteID
			INNER JOIN dbo.Appointment AS APPT WITH(NOLOCK)
					ON APPT.AppointmentID = PSA.AppointmentID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON R.MemberID = MBR.MemberID
			INNER JOIN dbo.Providers AS P WITH(NOLOCK)
					ON R.ProviderID = P.ProviderID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON R.ProviderSiteID = PS.ProviderSiteID
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON RV.MeasureID = M.MeasureID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON A.AbstractorID = APPT.AbstractorID
			LEFT OUTER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
					ON RV.AbstractionStatusID = AST.AbstractionStatusID
			LEFT OUTER JOIN dbo.ChartStatusValue AS CSV WITH(NOLOCK)
					ON RV.ChartStatusValueID = CSV.ChartStatusValueID
			OUTER APPLY (
							SELECT * FROM dbo.AppointmentStandardTimeframes WITH(NOLOCK) WHERE ID = @AppointmentTimeframeID
						) APPTSTF
	WHERE	((@AbstractorID IS NULL) OR (R.AbstractorID = @AbstractorID) OR (R.AbstractorID IS NULL AND @AbstractorID = -1)) AND
			((@AppointmentID IS NULL) OR (APPT.AppointmentID = @AppointmentID)) AND
			(APPT.AppointmentDate BETWEEN ISNULL(@MinAppointmentDate, APPT.AppointmentDate) AND ISNULL(@MaxAppointmentDate, APPT.AppointmentDate)) AND
			((@AppointmentTimeframeID IS NULL) OR (APPT.AppointmentDate BETWEEN APPTSTF.StartDate AND APPTSTF.EndDate)) AND
			((@AppointmentStatusID IS NULL) OR (APPT.AppointmentStatusID = @AppointmentStatusID)) AND
			------------------------------------------------------------------------------------------------------------------------
			((@CustomerProviderID IS NULL) OR (P.CustomerProviderID = @CustomerProviderID) OR (P.CustomerProviderID LIKE @CustomerProviderID)) AND 
			((@ProviderName IS NULL) OR (P.NameEntityFullName = @ProviderName) OR (P.NameEntityFullName LIKE @ProviderName) OR (P.NameLast = @ProviderName) OR (P.NameLast LIKE @ProviderName)) AND 
			((@ProviderTaxID IS NULL) OR (P.TaxID = @ProviderTaxID) OR (P.TaxID LIKE @ProviderTaxID) OR (PS.TaxID = @ProviderTaxID) OR (PS.TaxID LIKE @ProviderTaxID)) AND 
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
			------------------------------------------------------------------------------------------------------------------------
			(
				(@UserName IS NULL) OR 
				(ISNULL(@FilterOnUserName, 0) = 0) OR 
				(A.UserName = @UserName) 
			) 
	ORDER BY MeasureAbbrev, MemberNameLast, MemberNameFirst, MemberNameMid, MemberDOB
	OPTION (OPTIMIZE FOR UNKNOWN);

END

GO
GRANT EXECUTE ON  [Report].[GetAppointmentRoster] TO [Reporting]
GO
