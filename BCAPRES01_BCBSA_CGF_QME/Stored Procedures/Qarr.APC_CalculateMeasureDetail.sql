SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/29/2016
-- Description:	Calculates the member-level results for the QARR APC measure.
-- =============================================
CREATE PROCEDURE [Qarr].[APC_CalculateMeasureDetail]
(
	@DataRunID int,
	@ForceRescore bit = 0,
	@QarrMeasureSetID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BeginInitSeedDate datetime;	--The start of the measurement year
	DECLARE @EndInitSeedDate datetime;		--The end of the measurement year
	DECLARE @SeedDate datetime;

	DECLARE @MeasureID int;
	DECLARE @MeasureSetID int;
	DECLARE @MeasureSetTypeID smallint;
	DECLARE @MeasureYear smallint;

	DECLARE @APCMeasureID int;
	DECLARE @APC1MetricID int;
	DECLARE @APC2MetricID int;
	DECLARE @APC3MetricID int;
	DECLARE @APC4MetricID int;

	--i) Retrieve the ID for the "HEDIS" measure set type...
	SELECT	@MeasureSetTypeID = MeasureSetTypeID 
	FROM	Measure.MeasureSetTypes 
	WHERE	Abbrev = 'HEDIS';

	--ii) Retrieve the measure set and measurement year data range used for the specified data run, requiring it be a "HEDIS" type measure set...
	SELECT	@BeginInitSeedDate = BDR.BeginInitSeedDate,
			@EndInitSeedDate = BDR.EndInitSeedDate,
			@MeasureSetID = BDR.MeasureSetID,
			@MeasureYear = YEAR(MMS.DefaultSeedDate) + 1,
			@SeedDate = BDR.SeedDate
	FROM	Batch.DataRuns AS BDR
			INNER JOIN Measure.MeasureSets AS MMS
					ON MMS.MeasureSetID = BDR.MeasureSetID
	WHERE	BDR.DataRunID = @DataRunID AND
			MMS.MeasureSetTypeID = @MeasureSetTypeID;

	--iii) Retrieve the ID for the WCC measure for the data run's measure set...
	SELECT	@MeasureID = MeasureID
	FROM	Measure.Measures AS MM
	WHERE	MM.MeasureSetID = @MeasureSetID AND
			MM.Abbrev = 'WCC';

	--iv) Retrieve the APC metric IDs for the specified QARR measure set...
	SELECT	@APCMeasureID = MM.MeasureID,
			@APC1MetricID = MIN(CASE WHEN MX.Abbrev = 'APC1' THEN MX.MetricID END),
			@APC2MetricID = MIN(CASE WHEN MX.Abbrev = 'APC2' THEN MX.MetricID END),
			@APC3MetricID = MIN(CASE WHEN MX.Abbrev = 'APC3' THEN MX.MetricID END),
			@APC4MetricID = MIN(CASE WHEN MX.Abbrev = 'APC4' THEN MX.MetricID END)
	FROM	Measure.Metrics AS MX
			INNER JOIN Measure.Measures AS MM
					ON MM.MeasureID = MX.MeasureID
			INNER JOIN Measure.MeasureSets AS MMS
					ON MMS.MeasureSetID = MM.MeasureSetID
			INNER JOIN Measure.MeasureSetTypes AS MMST
					ON MMST.MeasureSetTypeID = MMS.MeasureSetTypeID
	WHERE	MMST.Abbrev = 'QARR' AND
			MMS.MeasureSetID = @QarrMeasureSetID AND
			MM.Abbrev = 'APC'
	GROUP BY MM.MeasureID;

	IF @MeasureID IS NOT NULL AND
		@BeginInitSeedDate IS NOT NULL AND
		@EndInitSeedDate IS NOT NULL AND
		@SeedDate IS NOT NULL AND
		@APC1MetricID IS NOT NULL AND
		@APC2MetricID IS NOT NULL AND
		@APC3MetricID IS NOT NULL AND
		@APC4MetricID IS NOT NULL AND
		@APCMeasureID IS NOT NULL
		BEGIN;

			--1) Retrieve the QARR-APC eligible population as the HEDIS WCC denominator for 12-17 year olds...
			IF OBJECT_ID('tempdb..#EligiblePopulation') IS NOT NULL
				DROP TABLE #EligiblePopulation;

			SELECT DISTINCT
					RMD.Age,
					RMD.AgeMonths,
					RMD.BatchID,
					RMD.BeginDate,
					RMD.BitProductLines,
					RMD.DataRunID,
					RMD.DataSetID,
					RMD.DataSourceID,
					RMD.DSEntityID,
					RMD.DSMemberID,
					RMD.DSProviderID,
					RMD.EndDate,
					RMD.EnrollGroupID,
					RMD.EntityID,
					RMD.ExclusionTypeID,
					RMD.Gender,
					RMD.IsDenominator,
					RMD.IsSupplementalDenominator,
					RMD.KeyDate,
					@APCMeasureID AS MeasureID,
					CASE T.N	
						 WHEN 1
						 THEN @APC1MetricID
						 WHEN 2 
						 THEN @APC2MetricID
						 WHEN 3
						 THEN @APC3MetricID
						 WHEN 4
						 THEN @APC4MetricID
						 END AS MetricID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID,
					RMD.ResultTypeID,
					RMD.SourceDenominator,
					RMD.SourceDenominatorSrc,
					RMD.SysSampleRefID
			INTO	#EligiblePopulation
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN dbo.Tally AS T
							ON T.N BETWEEN 1 AND 4 --Creates dummy rows for each metric using "Tally" table
			WHERE	RMD.Age BETWEEN 12 AND 17 AND --The age range required by the measure
					RMD.DataRunID = @DataRunID AND --The targeted run
					RMD.IsDenominator = 1 AND --Is part of the eligible population
					RMD.IsExclusion = 0 AND --Not excluded
					RMD.MeasureID = @MeasureID AND --The WCC Measure
					RMD.ResultTypeID IN (1, 3); --Administrative/Hybrid

			CREATE UNIQUE CLUSTERED INDEX IX_#EligiblePopulation ON #EligiblePopulation (DSMemberID, MetricID, ResultTypeID);
		
			--2) Retrieve the code lists from the Ncqa.CodingECTs table (QARR codes were populated in the CodingECTs table to mirror value sets and pre-value-set coding tables)...
			--(INTERNAL NOTE: CodeTypeTranslator code adapted from year-to-year automatic value set updater)...
			IF OBJECT_ID('tempdb..#CodeList') IS NOT NULL
				DROP TABLE #CodeList;

			WITH CodeTypeTranslatorBase AS
			(
				SELECT DISTINCT TypeOfCode FROM Ncqa.CodingECTs WHERE MeasureYear = @MeasureYear
			),
			CodeTypeTranslator AS
			(/**/
				SELECT	CCT.Abbrev AS CodeTypeAbbrev, 
						CCT.CodeTypeID,
						CTTB.TypeOfCode
				FROM	Claim.CodeTypes AS CCT
						INNER JOIN CodeTypeTranslatorBase AS CTTB
								ON CCT.Abbrev = CASE 
													WHEN CTTB.TypeOfCode LIKE 'UB___' 
													THEN RIGHT(CTTB.TypeOfCode, 3) 
													WHEN CTTB.TypeOfCode = 'ICD9CM' 
													THEN 'ICD9Diag'
													WHEN CTTB.TypeOfCode = 'ICD9PCS'
													THEN 'ICD9Proc'
													WHEN CTTB.TypeOfCode = 'ICD10CM' 
													THEN 'ICD10Diag'
													WHEN CTTB.TypeOfCode = 'ICD10PCS'
													THEN 'ICD10Proc'
													WHEN CTTB.TypeOfCode LIKE 'ICD9-____' OR CTTB.TypeOfCode = 'CPT-Mod'
													THEN REPLACE(CTTB.TypeOfCode, '-', '')
													WHEN CTTB.TypeOfCode = 'CPT-CAT-II'
													THEN 'CPT2'
													ELSE CTTB.TypeOfCode
													END
			),
			CodingECTsTranslated AS
			(
				SELECT ECT.*, ECT.TableName AS Reference1, ECT.MeasureYear AS Reference4, CTT.CodeTypeAbbrev, CTT.CodeTypeID FROM Ncqa.CodingECTs AS ECT INNER JOIN CodeTypeTranslator AS CTT ON ECT.TypeOfCode = CTT.TypeOfCode WHERE ECT.MeasureYear = @MeasureYear
			)
			SELECT	t.Code,
					t.CodeTypeAbbrev,
					t.CodeTypeID,
					t.[Description],
					t.TableName,
					t.TableLetter,
					t.Measure,
					t.MeasureYear,
					@APCMeasureID AS MeasureID,
					CASE t.TableLetter
						 WHEN '1'
						 THEN @APC1MetricID
						 WHEN '2'
						 THEN @APC2MetricID
						 WHEN '3' 
						 THEN @APC3MetricID
						 WHEN '4'
						 THEN @APC4MetricID
						 END AS MetricID
			INTO	#CodeList
			FROM	CodingECTsTranslated AS t
			WHERE	t.Measure = 'QARR-APC';

			CREATE UNIQUE CLUSTERED INDEX IX_#CodeList ON #CodeList (Code, CodeTypeID, MetricID);

			--3) Identify claims that have codes matching the code list during the measurement year...
			IF OBJECT_ID('tempdb..#IdentifiedClaims') IS NOT NULL
				DROP TABLE #IdentifiedClaims;

			SELECT DISTINCT
					CCL.BeginDate,
					CCC.Code,
					CCC.CodeTypeID,
					CCL.DataSourceID,
					CCC.DSClaimCodeID,
					CCL.DSClaimLineID,
					CCL.DSMemberID,
					CCL.EndDate,
					ISNULL(CCL.EndDate, CCL.BeginDate) AS EvalDate,
					CCL.IsSupplemental,
					CL.MeasureID,
					CL.MetricID
			INTO	#IdentifiedClaims
			FROM	#EligiblePopulation AS EP
					INNER JOIN Claim.ClaimLines AS CCL
							ON CCL.DataSetID = EP.DataSetID AND
								CCL.DSMemberID = EP.DSMemberID
					INNER JOIN Claim.ClaimCodes AS CCC
							ON CCC.DSClaimLineID = CCL.DSClaimLineID AND
								CCC.DataSetID = EP.DataSetID AND
								CCC.DSMemberID = EP.DSMemberID
					INNER JOIN #CodeList AS CL
							ON CL.Code = CCC.Code AND
							 CL.CodeTypeID = CCC.CodeTypeID AND
							 CL.MetricID = EP.MetricID
			WHERE	CCL.ClaimTypeID = 1 AND --Encounter Claims
					(
						(CCL.EndDate IS NULL AND CCL.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate) OR
						(CCL.EndDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate)
					);

			CREATE UNIQUE CLUSTERED INDEX IX_#IdentifiedClaims ON #IdentifiedClaims (DSMemberID, DSClaimCodeID, MetricID);

			--4) Leverage identified claims to indicate numerator compliance and create final results data...
			IF @ForceRescore = 1 OR NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail WHERE MeasureID = @APCMeasureID AND DataRunID = @DataRunID)
				BEGIN;
					IF @ForceRescore = 1
						DELETE FROM Result.MeasureDetail WHERE MeasureID = @APCMeasureID AND DataRunID = @DataRunID; 

					INSERT INTO Result.MeasureDetail
							(Age,
							AgeMonths,
							BatchID,
							BeginDate,
							BitProductLines,
							DataRunID,
							DataSetID,
							DataSourceID,
							DSEntityID,
							DSMemberID,
							DSProviderID,
							EndDate,
							EnrollGroupID,
							EntityID,
							ExclusionTypeID,
							Gender,
							IsDenominator,
							IsExclusion,
							IsNumerator,
							IsNumeratorAdmin,
							IsSupplementalDenominator,
							IsSupplementalExclusion,
							IsSupplementalNumerator,
							KeyDate,
							MeasureID,
							MeasureXrefID,
							MetricID,
							MetricXrefID,
							PayerID,
							PopulationID,
							ProductLineID,
							ResultTypeID,
							SourceDenominator,
							SourceDenominatorSrc,
							SourceNumerator,
							SourceNumeratorSrc,
							SysSampleRefID)
					SELECT	EP.Age,
							EP.AgeMonths,
							EP.BatchID,
							EP.BeginDate,
							EP.BitProductLines,
							EP.DataRunID,
							EP.DataSetID,
							EP.DataSourceID,
							EP.DSEntityID,
							EP.DSMemberID,
							EP.DSProviderID,
							EP.EndDate,
							EP.EnrollGroupID,
							EP.EntityID,
							EP.ExclusionTypeID,
							EP.Gender,
							EP.IsDenominator,
							0 AS IsExclusion,
							CONVERT(bit, CASE WHEN IC.DSClaimLineID IS NOT NULL THEN 1 ELSE 0 END) AS IsNumerator,
							CONVERT(bit, CASE WHEN IC.DSClaimLineID IS NOT NULL THEN 1 ELSE 0 END) AS IsNumeratorAdmin,
							EP.IsSupplementalDenominator,
							0 AS IsSupplementalExclusion,
							ISNULL(IC.IsSupplemental, 0) AS IsSupplementalNumerator,
							EP.KeyDate,
							EP.MeasureID,
							MM.MeasureXrefID,
							EP.MetricID,
							MX.MetricXrefID,
							EP.PayerID,
							EP.PopulationID,
							EP.ProductLineID,
							EP.ResultTypeID,
							EP.SourceDenominator,
							EP.SourceDenominatorSrc,
							IC.DSClaimCodeID AS SourceNumerator,
							IC.DataSourceID AS SourceNumeratorSrc,
							EP.SysSampleRefID
					FROM	#EligiblePopulation AS EP
							INNER JOIN Measure.Metrics AS MX
									ON MX.MetricID = EP.MetricID
							INNER JOIN Measure.Measures AS MM
									ON MM.MeasureID = EP.MeasureID
							OUTER APPLY (
											SELECT TOP 1
													tIC.*
											FROM	#IdentifiedClaims AS tIC
											WHERE	tIC.DSMemberID = EP.DSMemberID AND	
													tIC.MetricID = EP.MetricID
											ORDER BY tIC.IsSupplemental, tIC.EvalDate, tIC.DSClaimCodeID
										) AS IC
					ORDER BY EP.ResultTypeID, EP.BatchID, EP.PopulationID, EP.DSMemberID, EP.MetricID;

					EXEC Result.SummarizeMeasureDetail @DataRunID = @DataRunID;
				END;
			ELSE	
				RAISERROR('The measure could not be processed.  The specified run already has results.', 16, 1);
		END;
	ELSE
		RAISERROR('The measure could not be found.  Verify that the specified run exists and the run points to a HEDIS measure set.', 16, 1);

END
GO
GRANT EXECUTE ON  [Qarr].[APC_CalculateMeasureDetail] TO [Processor]
GO
