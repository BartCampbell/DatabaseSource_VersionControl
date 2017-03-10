SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Report].[GetCDCHba1cRoster]
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
			AV.ServiceDate AS [HbA1c Date - Admin],
			AV.LabResult AS [HbA1c Result - Admin],
			--CASE WHEN ISNULL(AV.LabResult, 100) > 9 THEN 'POOR' WHEN ISNULL(AV.LabResult, 100) > 8 THEN 'good' ELSE '' END AS [HbA1c Result Type - Admin],
			MRC.ServiceDate AS [HbA1c Date - MRR],
			MRC.CalcLabResult AS [HbA1c Result - MRR],
			--CASE WHEN ISNULL(MRC.CalcLabResult, 100) > 9 THEN 'POOR' WHEN ISNULL(MRC.CalcLabResult, 100) < 8 THEN 'good' ELSE '' END AS [HbA1c Result Type - MRR],
			CASE 
				WHEN AV.ServiceDate BETWEEN MRC.ServiceDate AND DATEADD(dd, @LabDays, MRC.ServiceDate)
				THEN 'Both' 
				WHEN AV.ServiceDate > DATEADD(dd, @LabDays, MRC.ServiceDate) OR MRC.ServiceDate IS NULL 
				THEN 'Admin' 
				ELSE 'MRR' 
				END AS [HbA1c Source - Hybrid],
			CASE 
				WHEN AV.ServiceDate > MRC.ServiceDate OR MRC.ServiceDate IS NULL 
				THEN AV.ServiceDate
				ELSE MRC.ServiceDate 
				END AS [HbA1c Date - Hybrid],
			CASE 
				WHEN AV.ServiceDate > MRC.ServiceDate OR MRC.ServiceDate IS NULL OR
					(AV.ServiceDate BETWEEN MRC.ServiceDate AND DATEADD(dd, @LabDays, MRC.ServiceDate) AND ISNULL(AV.LabResult, 100) < ISNULL(MRC.CalcLabResult, 100))
				THEN ISNULL(AV.LabResult, 100)
				ELSE ISNULL(MRC.CalcLabResult, 100)
				END AS [HbA1c Result - Hybrid]
	FROM	dbo.MemberMeasureMetricScoring AS MMMS WITH(NOLOCK)
			INNER JOIN dbo.HEDISSubMetric AS MX WITH(NOLOCK)
					ON MX.HEDISSubMetricID = MMMS.HEDISSubMetricID
			INNER JOIN dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
					ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
			INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
					ON MBR.MemberID = MMS.MemberID
			OUTER APPLY (
							SELECT TOP 1 
									tAV.* 
							FROM	dbo.AdministrativeEvent AS tAV WITH(NOLOCK)
									INNER JOIN dbo.HEDISSubMetric AS tMX WITH(NOLOCK)
											ON tMX.HEDISSubMetricID = tAV.HEDISSubMetricID 
							WHERE	tMX.HEDISSubMetricCode IN ('CDC1', 'CDC2', 'CDC3', 'CDC10') AND
									tAV.MemberID = MMS.MemberID AND
									tAV.ServiceDate BETWEEN @MeasureYearStart AND @MeasureYearEnd
							ORDER BY tAV.ServiceDate DESC,
									ISNULL(tAV.LabResult, 100.000000)
						) AS AV
			OUTER APPLY (
							SELECT TOP 1
									CASE WHEN ISNUMERIC(ISNULL(tMRC.ColValue01, '')) = 1 THEN CONVERT(decimal(18,6), tMRC.ColValue01) ELSE 100.000000 END AS CalcLabResult,
									tMRC.*
							FROM	dbo.MedicalRecordComposite AS tMRC WITH(NOLOCK)
									INNER JOIN dbo.MeasureComponent AS tMC WITH(NOLOCK)
											ON tMC.MeasureComponentID = tMRC.MeasureComponentID
									INNER JOIN dbo.Pursuit AS tR
											ON tR.PursuitID = tMRC.PursuitID
							WHERE	tMC.ComponentName = 'CDCHbA1c' AND
									tR.MemberID = MMS.MemberID AND
									tMRC.ServiceDate BETWEEN @MeasureYearStart AND @MeasureYearEnd
							ORDER BY tMRC.ServiceDate DESC,
									CASE WHEN ISNUMERIC(ISNULL(tMRC.ColValue01, '')) = 1 THEN CONVERT(decimal(18,6), tMRC.ColValue01) ELSE 100.000000 END
						) AS MRC
			LEFT OUTER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
					ON RV.MemberMeasureSampleID = MMS.MemberMeasureSampleID
			LEFT OUTER JOIN dbo.Pursuit AS R WITH(NOLOCK)
					ON R.PursuitID = RV.PursuitID
			LEFT OUTER JOIN dbo.ProviderSite AS PS WITH(NOLOCK)
					ON PS.ProviderSiteID = R.ProviderSiteID
	WHERE	MX.HEDISSubMetricCode IN ('CDC1', 'CDC2', 'CDC3', 'CDC10') AND
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
GRANT EXECUTE ON  [Report].[GetCDCHba1cRoster] TO [Reporting]
GO
