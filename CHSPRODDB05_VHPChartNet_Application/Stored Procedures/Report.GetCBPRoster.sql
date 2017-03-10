SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetCBPRoster]
(
	@HEDISSubMetricID int = NULL,
	@ProductLine varchar(20) = NULL,
	@Product nvarchar(20) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @MeasureYearStart datetime;
	DECLARE @MeasureYearEnd datetime;
	DECLARE @LabDays int;

	SELECT @MeasureYearEnd = dbo.MeasureYearEndDate(), @MeasureYearStart = dbo.MeasureYearStartDate();
	SET @LabDays = dbo.GetLabVarianceDaysAllowed();

	SELECT	MMS.ProductLine AS [Product Line], 
			MMS.Product, 
			MBR.CustomerMemberID AS [Member ID], 
			MBR.NameLast AS [Last Name], 
			MBR.NameFirst AS [First Name], 
			MBR.NameMiddleInitial AS [Middle Initial],
			MBR.DateOfBirth AS [Date of Birth],
			MBR.Gender,
			R.PursuitNumber AS [Pursuit Number],
			PS.CustomerProviderSiteID AS [Site ID],
			PS.ProviderSiteName AS [Site Name],
			PS.Address1 AS [Site - Address 1], 
			PS.Address2 AS [Site - Address 2],
			PS.City AS [Site - City],
			PS.State AS [Site - State],
			PS.Zip AS [Site - Zip Code],
			MX.HEDISSubMetricCode AS [Metric], 
			MX.HEDISSubMetricDescription AS [Metric Description],
			MMMS.Denominator AS [Denominator],
			MMMS.AdministrativeHit AS [Compliant - Admin],
			MMMS.MedicalRecordHit AS [Compliant - MRR],
			MMMS.HybridHit AS [Compliant - Hybrid],
			MRC_Conf.ServiceDate AS [Hypertension Confirmed],
			MRC.ServiceDate AS [BP Reading Date],
			MRC.Systolic AS [BP Reading - Systolic],
			MRC.Diastolic AS [BP Reading - Diastolic],
			MMS.DiabetesDiagnosisDate AS [Diabetes - Diagnosis Date],
			CONVERT(bit, CASE WHEN MMMS.SuppIndicator = 1 OR MMS.DiabetesDiagnosisDate IS NOT NULL THEN 1 ELSE 0 END) AS [Diabetes - Indicator],
			MRC_Refuted.ServiceDate AS [Diabetes - Refuted],
			dbo.GetAgeAsOf(MBR.DateOfBirth, @MeasureYearEnd) AS [Member Age]
	FROM	dbo.MemberMeasureMetricScoring AS MMMS WITH(NOLOCK)
			INNER JOIN dbo.HEDISSubMetric AS MX WITH(NOLOCK)
					ON MX.HEDISSubMetricID = MMMS.HEDISSubMetricID
			INNER JOIN dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
					ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON MBR.MemberID = MMS.MemberID
			OUTER APPLY (
							SELECT TOP 1
									MIN(CASE WHEN ISNUMERIC(ISNULL(tMRC.ColValue01, '')) = 1 THEN CONVERT(int, tMRC.ColValue01) ELSE 999 END) AS Systolic,
									MIN(CASE WHEN ISNUMERIC(ISNULL(tMRC.ColValue02, '')) = 1 THEN CONVERT(int, tMRC.ColValue02) ELSE 999 END) AS Diastolic,
									tMRC.ServiceDate
							FROM	dbo.MedicalRecordComposite AS tMRC WITH(NOLOCK)
									INNER JOIN dbo.MeasureComponent AS tMC WITH(NOLOCK)
											ON tMC.MeasureComponentID = tMRC.MeasureComponentID
									INNER JOIN dbo.Pursuit AS tR
											ON tR.PursuitID = tMRC.PursuitID
							WHERE	tMC.ComponentName = 'CBPReading' AND
									tR.MemberID = MMS.MemberID AND
									tMRC.ServiceDate BETWEEN @MeasureYearStart AND @MeasureYearEnd
							GROUP BY tMRC.ServiceDate
							ORDER BY tMRC.ServiceDate DESC
						) AS MRC
			OUTER APPLY (
							SELECT TOP 1
									tMRC.*
							FROM	dbo.MedicalRecordComposite AS tMRC WITH(NOLOCK)
									INNER JOIN dbo.MeasureComponent AS tMC WITH(NOLOCK)
											ON tMC.MeasureComponentID = tMRC.MeasureComponentID
									INNER JOIN dbo.Pursuit AS tR
											ON tR.PursuitID = tMRC.PursuitID
							WHERE	tMC.ComponentName = 'CBPConf' AND
									tR.MemberID = MMS.MemberID AND
									tMRC.ServiceDate <= @MeasureYearEnd
							ORDER BY tMRC.ServiceDate
						) AS MRC_Conf
			OUTER APPLY (
							SELECT TOP 1
									tMRC.ServiceDate
							FROM	dbo.MedicalRecordComposite AS tMRC WITH(NOLOCK)
									INNER JOIN dbo.MeasureComponent AS tMC WITH(NOLOCK)
											ON tMC.MeasureComponentID = tMRC.MeasureComponentID
									INNER JOIN dbo.Pursuit AS tR
											ON tR.PursuitID = tMRC.PursuitID
							WHERE	tMC.ComponentName = 'CBPDiabetes' AND
									tR.MemberID = MMS.MemberID AND
									tMRC.ServiceDate BETWEEN DATEADD(yy, -1, @MeasureYearStart) AND @MeasureYearEnd
							GROUP BY tMRC.ServiceDate
							HAVING MAX(tMRC.ColValue01) = '1' AND
									MAX(tMRC.ColValue02) = '1'
							ORDER BY tMRC.ServiceDate DESC
						) AS MRC_Refuted
			LEFT OUTER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON RV.MemberMeasureSampleID = MMS.MemberMeasureSampleID
			LEFT OUTER JOIN dbo.Pursuit AS R WITH(NOLOCK)
					ON R.PursuitID = RV.PursuitID
			LEFT OUTER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = R.ProviderSiteID
	WHERE	MX.HEDISSubMetricCode IN ('CBP') AND
			((@Product IS NULL) OR (MMS.Product = @Product)) AND
			((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine)) AND
			((@HEDISSubMetricID IS NULL) OR (MMMS.HEDISSubMetricID = @HEDISSubMetricID))
	ORDER BY [Product Line],
			Product,
			[Last Name],
			[First Name],
			[Member ID],
			[Pursuit Number],
			[Site ID],
			Metric;

END

GO
GRANT EXECUTE ON  [Report].[GetCBPRoster] TO [Reporting]
GO
