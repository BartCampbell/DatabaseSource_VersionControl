SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CalculateReportedScoring] 
(
	@HedisMeasure varchar(16) = NULL,
	@MemberID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TranCount int;
	SET @TranCount = @@TRANCOUNT;

	DECLARE @InvertAdminCDC2 bit = 1;

	BEGIN TRY;
		BEGIN TRANSACTION TCalculateReportedScoring;

		DECLARE @Product varchar(20);
		DECLARE @ProductLine varchar(20);
		
		--1) Determine product line and product for member, since the denominator calculation has to account for all members of a given product line, product and measure collectively.
		SELECT @Product = Product, @ProductLine = ProductLine FROM dbo.Member WHERE MemberID = @MemberID;

		--2) Determine denominator records (e.g. members/events in the "411")...
		--2a) Remove exclusions, identify the sample sizes, and resequence the remaining records...

		SELECT MeasureID, Product, ProductLine, COUNT(*) AS SampleSize INTO #SampleSizes FROM dbo.MemberMeasureSample AS t WHERE t.SampleType = 'sample'  AND (@HedisMeasure IS NULL OR MeasureID IN (SELECT MeasureID FROM dbo.Measure WHERE HEDISMeasure = @HedisMeasure)) GROUP BY MeasureID, Product, ProductLine
		CREATE UNIQUE CLUSTERED INDEX IX_#SampleSizes ON #SampleSizes (MeasureID, Product, ProductLine);

		SELECT	MMMS.HEDISSubMetricID,
				MMS.MeasureID,
				MMS.MemberMeasureSampleID,
				MMMS.MemberMeasureMetricScoringID,
				MMS.Product,
				MMS.ProductLine,
				MMS.SampleDrawOrder,
				ROW_NUMBER() OVER (PARTITION BY MMS.ProductLine, MMS.Product, MMMS.HEDISSubMetricID ORDER BY MMS.SampleDrawOrder) AS SeqOrder,
				ISNULL(MSSO.SampleSize, SS.SampleSize) AS SampleSize
		INTO	#Samples
		FROM	dbo.MemberMeasureSample AS MMS
				INNER JOIN dbo.Measure AS M
						ON MMS.MeasureID = M.MeasureID
				INNER JOIN #SampleSizes AS SS
						ON MMS.MeasureID = SS.MeasureID AND
							MMS.Product = SS.Product AND
							MMS.ProductLine = SS.ProductLine
				INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS
						ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID
				LEFT OUTER JOIN dbo.MetricSampleSizeOverride AS MSSO
						ON MSSO.HEDISSubMetricID = MMMS.HEDISSubMetricID AND
							MSSO.Product = MMS.Product AND
							MSSO.ProductLine = MMS.ProductLine
				CROSS APPLY (
								SELECT	CONVERT(bit, MAX(CASE WHEN tB.ExclusionCount > 0 OR 
																	tB.SampleVoidCount > 0 OR 
																	tB.ReqExclCount > 0 OR 
																	tB.DenominatorCount = 0 OR 
																	tB.PreExclusionAdmin = 1 OR 
																	tB.PreExclusionValidData = 1 OR 
																	tB.PreExclusionPlanEmployee = 1 
																THEN 1 
																ELSE 0 END)) AS IsExclusion 
								FROM	dbo.MemberMeasureMetricScoring AS tB 
								WHERE	tB.MemberMeasureMetricScoringID = MMMS.MemberMeasureMetricScoringID
							) AS Excl
		WHERE	((@HedisMeasure IS NULL) OR (M.HEDISMeasure = @HedisMeasure)) AND
				((@Product IS NULL) OR (MMS.Product = @Product)) AND
				((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine)) AND
				(Excl.IsExclusion = 0)
		OPTION	(OPTIMIZE FOR (@HedisMeasure = NULL, @Product = NULL, @ProductLine = NULL));	

		--2b) Delete records still in the oversample...
		DELETE FROM #Samples WHERE SeqOrder > SampleSize;

		CREATE UNIQUE CLUSTERED INDEX IX_#Samples ON #Samples (MemberMeasureMetricScoringID);
		CREATE UNIQUE NONCLUSTERED INDEX IX_#Samples2 ON #Samples (HEDISSubMetricID, ProductLine, Product, SampleDrawOrder);
			
		--3) Populate "reported" bit fields...
		SELECT MAX(SampleDrawOrder) AS SampleDrawOrder, MeasureID, HEDISSubMetricID, Product, ProductLine INTO #ExclusionLimit FROM #Samples AS tA GROUP BY HEDISSubMetricID, MeasureID, Product, ProductLine
		CREATE UNIQUE CLUSTERED INDEX IX_#ExclusionLimit ON #ExclusionLimit (HEDISSubMetricID, Product, ProductLine);

		/*
		SELECT M.HEDISMeasure, t.* FROM #SampleSizes AS t INNER JOIN dbo.Measure AS M ON M.MeasureID = t.MeasureID ORDER BY t.ProductLine, t.Product, M.HEDISMeasure;
		SELECT MX.HEDISMeasureInit, MX.HEDISSubMetricCode, MX.ReportName, t.* FROM #Samples AS t INNER JOIN dbo.HEDISSubMetric AS MX ON MX.HEDISSubMetricID = t.HEDISSubMetricID ORDER BY t.ProductLine, t.Product, MX.HEDISSubMetricCode, t.SeqOrder;
		SELECT MX.HEDISMeasureInit, MX.HEDISSubMetricCode, MX.ReportName, t.* FROM #ExclusionLimit AS t INNER JOIN dbo.HEDISSubMetric AS MX ON MX.HEDISSubMetricID = t.HEDISSubMetricID ORDER BY t.ProductLine, t.Product, MX.HEDISSubMetricCode;	
		*/

		UPDATE	MMMS
		SET		Denominator = CONVERT(bit, CASE WHEN MMMS.DenominatorCount > 0 AND ISNULL(MMMS.ReqExclCount, 0) <= 0 AND S.MemberMeasureSampleID IS NOT NULL THEN 1 ELSE 0 END),  --"411" Denominator
				AdministrativeHit = CONVERT(bit, ISNULL(NULLIF(CASE WHEN MMMS.AdministrativeHitCount > 0 AND MMMS.HybridHitCount > 0 THEN 1 ELSE 0 END - CASE WHEN MX.HEDISSubMetricCode = 'CDC2' AND @InvertAdminCDC2 = 1 THEN 1 ELSE 0 END, -1), 1)),
				MedicalRecordHit = CONVERT(bit, ISNULL(NULLIF(CASE WHEN MMMS.MedicalRecordHitCount > 0 AND MMMS.HybridHitCount > 0 AND MMMS.AdministrativeHitCount = 0 OR (MMMS.HybridHitCount > 0 AND MMMS.AdministrativeHitCount = 0) THEN 1 ELSE 0 END - CASE WHEN MX.HEDISSubMetricCode = 'CDC2' AND MMMS.MedicalRecordHitCount > 0 AND MMMS.HybridHitCount > 0 AND MMMS.AdministrativeHitCount = 0 THEN 1 ELSE 0 END, -1), 1)),
				HybridHit = CONVERT(bit, ISNULL(NULLIF(CASE WHEN MMMS.HybridHitCount > 0 THEN 1 ELSE 0 END - CASE WHEN MX.HEDISSubMetricCode = 'CDC2' THEN 1 ELSE 0 END, -1), 1)),
				ReqExclusion = CONVERT(bit, CASE WHEN MMMS.ReqExclCount > 0 AND MMS.SampleDrawOrder <= ISNULL(NULLIF(Excl.SampleDrawOrder, 0), MMS.SampleDrawOrder) THEN 1 ELSE 0 END),
				Exclusion = CONVERT(bit, CASE WHEN (MMMS.ExclusionCount > 0) AND MMS.SampleDrawOrder <= ISNULL(NULLIF(Excl.SampleDrawOrder, 0), MMS.SampleDrawOrder) THEN 1 ELSE 0 END), --Extra logic to not report exclusions from the oversample, as well as if the whole sample is somehow excluded
				SampleVoid = CONVERT(bit, CASE WHEN (MMMS.SampleVoidCount > 0 OR MMMS.PreExclusionValidData = 1 OR MMMS.PreExclusionPlanEmployee = 1 OR MMMS.PreExclusionAdmin = 1) AND MMS.SampleDrawOrder <= ISNULL(NULLIF(Excl.SampleDrawOrder, 0), MMS.SampleDrawOrder) THEN 1 ELSE 0 END) --Extra logic to not report exclusions from the oversample, as well as if the whole sample is somehow excluded
		FROM	dbo.MemberMeasureMetricScoring AS MMMS
				INNER JOIN dbo.MemberMeasureSample AS MMS
						ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID
				INNER JOIN dbo.HEDISSubMetric AS MX
						ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
				LEFT OUTER JOIN #Samples AS S
						ON MMMS.MemberMeasureSampleID = S.MemberMeasureSampleID AND
							MMMS.MemberMeasureMetricScoringID = S.MemberMeasureMetricScoringID
				LEFT OUTER JOIN #ExclusionLimit AS Excl 
						ON MMS.MeasureID = Excl.MeasureID AND
							Excl.HEDISSubMetricID = MMMS.HEDISSubMetricID AND
							MMS.Product = Excl.Product AND
							MMS.ProductLine = Excl.ProductLine
		WHERE	((@HedisMeasure IS NULL) OR (MX.HEDISMeasureInit = @HedisMeasure)) AND
				((@Product IS NULL) OR (MMS.Product = @Product)) AND
				((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine))
		OPTION	(OPTIMIZE FOR (@HedisMeasure = NULL, @Product = NULL, @ProductLine = NULL));

		WITH HbA1cMRR AS
		(
			--Identifies that any part of HbA1c metrics were determined via MRR for the most-recent HbA1c
			SELECT DISTINCT
					MMMS.MemberMeasureSampleID
			FROM	dbo.HEDISSubMetric AS MX
					INNER JOIN dbo.MemberMeasureMetricScoring AS MMMS
							ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
			WHERE	MX.HEDISMeasureInit = 'CDC' AND
					MX.HEDISSubMetricCode IN ('CDC1','CDC2','CDC3','CDC10') AND
					MMMS.MedicalRecordHitCount > 0 AND
					(
						MX.HEDISSubMetricCode <> 'CDC1' OR
						MMMS.AdministrativeHitCount = 0
					)
		)
		UPDATE	MMMS
		SET		AdministrativeHit = 0,
				MedicalRecordHit = 1
		FROM	dbo.MemberMeasureMetricScoring AS MMMS
				INNER JOIN dbo.MemberMeasureSample AS MMS
						ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID
				INNER JOIN dbo.HEDISSubMetric AS MX
						ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
				INNER JOIN HbA1cMRR AS HB
						ON HB.MemberMeasureSampleID = MMMS.MemberMeasureSampleID
		WHERE	(MX.HEDISSubMetricCode = 'CDC2') AND
				(MMMS.AdministrativeHit = 1) AND
				(MMMS.HybridHit = 1) AND
				(MMMS.MedicalRecordHit = 0) AND
				((@HedisMeasure IS NULL) OR (MX.HEDISMeasureInit = @HedisMeasure)) AND
				((@Product IS NULL) OR (MMS.Product = @Product)) AND
				((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine))
		OPTION	(OPTIMIZE FOR (@HedisMeasure = NULL, @Product = NULL, @ProductLine = NULL));

		UPDATE	MMMS
		SET		AdministrativeHit = 0,
				MedicalRecordHit = 0
		FROM	dbo.MemberMeasureMetricScoring AS MMMS
				INNER JOIN dbo.MemberMeasureSample AS MMS
						ON MMMS.MemberMeasureSampleID = MMS.MemberMeasureSampleID
				INNER JOIN dbo.HEDISSubMetric AS MX
						ON MMMS.HEDISSubMetricID = MX.HEDISSubMetricID
		WHERE	(MX.HEDISSubMetricCode = 'CDC2') AND
				(MMMS.HybridHit = 0) AND
				((@HedisMeasure IS NULL) OR (MX.HEDISMeasureInit = @HedisMeasure)) AND
				((@Product IS NULL) OR (MMS.Product = @Product)) AND
				((@ProductLine IS NULL) OR (MMS.ProductLine = @ProductLine))
		OPTION	(OPTIMIZE FOR (@HedisMeasure = NULL, @Product = NULL, @ProductLine = NULL));

		COMMIT TRANSACTION TCalculateReportedScoring;
	END TRY
	BEGIN CATCH
		WHILE @TranCount > @@TRANCOUNT
			ROLLBACK;

		PRINT ERROR_MESSAGE();
	END CATCH;
END
GO
