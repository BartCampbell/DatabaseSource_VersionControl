SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Report].[GetMetricDetail_v1]
(
	@MeasureID int = NULL,
	@MetricID int = NULL,
	@Product varchar(20) = NULL,
	@ProductLine varchar(20) = NULL,
	@ReportView varchar(32) = 'IsDenominator'
)
AS
BEGIN
	SET NOCOUNT ON;

	WITH MeasureMemberVoids AS
	(
		SELECT DISTINCT
				RV.MeasureID,
				R.MemberID
		FROM	dbo.Pursuit AS R WITH(NOLOCK)
				INNER JOIN dbo.PursuitEvent AS RV WITH(NOLOCK)
						ON R.PursuitID = RV.PursuitID
		WHERE	(RV.SampleVoidFlag = 1) OR
				(ISNULL(RTRIM(NULLIF(RV.SampleVoidReasonCode, 'N/A')), '') <> '')
	),
	ResultsDetail AS
	(
		SELECT	MBR.CustomerMemberID,
				MMMS.ExclusionReason,
				CASE WHEN MMMS.DenominatorCount > 0 AND MMMS.ReqExclCount = 0 AND ISNULL(MMMS.ExclusionCount, 0) <= 0 AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL THEN 1 ELSE 0 END AS IsDenominator,
				CASE WHEN ISNULL(MMMS.ExclusionCount, 0) > 0  AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL THEN 1 ELSE 0 END AS IsExclusion,
				CASE WHEN MMMS.DenominatorCount > 0 AND MMMS.ReqExclCount = 0 AND ISNULL(MMMS.ExclusionCount, 0) <= 0 AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL AND MMMS.HybridHitCount <= 0 THEN 1 ELSE 0 END AS IsNotNumerator,
				CASE WHEN MMMS.DenominatorCount > 0 AND MMMS.ReqExclCount = 0 AND ISNULL(MMMS.ExclusionCount, 0) <= 0 AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL AND MMMS.HybridHitCount > 0 THEN 1 ELSE 0 END AS IsNumerator,
				CASE WHEN MMMS.DenominatorCount > 0 AND MMMS.ReqExclCount = 0 AND ISNULL(MMMS.ExclusionCount, 0) <= 0 AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL AND MMMS.AdministrativeHitCount > 0 THEN 1 ELSE 0 END AS IsNumeratorAdmin,
				CASE WHEN MMMS.DenominatorCount > 0 AND MMMS.ReqExclCount = 0 AND ISNULL(MMMS.ExclusionCount, 0) <= 0 AND ISNULL(MMMS.SampleVoidCount, 0) <= 0 AND MMV.MeasureID IS NULL AND MMMS.MedicalRecordHitCount > 0 AND MMMS.AdministrativeHitCount <= 0 THEN 1 ELSE 0 END AS IsNumeratorMedRcd,
				CASE WHEN MMMS.DenominatorCount > 0 AND (ISNULL(MMMS.SampleVoidCount, 0) >= 1 OR MMV.MeasureID IS NOT NULL) THEN 1 ELSE 0 END AS IsSampleVoid,
				ISNULL(MMS.PPCDeliveryDate, MMS.DischargeDate) AS KeyDate,
				M.HEDISMeasure AS MeasureAbbrev,
				M.HEDISMeasureDescription AS MeasureDescr,
				M.MeasureID,
				M.HEDISMeasure + ' - ' + M.HEDISMeasureDescription AS MeasureLongDescr,	
				MBR.DateOfBirth AS MemberDOB,
				MBR.Gender AS MemberGender,
				MBR.MemberID,
				MBR.NameFirst AS MemberNameFirst,
				MBR.NameLast AS MemberNameLast,
				MBR.NameMiddleInitial AS MemberNameMid,
				MX.HEDISSubMetricCode AS MetricAbbrev,
				MX.HEDISSubMetricDescription AS MetricDescr,
				MX.HEDISSubMetricID AS MetricID,
				MX.HEDISMeasureInit + ' - ' +
						--CASE WHEN MX.HEDISSubMetricCode = MX.DisplayName AND
						--		  MX.HEDISSubMetricCode = MX.HEDISMeasureInit
						--	 THEN 'Numerator' 
						--	 ELSE MX.DisplayName 
						--	 END AS MetricLongDescr,
				MX.ReportName AS MetricLongDescr,
				--CASE WHEN MX.HEDISSubMetricCode = MX.DisplayName AND
				--		  MX.HEDISSubMetricCode = MX.HEDISMeasureInit
				--	 THEN 'Numerator' 
				--	 ELSE MX.DisplayName 
				--	 END AS MetricShortDescr,
				MX.ReportName AS MetricShortDescr,
				MMS.Product,
				MMS.ProductLine,
				MMS.SampleDrawOrder,
				MMS.SampleType,
				'###-##-' + RIGHT(MBR.SSN, 4) AS SSN
		FROM	dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
				INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS WITH(NOLOCK)
						ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
				INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
						ON MMS.MemberID = MBR.MemberID
				INNER JOIN dbo.Measure AS M WITH(NOLOCK)
						ON MMS.MeasureID = M.MeasureID
				INNER JOIN dbo.HEDISSubMetric AS MX WITH(NOLOCK)
						ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
				LEFT OUTER JOIN MeasureMemberVoids AS MMV
						ON MMS.MeasureID = MMV.MeasureID AND
							MMS.MemberID = MMV.MemberID
		WHERE	(MX.DisplayInScoringPanel = 1)
	)
	SELECT	RD.*
	FROM	ResultsDetail AS RD
	WHERE	((@MeasureID IS NULL) OR (RD.MeasureID = @MeasureID)) AND
			((@MetricID IS NULL) OR (RD.MetricID = @MetricID)) AND
			((@Product IS NULL) OR (RD.Product = @Product)) AND
			((@ProductLine IS NULL) OR (RD.ProductLine = @ProductLine)) AND          
			(
				(@ReportView = 'IsDenominator') OR
				((@ReportView = 'IsExclusion') AND (RD.IsExclusion = 1)) OR
				((@ReportView = 'IsNotNumerator') AND (RD.IsNotNumerator = 1)) OR
				((@ReportView = 'IsNumerator') AND (RD.IsNumerator = 1)) OR
				((@ReportView = 'IsNumeratorAdmin') AND (RD.IsNumeratorAdmin = 1)) OR
				((@ReportView = 'IsNumeratorMedRcd') AND (RD.IsNumeratorMedRcd = 1)) OR
				((@ReportView = 'IsSampleVoid') AND (RD.IsSampleVoid = 1)) 
			)
	ORDER BY MeasureAbbrev, MetricAbbrev, SampleDrawOrder
	OPTION (OPTIMIZE FOR (@MeasureID = NULL, @MetricID = NULL, @Product = NULL, @ProductLine = NULL));

END


GO
