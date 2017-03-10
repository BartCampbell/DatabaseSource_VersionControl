SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/8/2013
-- Description:	Refreshes the means and percentiles referenced in reports.
-- =============================================
CREATE PROCEDURE [Report].[RefreshMeansAndPercentiles]
(
	@ForceRefresh bit = 0,
	@Year smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CountActual int;
	DECLARE @CountExpected int;

	SELECT	@CountExpected = COUNT(*) 
	FROM	Ncqa.IDSS_MeansAndPercentiles AS IMP 
			INNER JOIN Product.ProductLines AS PPL
					ON IMP.ProductLine = PPL.Descr OR 
						(IMP.ProductLine = 'Medicare' AND PPL.Abbrev = 'S')
	WHERE	(IdssColumnID IS NOT NULL) AND
			(MeasureAbbrev IS NOT NULL) AND 
			(MetricAbbrev IS NOT NULL) 

	IF OBJECT_ID('tempdb..#Step1') IS NOT NULL
		DROP TABLE #Step1;

	--1) Convert the product line, class, measure and metrics to valid identifiers...
	SELECT	IMP.FromAgeMonths,
			IMP.FromAgeMonths + (FromAgeYears * 12) AS FromAgeTotMonths,
			IMP.FromAgeYears,
			IMP.Gender,
			IMP.IdssColumnID,
			IMP.IdssMeanPercentID,
			IMP.IdssYear,
			IMP.Mean,
			MMMR.MeasureXrefID, 
			MMXR.MetricXrefID, 
			IMP.Percent05,
			IMP.Percent10,
			IMP.Percent25,
			IMP.Percent50,
			IMP.Percent75,
			IMP.Percent90,
			IMP.Percent95,
			PPC.ProductClassID, 
			PPL.ProductLineID, 
			IMP.ToAgeMonths,
			IMP.ToAgeMonths + (ToAgeYears * 12) AS ToAgeTotMonths,
			IMP.ToAgeYears
	INTO	#Step1
	FROM	Ncqa.IDSS_MeansAndPercentiles AS IMP
			INNER JOIN Product.ProductLines AS PPL
					ON IMP.ProductLine = PPL.Descr OR 
						(IMP.ProductLine = 'Medicare' AND PPL.Abbrev = 'S')
			INNER JOIN Product.ProductClasses AS PPC
					ON IMP.ProductClass = PPC.Abbrev
			INNER JOIN Measure.MetricXrefs AS MMXR
					ON IMP.MetricAbbrev = MMXR.Abbrev
			INNER JOIN Measure.MeasureXrefs AS MMMR
					ON IMP.MeasureAbbrev = MMMR.Abbrev
	WHERE	(@Year IS NULL) OR (IdssYear = @Year)
	OPTION (OPTIMIZE FOR (@Year = NULL));
					
	SET @CountActual = @@ROWCOUNT;

	IF ISNULL(@CountActual, 0) >= ISNULL(@CountExpected, 0) 
		BEGIN;
		
			IF OBJECT_ID('tempdb..#Payers') IS NOT NULL
				DROP TABLE #Payers;
		
			SELECT DISTINCT
					PP.PayerID,
					PPT.ProductClassID,
					PPL.ProductLineID
			INTO	#Payers
			FROM	Product.Payers AS PP
					INNER JOIN Product.PayerProductLines AS PPL
							ON PP.PayerID = PPL.PayerID				
					INNER JOIN Product.ProductTypes AS PPT
							ON PP.ProductTypeID = PPT.ProductTypeID
					
			CREATE UNIQUE CLUSTERED INDEX IX_#Payers ON #Payers (ProductLineID, ProductClassID, PayerID);
		
			SELECT	@CountExpected = COUNT(*) 
			FROM	#Step1 AS s 
					INNER JOIN #Payers AS P
							ON s.ProductClassID = P.ProductClassID AND
								s.ProductLineID = P.ProductLineID
					INNER JOIN Measure.Metrics AS MX 
							ON s.MetricXrefID = MX.MetricXrefID
					LEFT OUTER JOIN Measure.Measures AS MM
							ON s.MeasureXrefID = MM.MeasureXrefID AND
								MX.MeasureID = MM.MeasureID
					LEFT OUTER JOIN Measure.MeasureSets AS MMS
							ON MM.MeasureSetID = MMS.MeasureSetID
			WHERE	(MMS.MeasureSetID IS NULL) OR (s.IdssYear <= YEAR(MMS.DefaultSeedDate));
		
			IF OBJECT_ID('tempdb..#Step2') IS NOT NULL
				DROP TABLE #Step2;
			
			--2) Convert payers and age bands...
			SELECT	MABS.AgeBandID,
					MABS.AgeBandSegID,
					s.FromAgeMonths,
					s.FromAgeYears,
					s.Gender,
					s.IdssColumnID,
					s.IdssMeanPercentID,
					s.IdssYear,
					s.Mean,
					MM.Abbrev AS Measure,
					MM.MeasureID,
					s.MeasureXrefID,
					MX.Abbrev AS Metric,
					MX.MetricID,
					s.MetricXrefID,
					P.PayerID,
					s.Percent05,
					s.Percent10,
					s.Percent25,
					s.Percent50,
					s.Percent75,
					s.Percent90,
					s.Percent95,
					s.ProductClassID,
					s.ProductLineID,
					s.ToAgeMonths,
					s.ToAgeYears
			INTO	#Step2
			FROM	#Step1 AS s
					INNER JOIN #Payers AS P
							ON s.ProductClassID = P.ProductClassID AND
								s.ProductLineID = P.ProductLineID
					INNER JOIN Measure.Metrics AS MX
							ON s.MetricXrefID = MX.MetricXrefID
					INNER JOIN Measure.Measures AS MM
							ON s.MeasureXrefID = MM.MeasureXrefID AND
								MX.MeasureID = MM.MeasureID
					INNER JOIN Measure.MeasureProductLines AS MMPL
							ON MM.MeasureID = MMPL.MeasureID AND
								s.ProductLineID = MMPL.ProductLineID
					INNER JOIN Measure.MeasureSets AS MMS
							ON MM.MeasureSetID = MMS.MeasureSetID
					LEFT OUTER JOIN Measure.AgeBandSegments AS MABS
							ON MX.AgeBandID = MABS.AgeBandID AND
								s.FromAgeTotMonths = ISNULL(MABS.FromAgeTotMonths, 0) AND
								s.ToAgeTotMonths = ISNULL(MABS.ToAgeTotMonths, (255 * 12 + 11)) AND
								(
									s.Gender = MABS.Gender OR
									s.Gender IS NULL AND MABS.Gender IS NULL
								) AND
								(
									MABS.ProductLineID IS NULL OR 
									s.ProductLineID = MABS.ProductLineID	
								)
			WHERE	(s.IdssYear <= YEAR(DATEADD(yy, 1, MMS.DefaultSeedDate))) AND
					(	
						MABS.AgeBandSegID IS NOT NULL OR 
						(
							(s.FromAgeTotMonths IS NULL) AND
							(s.ToAgeTotMonths IS NULL)
						)
					)
					--(	
					--	MABS.AgeBandSegID IS NULL AND 
					--	(
					--		(s.FromAgeTotMonths IS NOT NULL) OR
					--		(s.ToAgeTotMonths IS NOT NULL)
					--	)
					--)
					;	
								
			SET @CountActual = @@ROWCOUNT;
		
			--SELECT @CountActual AS [@CountActual], @CountExpected AS [@CountExpected];
			--SELECT * FROM #Step1

			--3) Finalize conversion, fixing percentage values
			IF @ForceRefresh = 1 AND @Year IS NULL
				TRUNCATE TABLE Report.MeansAndPercentiles;
			ELSE IF @ForceRefresh = 1 AND @Year IS NOT NULL
				DELETE FROM Report.MeansAndPercentiles WHERE IdssYear = @Year;
					
			WITH Existing AS
			(
				SELECT DISTINCT IdssMeanPercentID FROM Report.MeansAndPercentiles
			)
			INSERT INTO Report.MeansAndPercentiles
					(AgeBandID,
					AgeBandSegID,
					FieldID,
					IdssColumnID,
					IdssMeanPercentID,
					IdssYear,
					Mean,
					MeasureID,
					MeasureXrefID,
					MetricID,
					MetricXrefID,
					PayerID,
					Percent05,
					Percent10,
					Percent25,
					Percent50,
					Percent75,
					Percent90,
					Percent95,
					ProductLineID)
			SELECT  s.AgeBandID,
					s.AgeBandSegID,
					IC.FieldID,
					s.IdssColumnID,
					s.IdssMeanPercentID,
					s.IdssYear,
					s.Mean,
					s.MeasureID,
					s.MeasureXrefID,
					s.MetricID,
					s.MetricXrefID,
					s.PayerID,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent05 / 100 ELSE s.Percent05 END AS Percent05,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent10 / 100 ELSE s.Percent10 END AS Percent10,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent25 / 100 ELSE s.Percent25 END AS Percent25,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent50 / 100 ELSE s.Percent50 END AS Percent50,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent75 / 100 ELSE s.Percent75 END AS Percent75,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent90 / 100 ELSE s.Percent90 END AS Percent90,
					CASE WHEN RF.NumberFormat IN ('#,##0.0%','#,##0.00%') THEN s.Percent95 / 100 ELSE s.Percent95 END AS Percent95,
					s.ProductLineID
			FROM	#Step2 AS s
					INNER JOIN Ncqa.IDSS_Columns AS IC
							ON s.IdssColumnID = IC.IdssColumnID
					INNER JOIN Report.Fields AS RF
							ON IC.FieldID = RF.FieldID
					LEFT OUTER JOIN Existing AS X
							ON s.IdssMeanPercentID = X.IdssMeanPercentID
			WHERE	(X.IdssMeanPercentID IS NULL)
			ORDER BY IdssMeanPercentID, PayerID, MeasureID, MetricID;
		END;
	ELSE
		RAISERROR('Unable to convert all mean and percentile product lines, classes, measures and metrics.', 16, 1);

END

GO
GRANT VIEW DEFINITION ON  [Report].[RefreshMeansAndPercentiles] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[RefreshMeansAndPercentiles] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[RefreshMeansAndPercentiles] TO [Processor]
GO
