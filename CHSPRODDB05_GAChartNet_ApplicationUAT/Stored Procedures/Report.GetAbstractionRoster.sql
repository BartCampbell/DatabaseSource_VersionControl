SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetAbstractionRoster]
(
	@AbstractionStatusID int = NULL,
	@AbstractorID int = NULL,
	@AppointmentDate datetime = NULL,
	@AppointmentID int = NULL,
	@ChartStatusValueID int = NULL,
	@FaxLogID int = NULL,
	@FaxLogSubID int = NULL,
	@HasReviews bit = 0,
	@HasScans bit = 0,
	@IsForFax bit = 0,
	@MeasureID int = NULL,
	@MemberID int = NULL,
	@ProviderID int = NULL,
	@ProviderSiteID int = NULL,
	@PursuitCategory varchar(50) = NULL,
	-----------------------------------------------
	@CustomerMemberID varchar(20) = NULL,
	@ProductLine varchar(20) = NULL,
	@Product varchar(20) = NULL,
	@MemberName varchar(30) = NULL,
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

	DECLARE @WebAddress nvarchar(512);
	SELECT @WebAddress = ParamCharValue FROM dbo.SystemParams WITH(NOLOCK) WHERE ParamName = 'WebAddress';

	IF @WebAddress IS NOT NULL AND RIGHT(@WebAddress, 1) <> '/'
		SET @WebAddress = @WebAddress + '/';

	SET @PursuitCategory = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@PursuitCategory, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @CustomerMemberID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerMemberID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @ProductLine = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@ProductLine, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @Product = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@Product, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
	SET @MemberName = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@MemberName, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');
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

	WITH Deductions AS
	(
		SELECT	AbstractionReviewID,
				SUM(Deductions) AS Deductions
		FROM	dbo.AbstractionReviewDetail WITH(NOLOCK)
		GROUP BY AbstractionReviewID
	),
	Reviews AS
	(
		SELECT	R.AbstractionDate,
				R.AbstractorID,
				AR.MeasureComponentID,
				RV.MeasureID,
				CASE WHEN ISNULL(D.Deductions, 0) > AR.ReviewPointsAvailable THEN 0 ELSE AR.ReviewPointsAvailable - ISNULL(D.Deductions, 0) END AS PointsActual,
				AR.ReviewPointsAvailable AS PointsAvailable,
				RV.PursuitEventID,
				R.PursuitID,
				AR.ReviewDate,
				AR.ReviewerID
		FROM	dbo.AbstractionReview AS AR WITH(NOLOCK)
				INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
						ON AR.PursuitEventID = RV.PursuitEventID
				INNER JOIN dbo.Pursuit AS R WITH(NOLOCK)
						ON RV.PursuitID = R.PursuitID
				LEFT OUTER JOIN Deductions AS D
						ON AR.AbstractionReviewID = D.AbstractionReviewID
	),
	PursuitEventsWithCharts AS
	(
		SELECT DISTINCT
				PursuitEventID 
		FROM	dbo.PursuitEventChartImage WITH(NOLOCK)
		
	),
	PursuitEventsWithReviews AS
	(
		SELECT	SUM(PointsActual) AS PointsActual,
				SUM(PointsAvailable) AS PointsAvailable,
				PursuitEventID,
				CASE WHEN COUNT(DISTINCT t.ReviewerID) = 1 THEN MIN(t.ReviewerID) END AS ReviewerID,
				CASE WHEN COUNT(DISTINCT t.ReviewerID) > 1 THEN '(Multiple Reviewers)' ELSE MIN(R.ReviewerName) END AS ReviewerName
		FROM	Reviews AS t
				INNER JOIN dbo.Reviewer AS R WITH(NOLOCK)
						ON t.ReviewerID = R.ReviewerID
		GROUP BY PursuitEventID
	),
	AppointmentSites AS 
	(
		SELECT DISTINCT 
				PSAPPT.ProviderSiteID 
		FROM	dbo.Appointment AS APPT WITH(NOLOCK)
				INNER JOIN dbo.ProviderSiteAppointment AS PSAPPT WITH(NOLOCK)
						ON PSAPPT.AppointmentID = APPT.AppointmentID
		WHERE	(APPT.AppointmentDate = @AppointmentDate) OR
				(APPT.AppointmentID = @AppointmentID)
	),
	FaxLogSubmissionPursuits AS
	(
		SELECT DISTINCT
				FL.ProviderSiteID, FLP.PursuitID
		FROM	dbo.FaxLog AS FL WITH(NOLOCK)
				INNER JOIN dbo.FaxLogPursuits AS FLP WITH(NOLOCK)
						ON FLP.FaxLogID = FL.FaxLogID
		WHERE	((@FaxLogID IS NULL) OR (FL.FaxLogID = @FaxLogID)) AND
				((@FaxLogSubID IS NULL) OR (FL.FaxLogID IN (SELECT FLS.FaxLogID FROM dbo.FaxLogSubmissions AS FLS WITH(NOLOCK) WHERE FLS.FaxLogSubID = @FaxLogSubID))) AND
				((@IsForFax = 0) OR (@FaxLogID IS NOT NULL) OR (@FaxLogSubID IS NOT NULL) OR (1 = 2)) AND --Prevent returning all rows to fax roster, if both parameters are NULL
				(FLP.Selected = 1)
	)
	SELECT	AST.[Description] AS AbstractionStatusDescr,
			AST.AbstractionStatusID,
			ISNULL(A.AbstractorID, -1) AS AbstractorID,
			ISNULL(A.AbstractorName, '(Unassigned)') AS AbstractorName,
			APP.AppointmentDate,
			APP.AppointmentDateTime,
			APP.AppointmentNote AS AppointmentDescription,
			APP.AppointmentID,
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
			ISNULL(RVWR.PointsActual, 0) AS ReviewPointsActual,
			ISNULL(RVWR.PointsAvailable, 0) AS ReviewPointsAvailable,
			RVWR.ReviewerID,
			RVWR.ReviewerName,
			CONVERT(decimal(6, 3), CASE WHEN ISNULL(RVWR.PointsAvailable, 0) > 0 THEN ROUND(CONVERT(decimal(18,6), ISNULL(RVWR.PointsActual, 0)) / CONVERT(decimal(18,6), ISNULL(RVWR.PointsAvailable, 0)), 3, 1) END) AS ReviewScore,
			'###-##-' + RIGHT(MBR.SSN, 4) AS SSN,
			@WebAddress + 'AbstractionSummary.aspx?id=' + CONVERT(nvarchar(512), RV.PursuitEventID) AS WebAddress
	FROM	dbo.Pursuit AS R WITH(NOLOCK)
			INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON R.PursuitID = RV.PursuitID
			LEFT OUTER JOIN PursuitEventsWithCharts AS RVWC
					ON RV.PursuitEventID = RVWC.PursuitEventID
			LEFT OUTER JOIN PursuitEventsWithReviews AS RVWR
					ON RV.PursuitEventID = RVWR.PursuitEventID
			LEFT OUTER JOIN dbo.Appointment AS APP WITH(NOLOCK)
					ON R.AppointmentID = APP.AppointmentID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON R.MemberID = MBR.MemberID
			INNER JOIN dbo.Providers AS P WITH(NOLOCK)
					ON R.ProviderID = P.ProviderID
			INNER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON R.ProviderSiteID = PS.ProviderSiteID
			INNER JOIN dbo.Measure AS M WITH(NOLOCK)
					ON RV.MeasureID = M.MeasureID
			LEFT OUTER JOIN dbo.Abstractor AS A WITH(NOLOCK)
					ON R.AbstractorID = A.AbstractorID
			LEFT OUTER JOIN dbo.AbstractionStatus AS AST WITH(NOLOCK)
					ON RV.AbstractionStatusID = AST.AbstractionStatusID
			LEFT OUTER JOIN dbo.ChartStatusValue AS CSV WITH(NOLOCK)
					ON RV.ChartStatusValueID = CSV.ChartStatusValueID
			LEFT OUTER JOIN FaxLogSubmissionPursuits AS FLSP
					ON FLSP.PursuitID = R.PursuitID AND
						FLSP.ProviderSiteID = R.ProviderSiteID
	WHERE	((@AbstractionStatusID IS NULL) OR (AST.AbstractionStatusID = @AbstractionStatusID)) AND
			((@AbstractorID IS NULL) OR (R.AbstractorID = @AbstractorID) OR (R.AbstractorID IS NULL AND @AbstractorID = -1)) AND
			(((@AppointmentDate IS NULL) AND (@AppointmentID IS NULL)) OR (R.ProviderSiteID IN (SELECT ProviderSiteID FROM AppointmentSites))) AND
			((@ChartStatusValueID IS NULL) OR (RV.ChartStatusValueID = @ChartStatusValueID) OR (@ChartStatusValueID = -1 AND RV.ChartStatusValueID IS NULL)) AND
			((@HasReviews = 0) OR (RVWR.PursuitEventID IS NOT NULL)) AND
			((@HasScans = 0) OR (RVWC.PursuitEventID IS NOT NULL)) AND
			((@MeasureID IS NULL) OR (RV.MeasureID = @MeasureID)) AND
			((@MemberID IS NULL) OR (R.MemberID = @MemberID)) AND
			((@ProviderID IS NULL) OR (R.ProviderID = @ProviderID)) AND
			((@ProviderSiteID IS NULL) OR (R.ProviderSiteID = @ProviderSiteID)) AND
			((@PursuitCategory IS NULL) OR (R.PursuitCategory = @PursuitCategory) OR (R.PursuitCategory LIKE @PursuitCategory)) AND
			------------------------------------------------------------------------------------------------------------------------
			((@CustomerMemberID IS NULL) OR (MBR.CustomerMemberID = @CustomerMemberID) OR (MBR.CustomerMemberID LIKE @CustomerMemberID)) AND 
			((@ProductLine IS NULL) OR (MBR.ProductLine = @ProductLine) OR (MBR.ProductLine LIKE @ProductLine)) AND 
			((@Product IS NULL) OR (MBR.Product = @Product) OR (MBR.Product LIKE @Product)) AND 
			((@MemberName IS NULL) OR (MBR.NameLast = @MemberName) OR (MBR.NameLast LIKE @MemberName)) AND 
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
			((@IsForFax = 0)  OR (FLSP.PursuitID IS NOT NULL)) AND
			------------------------------------------------------------------------------------------------------------------------
			(
				(@UserName IS NULL) OR 
				(ISNULL(@FilterOnUserName, 0) = 0) OR 
				(A.UserName = @UserName) 
			) 
	ORDER BY MeasureAbbrev, MemberNameLast, MemberNameFirst, MemberNameMid, MemberDOB
	OPTION (OPTIMIZE FOR (@AbstractionStatusID = NULL, @AbstractorID = NULL, @AppointmentDate = NULL, 
							@AppointmentID = NULL, @ChartStatusValueID = NULL, @FaxLogSubID = NULL, @HasReviews = 0,
							@HasScans = 0, @MeasureID = NULL, @MemberID = NULL,
							@ProviderID = NULL, @ProviderSiteID = NULL));

	-------------------------------------------------------------------------------------------------------------------------------
	--Added for Fax Log Submission sample SSRS report...
	IF @FaxLogSubID IS NOT NULL
		BEGIN;
			EXEC dbo.MarkReadyFaxLogSubmission @FaxLogSubID = @FaxLogSubID;
		END;
	-------------------------------------------------------------------------------------------------------------------------------

END
GO
GRANT EXECUTE ON  [Report].[GetAbstractionRoster] TO [Reporting]
GO
