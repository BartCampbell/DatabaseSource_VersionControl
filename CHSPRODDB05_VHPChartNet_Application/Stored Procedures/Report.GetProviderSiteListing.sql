SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetProviderSiteListing]
(
	@CustomerProviderSiteID varchar(25) = NULL,
	@MaxCountAppt int = NULL,
	@MinCountAppt int = NULL,
	@MaxCountApptCompleted int = NULL,
	@MinCountApptCompleted int = NULL,
	@MaxCountApptNotCompleted int = NULL,
	@MinCountApptNotCompleted int = NULL,
	@MaxCountApptRescheduled int = NULL,
	@MinCountApptRescheduled int = NULL,
	@MaxCountFaxLog int = NULL,
	@MinCountFaxLog int = NULL,
	@MaxCountFaxLogNotReceived int = NULL,
	@MinCountFaxLogNotReceived int = NULL,
	@MaxCountFaxLogNotSent int = NULL,
	@MinCountFaxLogNotSent int = NULL,
	@MaxCountFaxLogReceived int = NULL,
	@MinCountFaxLogReceived int = NULL,
	@MaxCountFaxLogSent int = NULL,
	@MinCountFaxLogSent int = NULL,
	@MaxCountCompleted int = NULL,
	@MinCountCompleted int = NULL,
	@MaxCountMembers int = NULL,
	@MinCountMembers int = NULL,
	@MaxCountNotCompleted int = NULL,
	@MinCountNotCompleted int = NULL,
	@MaxCountProviders int = NULL,
	@MinCountProviders int = NULL,
	@MaxCountPursuits int = NULL,
	@MinCountPursuits int = NULL,
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

	SELECT	ISNULL(A.CountAppt, 0) AS CountAppt,
			ISNULL(A.CountApptCompleted, 0) AS CountApptCompleted,
            ISNULL(A.CountApptNotCompleted, 0) AS CountApptNotCompleted,
            ISNULL(A.CountApptRescheduled, 0) AS CountApptRescheduled,
			ISNULL(R.CountCompleted, 0) AS CountCompleted,
			ISNULL(FL.CountFaxLog, 0) AS CountFaxLog,
			ISNULL(FL.CountFaxLogNotReceived, 0) AS CountFaxLogNotReceived,
			ISNULL(FL.CountFaxLogNotSent, 0) AS CountFaxLogNotSent,
			ISNULL(FL.CountFaxLogReceived, 0) AS CountFaxLogReceived,
			ISNULL(FL.CountFaxLogSent, 0) AS CountFaxLogSent,
			ISNULL(R.CountMembers, 0) AS CountMembers,
			ISNULL(R.CountNotCompleted, 0) AS CountNotCompleted,
			ISNULL(R.CountProviders, 0) AS CountProviders,
			ISNULL(R.CountPursuits, 0) AS CountPursuits,
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
	FROM	dbo.ProviderSite AS PS WITH(NOLOCK)
			OUTER APPLY (
							SELECT	COUNT(DISTINCT CASE WHEN tAST.IsCompleted = 1 THEN tRV.PursuitEventID END) AS CountCompleted,
									COUNT(DISTINCT tR.MemberID) AS CountMembers, 
									COUNT(DISTINCT CASE WHEN tAST.IsCompleted = 0 THEN tRV.PursuitEventID END) AS CountNotCompleted,
									COUNT(DISTINCT tR.ProviderID) AS CountProviders, 
									COUNT(DISTINCT tRV.PursuitEventID) AS CountPursuitEvents,
									COUNT(DISTINCT tR.PursuitID) AS CountPursuits 
							FROM	dbo.Pursuit AS tR WITH(NOLOCK)
									INNER JOIN dbo.PursuitEvent AS tRV WITH(NOLOCK)
											ON tRV.PursuitID = tR.PursuitID
									INNER JOIN dbo.AbstractionStatus AS tAST WITH(NOLOCK)
											ON tAST.AbstractionStatusID = tRV.AbstractionStatusID
							WHERE	tR.ProviderSiteID = PS.ProviderSiteID
						) AS R
			OUTER APPLY (
							SELECT	COUNT(DISTINCT tA.AppointmentID) AS CountAppt,
									COUNT(DISTINCT CASE WHEN tAPT.IsCompleted = 1 AND tAPT.IsReschedule = 0 THEN tA.AppointmentID END) AS CountApptCompleted,
									COUNT(DISTINCT CASE WHEN tAPT.IsCompleted = 0 AND tAPT.IsReschedule = 0 THEN tA.AppointmentID END) AS CountApptNotCompleted,
									COUNT(DISTINCT CASE WHEN tAPT.IsReschedule = 1 THEN tA.AppointmentID END) AS CountApptRescheduled
							FROM	dbo.Appointment AS tA WITH(NOLOCK)
									INNER JOIN dbo.ProviderSiteAppointment AS tPSA WITH(NOLOCK)
											ON tPSA.AppointmentID = tA.AppointmentID
									INNER JOIN dbo.AppointmentStatus AS tAPT WITH(NOLOCK)
											ON tAPT.AppointmentStatusID = tA.AppointmentStatusID
							WHERE	tPSA.ProviderSiteID = PS.ProviderSiteID
						) AS A
			OUTER APPLY (
							SELECT	COUNT(DISTINCT tFL.FaxLogID) AS CountFaxLog,
									COUNT(DISTINCT CASE WHEN tFLS.IsReceived = 0 AND tFL.FaxLogType = 'R' THEN tFL.FaxLogID END) AS CountFaxLogNotReceived,
									COUNT(DISTINCT CASE WHEN tFLS.IsSent = 0 AND tFL.FaxLogType = 'S' THEN tFL.FaxLogID END) AS CountFaxLogNotSent,
									COUNT(DISTINCT CASE WHEN tFLS.IsReceived = 1 AND tFL.FaxLogType = 'R' THEN tFL.FaxLogID END) AS CountFaxLogReceived,
									COUNT(DISTINCT CASE WHEN tFLS.IsSent = 1 AND tFL.FaxLogType = 'S' THEN tFL.FaxLogID END) AS CountFaxLogSent
							FROM	dbo.FaxLog AS tFL WITH(NOLOCK)
									INNER JOIN dbo.FaxLogStatus AS tFLS WITH(NOLOCK)
											ON tFLS.FaxLogStatusID = tFL.FaxLogStatusID
							WHERE	tFL.ProviderSiteID = PS.ProviderSiteID
						) AS FL
	WHERE	(PS.CustomerProviderSiteID <> '') AND
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
			(ISNULL(A.CountAppt, 0) BETWEEN ISNULL(@MinCountAppt, 0) AND ISNULL(@MaxCountAppt, 2147483647)) AND
			(ISNULL(A.CountApptCompleted, 0) BETWEEN ISNULL(@MinCountApptCompleted, 0) AND ISNULL(@MaxCountApptCompleted, 2147483647)) AND
			(ISNULL(A.CountApptNotCompleted, 0) BETWEEN ISNULL(@MinCountApptNotCompleted, 0) AND ISNULL(@MaxCountApptNotCompleted, 2147483647)) AND
			(ISNULL(A.CountApptRescheduled, 0) BETWEEN ISNULL(@MinCountApptRescheduled, 0) AND ISNULL(@MaxCountApptRescheduled, 2147483647)) AND
			(ISNULL(FL.CountFaxLog, 0) BETWEEN ISNULL(@MinCountFaxLog, 0) AND ISNULL(@MaxCountFaxLog, 2147483647)) AND
			(ISNULL(FL.CountFaxLogNotReceived, 0) BETWEEN ISNULL(@MinCountFaxLogNotReceived, 0) AND ISNULL(@MaxCountFaxLogNotReceived, 2147483647)) AND
			(ISNULL(FL.CountFaxLogNotSent, 0) BETWEEN ISNULL(@MinCountFaxLogNotSent, 0) AND ISNULL(@MaxCountFaxLogNotSent, 2147483647)) AND
			(ISNULL(FL.CountFaxLogReceived, 0) BETWEEN ISNULL(@MinCountFaxLogReceived, 0) AND ISNULL(@MaxCountFaxLogReceived, 2147483647)) AND
			(ISNULL(FL.CountFaxLogSent, 0) BETWEEN ISNULL(@MinCountFaxLogSent, 0) AND ISNULL(@MaxCountFaxLogSent, 2147483647)) AND
			(ISNULL(R.CountMembers, 0) BETWEEN ISNULL(@MinCountMembers, 0) AND ISNULL(@MaxCountMembers, 2147483647)) AND
			(ISNULL(R.CountProviders, 0) BETWEEN ISNULL(@MinCountProviders, 0) AND ISNULL(@MaxCountProviders, 2147483647)) AND
			(ISNULL(R.CountPursuits, 0) BETWEEN ISNULL(@MinCountPursuits, 0) AND ISNULL(@MaxCountPursuits, 2147483647)) AND
			(ISNULL(R.CountCompleted, 0) BETWEEN ISNULL(@MinCountCompleted, 0) AND ISNULL(@MaxCountCompleted, 2147483647)) AND
			(ISNULL(R.CountNotCompleted, 0) BETWEEN ISNULL(@MinCountNotCompleted, 0) AND ISNULL(@MaxCountNotCompleted, 2147483647))
	ORDER BY PS.CustomerProviderSiteID
	OPTION (OPTIMIZE FOR UNKNOWN);

END

GO
GRANT EXECUTE ON  [Report].[GetProviderSiteListing] TO [Reporting]
GO
