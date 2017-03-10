SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAppointmentListing]
(
	@AbstractorID int = NULL,
	@MinAppointmentDate datetime = NULL,
	@MaxAppointmentDate datetime = NULL,
	@AppointmentID int = NULL,
	@AppointmentStatusID int = NULL,
	@AppointmentTimeframeID int = NULL,
	-----------------------------------------------
	@ProviderSiteTaxID varchar(11) = NULL,
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

	DECLARE @WebAddress nvarchar(512);
	SELECT @WebAddress = ParamCharValue FROM dbo.SystemParams WITH(NOLOCK) WHERE ParamName = 'WebAddress';

	IF @WebAddress IS NOT NULL AND RIGHT(@WebAddress, 1) <> '/'
		SET @WebAddress = @WebAddress + '/';

	SET @ProviderSiteTaxID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProviderSiteTaxID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
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

	SELECT	APPT.AppointmentID,
			APPT.AppointmentNote,
			APPT.AppointmentDateTime,
			APPT.AppointmentDate,
			APPT.AbstractorID,
			A.AbstractorName,
			APPT.AppointmentStatusID,
			APST.[Description] AS AppointmentStatusDescription,
			APPT.OriginalAppointmentID,
			APPT.CreatedDate,
			APPT.CreatedUser,
			APPT.LastChangedDate,
			APPT.LastChangedUser,
			PS.CustomerProviderSiteID,
			PS.Address1 AS ProviderSiteAddress1,
			PS.Address2 AS ProviderSiteAddress2,
			PS.City AS ProviderSiteAddressCity,
			PS.County AS ProviderSiteAddressCounty,
			PS.[State] AS ProviderSiteAddressState,
			PS.Zip AS ProviderSiteAddressZip,
			PS.Contact AS ProviderSiteContact,
			PS.Fax AS ProviderSiteFax,
			PS.ProviderSiteID,
			PS.ProviderSiteName,
			PS.Phone AS ProviderSitePhone,		
			PS.TaxID AS ProviderSiteTaxID
	FROM	dbo.Appointment AS APPT WITH(NOLOCK)
			INNER JOIN dbo.ProviderSiteAppointment AS PSA WITH(NOLOCK)
					ON PSA.AppointmentID = APPT.AppointmentID
			INNER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON A.AbstractorID = APPT.AbstractorID
			INNER JOIN dbo.AppointmentStatus AS APST WITH(NOLOCK)
					ON APST.AppointmentStatusID = APPT.AppointmentStatusID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = PSA.ProviderSiteID
			OUTER APPLY (
							SELECT * FROM dbo.AppointmentStandardTimeframes WITH(NOLOCK) WHERE ID = @AppointmentTimeframeID
						) APPTSTF
	WHERE	((@AbstractorID IS NULL) OR (A.AbstractorID = @AbstractorID) OR (A.AbstractorID IS NULL AND @AbstractorID = -1)) AND
			((@AppointmentID IS NULL) OR (APPT.AppointmentID = @AppointmentID)) AND
			(APPT.AppointmentDate BETWEEN ISNULL(@MinAppointmentDate, APPT.AppointmentDate) AND ISNULL(@MaxAppointmentDate, APPT.AppointmentDate)) AND
			((@AppointmentTimeframeID IS NULL) OR (APPT.AppointmentDate BETWEEN APPTSTF.StartDate AND APPTSTF.EndDate)) AND
			((@AppointmentStatusID IS NULL) OR (APPT.AppointmentStatusID = @AppointmentStatusID)) AND
			------------------------------------------------------------------------------------------------------------------------
			((@ProviderSiteTaxID IS NULL) OR (PS.TaxID = @ProviderSiteTaxID) OR (PS.TaxID LIKE @ProviderSiteTaxID)) AND 
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
	ORDER BY AbstractorName, AppointmentDateTime;
END
GO
GRANT EXECUTE ON  [Report].[GetAppointmentListing] TO [Reporting]
GO
