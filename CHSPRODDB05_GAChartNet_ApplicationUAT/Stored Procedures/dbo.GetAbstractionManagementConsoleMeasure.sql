SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAbstractionManagementConsoleMeasure]
    @MeasureID int,
    @AbstractorID int = NULL,
    @ReviewerID int = NULL,
    @AppointmentID int = NULL,
    @ProviderID int = NULL,
	@ProductLine varchar(20) = NULL,
	@Product varchar(20) = NULL
AS 

WITH FilterSet AS --Changed from a temp table when adding product line and product
(
	SELECT	DISTINCT
			MMS.MemberMeasureSampleID/*,
			P.AbstractorID,
			P.ReviewerID,
			P.AppointmentID,
			Prov.ProviderID,
			MMS.Product,
			MMS.ProductLine*/
	FROM    dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
			INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS WITH(NOLOCK) ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
			INNER JOIN dbo.HEDISSubMetric AS HSM WITH(NOLOCK) ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID
			LEFT OUTER JOIN dbo.Pursuit AS P WITH(NOLOCK) ON MMS.MemberID = P.MemberID
			LEFT OUTER JOIN dbo.Providers AS Prov WITH(NOLOCK) ON P.ProviderID = Prov.ProviderID
			LEFT OUTER JOIN dbo.PursuitEvent AS PE WITH(NOLOCK) ON P.PursuitID = PE.PursuitID AND
										 PE.MeasureID = MMS.MeasureID
			LEFT OUTER JOIN dbo.AbstractionReview AS AR WITH(NOLOCK)
					ON PE.PursuitEventID = AR.PursuitEventID
	WHERE   ((@MeasureID IS NULL) OR (HSM.MeasureID = @MeasureID)) AND
			((@Product IS NULL) OR (MMS.Product = @Product)) AND
			((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine)) AND
			((@AbstractorID IS NULL) OR (P.AbstractorID = @AbstractorID)) AND
			((@ProviderID IS NULL) OR (Prov.ProviderID = @ProviderID)) AND
			((@AppointmentID IS NULL) OR (P.AppointmentID = @AppointmentID)) AND
			((@ReviewerID IS NULL) OR (AR.ReviewerID = @ReviewerID))
)
SELECT  HSM.HEDISMeasureInit,
        HSM.HEDISSubMetricCode HEDISSubMetric,
        HSM.ReportName AS DisplayName,
        SUM(CONVERT(int, MMMS.Denominator)) AS Denominator,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.AdministrativeHit > 0 THEN 1 ELSE 0 END) AS AdministrativeHit,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.MedicalRecordHit > 0 THEN 1 ELSE 0 END) AS MedicalRecordHit,
        SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.HybridHit > 0 THEN 1 ELSE 0 END) AS HybridHit,
        ((SUM(CASE WHEN MMMS.Denominator > 0 AND MMMS.HybridHit > 0 THEN 1 ELSE 0 END * 100.00) / SUM(CONVERT(int, MMMS.Denominator))) / 100) AS [Rate],
		SUM(CONVERT(int, MMMS.ReqExclusion)) AS ReqExclusion,
		SUM(CONVERT(int, MMMS.Exclusion)) AS Exclusion,
		SUM(CONVERT(int, MMMS.SampleVoid)) AS SampleVoid
FROM    dbo.MemberMeasureSample AS MMS WITH(NOLOCK)
		INNER JOIN FilterSet AS FS ON MMS.MemberMeasureSampleID = FS.MemberMeasureSampleID
        INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS WITH(NOLOCK) ON MMS.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
        INNER JOIN dbo.HEDISSubMetric AS HSM WITH(NOLOCK) ON MMMS.HEDISSubMetricID = HSM.HEDISSubMetricID
WHERE   HSM.DisplayInScoringPanel = 1
GROUP BY HSM.HEDISMeasureInit,
        HSM.HEDISSubMetricCode,
        HSM.DisplayName,
		HSM.ReportName,
		HSM.SortOrder
ORDER BY HSM.HEDISMeasureInit, HSM.SortOrder, HSM.HEDISSubMetricCode;
GO
