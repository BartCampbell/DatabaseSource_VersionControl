SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ScorePDS]
(
	@MemberID int
)
AS
BEGIN
	SELECT	DR.*, 
			CONVERT(bit, CASE WHEN (DR.IsPPC1Numerator = 1 OR DR.HasPrenatalVisit = 1) AND DR.IsPPC1Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC1Compliant,
			CONVERT(bit, CASE WHEN (DR.IsPPC2Numerator = 1 OR DR.HasPostpartumVisit = 1) AND DR.IsPPC2Denominator = 1 THEN 1 ELSE 0 END) AS IsPPC2Compliant
	INTO	#MeasureBase
	FROM	dbo.GetPADateRanges(@MemberID) AS DR 
			INNER JOIN dbo.Measure AS M
					ON M.MeasureID = DR.MeasureID
	WHERE	M.HEDISMeasure = 'PDS';

	CREATE UNIQUE CLUSTERED INDEX IX_#MeasureBase ON #MeasureBase (MemberMeasureSampleID);
	CREATE INDEX IX_#MeasureBase2 ON #MeasureBase (MemberID, MeasureID); 

	SELECT	a.MemberMeasureSampleID,
			a.MemberID,
			a.MeasureID,
			a.EventDate,
			a.IsPPC1Compliant,
			a.IsPPC2Compliant,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalDepressionScreening,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalDepressionScreeningAtFirstTwo,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.DepressionScreeningTool IS NOT NULL AND
								tMR1.DepressionScreeningTool NOT IN ('', 'NONE', '(NONE)', 'No Tool (Discussion w/Provider)')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalDepressionScreeningTool,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.ResultOfScreening = 'Positive'

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalDepressionScreeningPositiveResult,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.ResultOfScreening = 'Positive'

					) AND
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPrenatal AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRanges = 0 AND
										tMR1.ServiceDate BETWEEN a.PrenatalCareStartDateScore AND a.PrenatalCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRanges = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate1 AND a.PrenatalCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate2 AND a.PrenatalCareEndDate2 OR
											tMR1.ServiceDate BETWEEN a.PrenatalCareStartDate3 AND a.PrenatalCareEndDate3 
										)
									)
								) AND
								tMR1.EvidenceOfFurtherEvaluation = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalDepressionScreeningFurtherEvaluation,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPostpartum AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRangesPostpartum = 0 AND
										tMR1.ServiceDate BETWEEN a.PostpartumCareStartDateScore AND a.PostpartumCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRangesPostpartum = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate1 AND a.PostpartumCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate2 AND a.PostpartumCareEndDate2 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPostpartumDepressionScreening,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPostpartum AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										a.AllowConcurrentScoringRangesPostpartum = 0 AND
										tMR1.ServiceDate BETWEEN a.PostpartumCareStartDateScore AND a.PostpartumCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRangesPostpartum = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate1 AND a.PostpartumCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate2 AND a.PostpartumCareEndDate2 
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.DepressionScreeningTool IS NOT NULL AND
								tMR1.DepressionScreeningTool NOT IN ('', 'NONE', '(NONE)', 'No Tool (Discussion w/Provider)')

					)
				THEN 1
				ELSE 0 
				END AS HasPostpartumDepressionScreeningTool,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPostpartum AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRangesPostpartum = 0 AND
										tMR1.ServiceDate BETWEEN a.PostpartumCareStartDateScore AND a.PostpartumCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRangesPostpartum = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate1 AND a.PostpartumCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate2 AND a.PostpartumCareEndDate2
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.ResultOfScreening = 'Positive'

					)
				THEN 1
				ELSE 0 
				END AS HasPostpartumDepressionScreeningPositiveResult,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPostpartum AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRangesPostpartum = 0 AND
										tMR1.ServiceDate BETWEEN a.PostpartumCareStartDateScore AND a.PostpartumCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRangesPostpartum = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate1 AND a.PostpartumCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate2 AND a.PostpartumCareEndDate2
										)
									)
								) AND
								tMR1.ScreenedForDepression = 1 AND
								tMR1.ResultOfScreening = 'Positive'

					) AND
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPDSPostpartum AS tMR1
								INNER JOIN dbo.PursuitEvent AS tRV1
										ON tRV1.PursuitEventID = tMR1.PursuitEventID
								INNER JOIN dbo.Pursuit AS tR1
										ON tR1.PursuitID = tRV1.PursuitID
						WHERE	tR1.MemberID = a.MemberID AND
								tRV1.MeasureID = a.MeasureID AND
                                tRV1.EventDate = a.EventDate AND
								(
									(
										A.AllowConcurrentScoringRangesPostpartum = 0 AND
										tMR1.ServiceDate BETWEEN a.PostpartumCareStartDateScore AND a.PostpartumCareEndDateScore
									) OR
									(
										a.AllowConcurrentScoringRangesPostpartum = 1 AND
                                        (
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate1 AND a.PostpartumCareEndDate1 OR
											tMR1.ServiceDate BETWEEN a.PostpartumCareStartDate2 AND a.PostpartumCareEndDate2 
										)
									)
								) AND
								tMR1.EvidenceOfFurtherEvaluation = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPostpartumDepressionScreeningFurtherEvaluation
	INTO	#MeasureKey
	FROM	#MeasureBase AS a

	DECLARE @Denominator bit = 1;
	DECLARE @Numerator bit = 1;

	UPDATE	MMMS
	SET		@Denominator = Denominator = CASE 
											WHEN MX.HEDISSubMetricCode = 'PDS1' AND MK.IsPPC1Compliant = 1 
											THEN 1 
											WHEN MX.HEDISSubMetricCode = 'PDS1A' AND MK.IsPPC1Compliant = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS1CHIPRA' AND MK.IsPPC1Compliant = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS2' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS3' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1 AND MK.HasPrenatalDepressionScreeningPositiveResult = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS4' AND MK.IsPPC2Compliant = 1 
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS4A' AND MK.IsPPC2Compliant = 1 
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS5' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1 
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS6' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1 AND MK.HasPostpartumDepressionScreeningPositiveResult = 1
											THEN 1
											ELSE 0 
											END,
			DenominatorCount = @Denominator,
			@Numerator = HybridHit = CASE 
											WHEN MX.HEDISSubMetricCode = 'PDS1' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1
											THEN 1 
											WHEN MX.HEDISSubMetricCode = 'PDS1A' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1 AND MK.HasPrenatalDepressionScreeningTool = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS1CHIPRA' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreeningAtFirstTwo = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS2' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1 AND MK.HasPrenatalDepressionScreeningPositiveResult = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS3' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalDepressionScreening = 1 AND MK.HasPrenatalDepressionScreeningPositiveResult = 1 AND MK.HasPrenatalDepressionScreeningFurtherEvaluation = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS4' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS4A' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1 AND MK.HasPostpartumDepressionScreeningTool = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS5' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1 AND MK.HasPostpartumDepressionScreeningPositiveResult = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PDS6' AND MK.IsPPC2Compliant = 1 AND MK.HasPostpartumDepressionScreening = 1 AND MK.HasPostpartumDepressionScreeningPositiveResult = 1 AND MK.HasPostpartumDepressionScreeningFurtherEvaluation = 1
											THEN 1
											ELSE 0 
											END,
			HybridHitCount = @Numerator,
			MedicalRecordHit = @Numerator,
			MedicalRecordHitCount = @Numerator
	FROM	dbo.MemberMeasureMetricScoring AS MMMS
			INNER JOIN dbo.HEDISSubMetric AS MX
					ON MX.HEDISSubMetricID = MMMS.HEDISSubMetricID
			INNER JOIN #MeasureKey AS MK
					ON MK.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
	WHERE	MX.HEDISMeasureInit = 'PDS';

END
GO
