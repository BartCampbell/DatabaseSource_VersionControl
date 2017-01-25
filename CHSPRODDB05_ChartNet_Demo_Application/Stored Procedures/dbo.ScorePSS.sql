SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ScorePSS]
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
	WHERE	M.HEDISMeasure = 'PSS';

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
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								(
									tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate OR
									tMR1.ServiceDate BETWEEN a.FirstTwoEnrolledPrenatalStartDate AND a.FirstTwoEnrolledPrenatalEndDate
								) AND
								tMR1.ScreenedForSmoking IN ('Yes, member smoker', 'Yes, member not smoker')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalScreenedForSmoking,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								(
									tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate --OR
									--tMR1.ServiceDate BETWEEN a.FirstTwoEnrolledPrenatalStartDate AND a.FirstTwoEnrolledPrenatalEndDate
								) AND
								tMR1.ScreenedForSmoking IN ('Yes, member smoker', 'Yes, member not smoker')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalScreenedForSmokingNoEnroll,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								(
									tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate OR
									tMR1.ServiceDate BETWEEN a.FirstTwoEnrolledPrenatalStartDate AND a.FirstTwoEnrolledPrenatalEndDate
								) AND
								tMR1.ScreenedForExposure IN ('Yes, member exposed', 'Yes, member not exposed')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalScreenedForExposure,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								(
									tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate OR
									tMR1.ServiceDate BETWEEN a.FirstTwoEnrolledPrenatalStartDate AND a.FirstTwoEnrolledPrenatalEndDate
								) AND
								tMR1.ScreenedForSmoking IN ('Yes, member smoker')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalScreenedForSmokingPositive,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								(
									tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate OR
									tMR1.ServiceDate BETWEEN a.FirstTwoEnrolledPrenatalStartDate AND a.FirstTwoEnrolledPrenatalEndDate
								) AND
								tMR1.ScreenedForExposure IN ('Yes, member exposed')

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalScreenedForExposurePositive,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								--tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate AND
								tMR1.EvidenceOfSmokingCounseling = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalCounselingForSmoking,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								--tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate AND
								tMR1.EvidenceOfSmokingExposure = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalCounselingForExposure,
			CASE 
				WHEN 
					EXISTS (
						SELECT	TOP 1 
								1
						FROM	dbo.MedicalRecordPSSScreening AS tMR1
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
								--tMR1.ServiceDate BETWEEN a.FirstTwoPrenatalStartDate AND a.FirstTwoPrenatalEndDate AND
								tMR1.EvidenceStoppedSmoking = 1

					)
				THEN 1
				ELSE 0 
				END AS HasPrenatalStoppedSmoking
	INTO	#MeasureKey
	FROM	#MeasureBase AS a

	DECLARE @Denominator bit = 1;
	DECLARE @Numerator bit = 1;

	UPDATE	MMMS
	SET		@Denominator = Denominator = CASE 
											WHEN MX.HEDISSubMetricCode = 'PSS1' AND MK.IsPPC1Compliant = 1 
											THEN 1 
											WHEN MX.HEDISSubMetricCode = 'PSS1CHIPRA' AND MK.IsPPC1Compliant = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS2' AND MK.IsPPC1Compliant = 1 
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS3' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmoking = 1 AND MK.HasPrenatalScreenedForSmokingPositive = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS4' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForExposure = 1 AND MK.HasPrenatalScreenedForExposurePositive = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS5' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmoking = 1 AND MK.HasPrenatalScreenedForSmokingPositive = 1
											THEN 1
											ELSE 0 
											END,
			DenominatorCount = @Denominator,
			@Numerator = HybridHit = CASE 
											WHEN MX.HEDISSubMetricCode = 'PSS1' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmoking = 1
											THEN 1 
											WHEN MX.HEDISSubMetricCode = 'PSS1CHIPRA' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmokingNoEnroll = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS2' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForExposure = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS3' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmoking = 1 AND HasPrenatalScreenedForSmokingPositive = 1 AND HasPrenatalCounselingForSmoking = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS4' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForExposure = 1 AND HasPrenatalScreenedForExposurePositive = 1 AND HasPrenatalCounselingForExposure = 1
											THEN 1
											WHEN MX.HEDISSubMetricCode = 'PSS5' AND MK.IsPPC1Compliant = 1 AND MK.HasPrenatalScreenedForSmoking = 1 AND MK.HasPrenatalScreenedForSmokingPositive = 1 AND MK.HasPrenatalStoppedSmoking = 1
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
	WHERE	MX.HEDISMeasureInit = 'PSS';

END
GO
