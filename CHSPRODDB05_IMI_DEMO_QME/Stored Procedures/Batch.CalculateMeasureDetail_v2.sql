SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/22/2011
-- Description:	Calculates the detailed measure results.
-- =============================================
CREATE PROCEDURE [Batch].[CalculateMeasureDetail_v2]
(
	@BatchID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);

	DECLARE @Result int;

	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Calculating detailed measure results for the batch failed!  No batch was specified.', 16, 1);
				
			DECLARE @CountRecords int;
			
			SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = DR.DataRunID,
					@DataSetID = DS.DataSetID,
					@EndInitSeedDate = DR.EndInitSeedDate,
					@IsLogged = DR.IsLogged,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
			WHERE	(B.BatchID = @BatchID);
			
			--i) Purge any existing records for the batch...
			DELETE FROM Result.MeasureDetail WHERE BatchID = @BatchID;

			--1) Insert the eligible populations (denominators)...
			--1a) Identify denominator-related entities
			SELECT	ME.AgeAsOfDays, 
					ME.AgeAsOfMonths,
					SUM(DISTINCT PPL.BitValue) AS BitProductLines,
					METMM.EntityID, 
					MM.MeasureID, 
					MM.MeasureXrefID, 
					METMM.MetricID, 
					MX.MetricXrefID
			INTO	#MetricEligiblePopulationKey
			FROM	Measure.EntityToMetricMapping AS METMM
					INNER JOIN Measure.Entities AS ME
							ON METMM.EntityID = ME.EntityID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID 
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
					INNER JOIN Measure.EntityProductLines AS MEPL
							ON METMM.EntityID = MEPL.EntityID AND
								ME.EntityID = MEPL.EntityID
					INNER JOIN Measure.MeasureProductLines AS MMPL
							ON MX.MeasureID = MMPL.MeasureID AND
								MEPL.ProductLineID = MMPL.ProductLineID
					INNER JOIN Product.ProductLines AS PPL
							ON MMPL.ProductLineID = PPL.ProductLineID
			WHERE	(MMT.MapTypeGuid = '1615D299-5BA1-4455-AE77-BE49646F54A4')
			GROUP BY ME.AgeAsOfDays, 
					ME.AgeAsOfMonths,
					METMM.EntityID, 
					MM.MeasureID, 
					MM.MeasureXrefID, 
					METMM.MetricID, 
					MX.MetricXrefID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricEligiblePopulationKey ON #MetricEligiblePopulationKey (EntityID, MetricID, MeasureID);
			
			--1b) Prepare the Payer-Product-Line bit-wise key...
			SELECT	SUM(CONVERT(bigint, BitValue)) AS BitProductLines, PP.PayerID
			INTO	#PayerBitProductLines
			fROM	Product.Payers AS PP
					INNER JOIN Product.PayerProductLines AS PPPL
							ON PP.PayerID = PPPL.PayerID
					INNER JOIN Product.ProductLines AS PPL
							ON PPPL.ProductLineID = PPL.ProductLineID
			GROUP BY PP.PayerID;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#PayerBitProductLines ON #PayerBitProductLines (PayerID);
			
			--1c) Calculate eligible populations (denominators) and insert into the measure result detail...
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
					Gender, 
					IsDenominator, 
					IsExclusion,
					IsIndicator, 
					IsNumerator, 
					IsNumeratorAdmin, 
					IsNumeratorMedRcd, 
					KeyDate, 
					MeasureID, 
					MeasureXrefID, 
					MetricID, 
					MetricXrefID,
					PayerID, 
					PopulationID, 
					Qty, 
					ResultTypeID, 
					SourceDenominator,
					SourceDenominatorSrc)
			SELECT DISTINCT
					Member.GetAgeAsOf(TM.DOB, COALESCE(DATEADD(dd, t.AgeAsOfDays, DATEADD(mm, t.AgeAsOfMonths, @EndInitSeedDate)), TE.EndDate, TE.BeginDate)) AS Age,
					Member.GetAgeInMonths(TM.DOB, COALESCE(DATEADD(dd, t.AgeAsOfDays, DATEADD(mm, t.AgeAsOfMonths, @EndInitSeedDate)), TE.EndDate, TE.BeginDate)) AS AgeMonths,
					TE.BatchID, 
					TE.BeginDate, 
					ISNULL(PBP.BitProductLines & TE.BitProductLines /*Added 12/18/2013*/ & t.BitProductLines, 0) AS BitProductLines,
					@DataRunID AS DataRunID, 
					@DataSetID AS DataSetID,  
					MIN(TE.DataSourceID) AS DataSourceID,
					TE.DSEntityID,
					TE.DSMemberID, 
					MIN(DSProviderID) AS DSProviderID,
					TE.EndDate, 
					TE.EnrollGroupID, 
					TE.EntityID, 
					TM.Gender,
					1 AS IsDenominator, 
					0 AS IsExclusion, 
					0 AS IsIndicator, 
					0 AS IsNumerator, 
					0 AS IsNumeratorAdmin, 
					0 AS IsNumeratorMedRcd,
					ISNULL(TE.EndDate, TE.BeginDate) AS KeyDate,
					t.MeasureID, 
					t.MeasureXrefID, 
					t.MetricID, 
					t.MetricXrefID, 
					ISNULL(PEK.PayerID, 0 ) AS PayerID, 
					ISNULL(PEK.PopulationID, 0) AS PopulationID, 
					0 AS Qty, 
					1 AS ResultTypeID,
					TE.DSEntityID AS SourceDenominator,
					MIN(TE.DataSourceID) AS SourceDenominatorSrc
			FROM	Proxy.Entities AS TE
					INNER JOIN Proxy.Members AS TM
							ON TE.DSMemberID = TM.DSMemberID AND
								TE.BatchID = TM.BatchID AND
								TE.DataRunID = TM.DataRunID AND
								TE.DataSetID = TM.DataSetID
					INNER JOIN #MetricEligiblePopulationKey AS t
							ON TE.EntityID = t.EntityID
					LEFT OUTER JOIN Proxy.EnrollmentKey AS PEK
							ON TE.EnrollGroupID = PEK.EnrollGroupID
					LEFT OUTER JOIN #PayerBitProductLines AS PBP
							ON PEK.PayerID = PBP.PayerID
			WHERE	(
						(TE.EnrollGroupID IS NULL) OR 
						(
							(PEK.EnrollGroupID  IS NOT NULL) AND
							(PBP.PayerID IS NOT NULL) AND
							(PBP.BitProductLines & TE.BitProductLines /*Added 12/18/2013*/ & t.BitProductLines > 0) --Entire line added 12/18/2013, Copied from above...
						)
					)
			GROUP BY t.AgeAsOfDays, 
					t.AgeAsOfMonths, 
					TE.BatchID, 
					TE.BeginDate, 
					t.BitProductLines,
					TE.BitProductLines,
					PBP.BitProductLines, 
					TM.DOB, 
					TE.DSEntityID, 
					TE.DSMemberID,
					TE.EndDate, 
					TE.EnrollGroupID, 
					TE.EntityID, 
					TM.Gender,
					t.MeasureID, 
					t.MeasureXrefID, 
					t.MetricID, 
					t.MetricXrefID, 
					PEK.PayerID, 
					PEK.PopulationID
			ORDER BY MeasureID, MetricID, DSMemberID, KeyDate;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--2) Insert the counter populations (UOS-like) measures...
			IF OBJECT_ID('tempdb..#Counters') IS NOT NULL
				DROP TABLE #Counters;

			DECLARE @RequireBenefit bit;
			SET @RequireBenefit = 0;		--Is necessary for some UOS measures, but causes problems for others (ABX = 1, AMB/FSP/IAD/MPT = 0)

			--2a) Counter: Unique Dates
			SELECT	Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)) AS Age,
					MAX(Member.GetAgeInMonths(M.DOB, ISNULL(PE.EndDate, PE.BeginDate))) AS AgeMonths,
					MAX(ISNULL(MN.BitProductLines, 0)) AS BitProductLines,
					MIN(PE.DataSourceID) AS DataSourceID,
					SUM(PE.[Days]) AS [Days],
					MIN(PE.DSEntityID) AS DSEntityID,
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID, 
					MIN(M.Gender) AS Gender,
					METMM.MetricID,
					COUNT(DISTINCT ISNULL(PE.EndDate, PE.BeginDate)) AS Qty
			INTO	#Counters
			FROM	Proxy.Entities AS PE
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON PE.EntityID = METMM.EntityID 
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID AND
								MMT.MapTypeGuid = '8306A9E9-9349-448B-A9B3-68790C5892C7'
					INNER JOIN Proxy.Members AS M
							ON PE.DataSetID = M.DataSetID AND
								PE.DSMemberID = M.DSMemberID 
					LEFT OUTER JOIN Proxy.Enrollment AS MN
							ON M.DataSetID = MN.DataSetID AND
								M.DSMemberID = MN.DSMemberID AND
								ISNULL(PE.EndDate, PE.BeginDate) BETWEEN MN.BeginDate AND MN.EndDate
					LEFT OUTER JOIN Batch.EnrollmentBenefits AS PEB
							ON MN.EnrollItemID = PEB.EnrollItemID AND
								MX.BenefitID = PEB.BenefitID
			WHERE	(
						(MX.BenefitID IS NULL) OR
						(@RequireBenefit = 0) OR
						(PEB.EnrollItemID IS NOT NULL)
					)
			GROUP BY Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)), 
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID,
					METMM.MetricID;	
								
			--2b) Counter: Unique Dates/Providers
			INSERT INTO #Counters
					(Age,
					AgeMonths,
					BitProductLines,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					EnrollGroupID,
					EntityID,
					Gender,
					MetricID,
					Qty)		
			SELECT	Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)) AS Age,
					MAX(Member.GetAgeInMonths(M.DOB, ISNULL(PE.EndDate, PE.BeginDate))) AS AgeMonths,
					MAX(ISNULL(MN.BitProductLines, 0)) AS BitProductLines,
					MIN(PE.DataSourceID) AS DataSourceID,
					SUM(PE.[Days]) AS [Days],
					MIN(PE.DSEntityID) AS DSEntityID,
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID, 
					MIN(M.Gender),
					METMM.MetricID,
					COUNT(DISTINCT CONVERT(varchar(8), ISNULL(PE.EndDate, PE.BeginDate), 112) + CONVERT(char(16), DSProviderID)) AS Qty
			FROM	Proxy.Entities AS PE
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON PE.EntityID = METMM.EntityID 
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID AND
								MMT.MapTypeGuid = 'DB7AA151-A1C9-4E6D-BBB1-8AE960EB8BA9'
					INNER JOIN Proxy.Members AS M
							ON PE.DataSetID = M.DataSetID AND
								PE.DSMemberID = M.DSMemberID
					LEFT OUTER JOIN Proxy.Enrollment AS MN
							ON M.DataSetID = MN.DataSetID AND
								M.DSMemberID = MN.DSMemberID AND
								ISNULL(PE.EndDate, PE.BeginDate) BETWEEN MN.BeginDate AND MN.EndDate 
					LEFT OUTER JOIN Batch.EnrollmentBenefits AS PEB
							ON MN.EnrollItemID = PEB.EnrollItemID AND
								MX.BenefitID = PEB.BenefitID
			WHERE	(
						(MX.BenefitID IS NULL) OR
						(@RequireBenefit = 0) OR
						(PEB.EnrollItemID IS NOT NULL)
					)
			GROUP BY Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)), 
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID,
					METMM.MetricID;		
					
			--2c) Counter: Unique Entites (DSEntityIDs)
			INSERT INTO #Counters
					(Age,
					AgeMonths,
					BitProductLines,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					EnrollGroupID,
					EntityID,
					Gender,
					MetricID,
					Qty)		
			SELECT	Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)) AS Age,
					MAX(Member.GetAgeInMonths(M.DOB, ISNULL(PE.EndDate, PE.BeginDate))) AS AgeMonths,
					MAX(ISNULL(MN.BitProductLines, 0)) AS BitProductLines,
					MIN(PE.DataSourceID) AS DataSourceID,
					SUM(PE.[Days]) AS [Days],
					MIN(PE.DSEntityID) AS DSEntityID,
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID, 
					MIN(M.Gender),
					METMM.MetricID,
					COUNT(DISTINCT PE.DSEntityID) AS Qty
			FROM	Proxy.Entities AS PE
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON PE.EntityID = METMM.EntityID 
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID AND
								MMT.MapTypeGuid = '3BC16020-E437-4780-989A-26620FDA7A0C'
					INNER JOIN Proxy.Members AS M
							ON PE.DataSetID = M.DataSetID AND
								PE.DSMemberID = M.DSMemberID
					LEFT OUTER JOIN Proxy.Enrollment AS MN
							ON M.DataSetID = MN.DataSetID AND
								M.DSMemberID = MN.DSMemberID AND
								ISNULL(PE.EndDate, PE.BeginDate) BETWEEN MN.BeginDate AND MN.EndDate 
					LEFT OUTER JOIN Batch.EnrollmentBenefits AS PEB
							ON MN.EnrollItemID = PEB.EnrollItemID AND
								MX.BenefitID = PEB.BenefitID
			WHERE	(
						(MX.BenefitID IS NULL) OR
						(@RequireBenefit = 0) OR
						(PEB.EnrollItemID IS NOT NULL)
					)
			GROUP BY Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)), 
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID,
					METMM.MetricID;		
					
			--2d) Counter: Unique Dates/Sources
			INSERT INTO #Counters
					(Age,
					AgeMonths,
					BitProductLines,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					EnrollGroupID,
					EntityID,
					Gender,
					MetricID,
					Qty)		
			SELECT	Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)) AS Age,
					MAX(Member.GetAgeInMonths(M.DOB, ISNULL(PE.EndDate, PE.BeginDate))) AS AgeMonths,
					MAX(ISNULL(MN.BitProductLines, 0)) AS BitProductLines,
					MIN(PE.DataSourceID) AS DataSourceID,
					SUM(PE.[Days]) AS [Days],
					MIN(PE.DSEntityID) AS DSEntityID,
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID, 
					MIN(M.Gender),
					METMM.MetricID,
					COUNT(DISTINCT CONVERT(varchar(8), ISNULL(PE.EndDate, PE.BeginDate), 112) + 
									CONVERT(char(16), ISNULL(PE.SourceID, '')) + 
									CONVERT(char(16), ISNULL(PE.SourceLinkID, ''))
							) AS Qty
			FROM	Proxy.Entities AS PE
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON PE.EntityID = METMM.EntityID 
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID AND
								MMT.MapTypeGuid = '48B5FC85-0398-40B4-8BBB-4923760C12EB'
					INNER JOIN Proxy.Members AS M
							ON PE.DataSetID = M.DataSetID AND
								PE.DSMemberID = M.DSMemberID
					LEFT OUTER JOIN Proxy.Enrollment AS MN
							ON M.DataSetID = MN.DataSetID AND
								M.DSMemberID = MN.DSMemberID AND
								ISNULL(PE.EndDate, PE.BeginDate) BETWEEN MN.BeginDate AND MN.EndDate 
					LEFT OUTER JOIN Batch.EnrollmentBenefits AS PEB
							ON MN.EnrollItemID = PEB.EnrollItemID AND
								MX.BenefitID = PEB.BenefitID
			WHERE	(
						(MX.BenefitID IS NULL) OR
						(@RequireBenefit = 0) OR
						(PEB.EnrollItemID IS NOT NULL)
					)
			GROUP BY Member.GetAgeAsOf(M.DOB, ISNULL(PE.EndDate, PE.BeginDate)), 
					PE.DSMemberID, 
					MN.EnrollGroupID, 
					PE.EntityID,
					METMM.MetricID;		
					
			--2e) Insert the "counter" records into the measure results detail.
			SELECT	SUM(DISTINCT PPL.BitValue) AS BitProductLines,
					MMPL.MeasureID
			INTO	#MeasureProductLines
			FROM	Measure.MeasureProductLines AS MMPL
					INNER JOIN Product.ProductLines AS PPL
							ON MMPL.ProductLineID = PPL.ProductLineID
			GROUP BY MMPL.MeasureID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MeasureProductLines ON #MeasureProductLines (MeasureID);
				
			INSERT INTO Result.MeasureDetail
					(Age,
					AgeMonths,
					BatchID,
					BeginDate,
					BitProductLines,
					ClinCondID,
					DataRunID,
					DataSetID,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EnrollGroupID,
					EntityID,
					Gender,
					IsDenominator,
					IsExclusion,
					IsIndicator,
					IsNumerator,
					IsNumeratorAdmin,
					IsNumeratorMedRcd,
					KeyDate,
					MeasureID,
					MeasureXrefID,
					MetricID,
					MetricXrefID,
					PayerID,
					PopulationID,
					Qty,
					ResultTypeID,
					SourceDenominator,
					SourceExclusion,
					SourceIndicator,
					SourceNumerator,
					SysSampleRefID,
					[Weight])
			SELECT	C.Age,
					C.AgeMonths,
					@BatchID AS BatchID,
					@BeginInitSeedDate AS BeginDate,
					ISNULL(PBP.BitProductLines & C.BitProductLines & MMPL.BitProductLines, 0) AS BitProductLines,
					NULL AS ClinCondID,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					C.DataSourceID,
					ISNULL(C.[Days], 0) AS [Days],
					C.DSEntityID,
					C.DSMemberID,
					NULL AS DSProviderID,
					@EndInitSeedDate AS EndDate,
					ISNULL(C.EnrollGroupID, 0) AS EnrollGroupID,
					C.EntityID,
					C.Gender,
					NULL AS IsDenominator,
					NULL AS IsExclusion,
					NULL AS IsIndicator,
					NULL AS IsNumerator,
					NULL AS IsNumeratorAdmin,
					NULL AS IsNumeratorMedRcd,
					@EndInitSeedDate AS KeyDate,
					MX.MeasureID,
					MM.MeasureXrefID,
					C.MetricID,
					MX.MetricXrefID,
					ISNULL(PEK.PayerID, 0) AS PayerID,
					ISNULL(PEK.PopulationID, 0) AS PopulationID,
					CASE WHEN C.Qty > ME.MaxCount THEN ME.MaxCount ELSE C.Qty END AS Qty,
					4 AS ResultTypeID,
					NULL AS SourceDenominator,
					NULL AS SourceExclusion,
					NULL AS SourceIndicator,
					NULL AS SourceNumerator,
					NULL AS SysSampleRefID,
					NULL AS [Weight] 
			FROM	#Counters AS C
					INNER JOIN Measure.Entities AS ME
							ON C.EntityID = ME.EntityID
					INNER JOIN Measure.Metrics AS MX
							ON C.MetricID = MX.MetricID
					INNER JOIN Measure.Measures AS  MM
							ON MX.MeasureID = MM.MeasureID
					INNER JOIN #MeasureProductLines AS MMPL
							ON MX.MeasureID = MMPL.MeasureID
					LEFT OUTER JOIN Proxy.EnrollmentKey AS PEK
							ON C.EnrollGroupID = PEK.EnrollGroupID
					LEFT OUTER JOIN #PayerBitProductLines AS PBP
							ON PEK.PayerID = PBP.PayerID
			WHERE	(
						(PBP.BitProductLines & C.BitProductLines & MMPL.BitProductLines > 0) OR
						(C.EnrollGroupID IS NULL)                      
					) 
			ORDER BY MeasureID, MetricID, DSMemberID, KeyDate;

			--3) Calculate numerator compliance...
			--3a) Identify numerator-related entities 
			SELECT DISTINCT
					METMM.EntityID, MM.MeasureID, METMM.MetricID 
			INTO	#MetricNumeratorKey
			FROM	Measure.EntityToMetricMapping AS METMM
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID 
					INNER JOIN Measure.Metrics AS MC
							ON METMM.MetricID = MC.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MC.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
			WHERE	(MMT.MapTypeGuid = '376C404D-C8EF-4716-9296-909A0BE6ADD4');
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricNumeratorKey ON #MetricNumeratorKey (EntityID, MetricID, MeasureID);
			
			--3b) Find valid numerator entity records
			SELECT	COUNT(DISTINCT TE.DSEntityID) AS CountNumerator,
					MIN(TE.DataSourceID) AS DataSourceID,
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					t.MeasureID,
					t.MetricID,
					IDENTITY(bigint, 1, 1) AS RowID,
					MIN(TE.DSEntityID) AS SourceNumerator
			INTO	#Numerators
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricNumeratorKey AS t
							ON TE.EntityID = t.EntityID
			GROUP BY TE.SourceLinkID,
					TE.DSMemberID, 
					t.MeasureID,
					t.MetricID;
					
			DROP TABLE #MetricNumeratorKey;
				
			--3c) Loop through nested-entities to match numerator records to the appropriate denominator entity
			--Added 1/25/2012 to handle nested mappings--
			DECLARE @i int;
			DECLARE @MaxIteration int;
			
			SELECT	@MaxIteration = MAX(MER.Iteration) 
			FROM	Measure.EntityRelationships AS MER 
					INNER JOIN Proxy.EntityKey AS PEK 
							ON MER.EntityID = PEK.EntityID
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON MER.EntityID = METMM.EntityID AND
								PEK.EntityID = METMM.EntityID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID
			WHERE	(MMT.MapTypeGuid = '376C404D-C8EF-4716-9296-909A0BE6ADD4');
			
			WHILE 1 = 1
				BEGIN;
					SET @i = ISNULL(@i, 0) + 1;
				
					WITH EPEntityToMetricMapping AS
					(
						SELECT DISTINCT
								EntityID, MetricID
						FROM	Measure.EntityToMetricMapping AS METMM WITH(NOLOCK)
								INNER JOIN Measure.MappingTypes AS MMT WITH(NOLOCK)
										ON METMM.MapTypeID = MMT.MapTypeID AND
											MMT.MapTypeGuid = '1615D299-5BA1-4455-AE77-BE49646F54A4'
					)
					INSERT INTO #Numerators
							(CountNumerator,
							DataSourceID,
							DSEntityID,
							DSMemberID,
							MeasureID,
							MetricID,
							SourceNumerator)
					SELECT DISTINCT
							t.CountNumerator,
							TE.DataSourceID,
							TE.SourceLinkID AS DSEntityID,
							t.DSMemberID,
							t.MeasureID,
							t.MetricID,
							t.SourceNumerator
					FROM	#Numerators AS t
							INNER JOIN Proxy.Entities AS TE
									ON t.DSEntityID = TE.DSEntityID AND
										t.DSMemberID = TE.DSMemberID AND
										TE.BatchID = @BatchID AND
										TE.DataRunID = @DataRunID AND
										TE.DataSetID = @DataSetID AND
										(TE.SourceLinkID IS NULL OR
										TE.DSEntityID <> TE.SourceLinkID)
							LEFT OUTER JOIN EPEntityToMetricMapping AS EP
									ON TE.EntityID = EP.EntityID AND
										t.MetricID = EP.MetricID
							LEFT OUTER JOIN #Numerators AS x
									ON t.DSMemberID = x.DSMemberID AND
										(TE.SourceLinkID = x.DSEntityID OR (TE.SourceLinkID IS NULL AND x.DSEntityID IS NULL)) AND
										t.MetricID = x.MetricID  AND
										t.SourceNumerator = x.SourceNumerator
					WHERE	(EP.MetricID IS NULL) AND  --Stop matching at the metric's eligible population entity, added 12/5/2012
							(x.DSMemberID IS NULL) --Prevent Duplicates;
				
					IF @@ROWCOUNT = 0 OR @i >= ISNULL(@MaxIteration, 2) - 1
						BREAK;		
				END;
			-------------------------------------------------------------------------------------------
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Numerators ON #Numerators (RowID);				
			CREATE UNIQUE NONCLUSTERED INDEX IX_#Numerators2 ON #Numerators (DSMemberID, DSEntityID, MetricID, SourceNumerator);

			--3d) Update the measure result detail with numerator compliance 
			UPDATE RMD
			SET		IsNumerator = 1,
					IsNumeratorAdmin = 1,
					Qty = t.CountNumerator,
					SourceNumerator = t.SourceNumerator,
					SourceNumeratorSrc = t.DataSourceID
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Numerators AS t
							ON RMD.DSMemberID = t.DSMemberID AND
								(
									RMD.DSEntityID = t.DSEntityID OR
									t.DSEntityID IS NULL
								) AND
								RMD.MetricID = t.MetricID AND
								RMD.BatchID = @BatchID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--4) Calculate any secondary indicators...
			--4a) Identify indicator-related entities 
			SELECT DISTINCT
					METMM.EntityID, MM.MeasureID, METMM.MetricID 
			INTO	#MetricIndicatorKey
			FROM	Measure.EntityToMetricMapping AS METMM
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID 
					INNER JOIN Measure.Metrics AS MC
							ON METMM.MetricID = MC.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MC.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
			WHERE	(MMT.MapTypeGuid = '3B1CBDBC-8391-42B5-87BB-C4951ADC4024');
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricIndicatorKey ON #MetricIndicatorKey (EntityID, MetricID, MeasureID);
			
			--4b) Find valid indicator entity records
			SELECT DISTINCT
					TE.DataSourceID,          
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					t.MeasureID,
					t.MetricID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceIndicator
			INTO	#Indicators
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricIndicatorKey AS t
							ON TE.EntityID = t.EntityID;
				
			DROP TABLE #MetricIndicatorKey;
							
			CREATE UNIQUE CLUSTERED INDEX IX_#Indicators ON #Indicators (RowID);				
			CREATE UNIQUE NONCLUSTERED INDEX IX_#Indicators2 ON #Indicators (DSMemberID, DSEntityID, MetricID, SourceIndicator);
					
			--4c) Update the measure result detail with indicator settings					
			UPDATE RMD
			SET		IsIndicator = 1,
					SourceIndicator = t.SourceIndicator,
					SourceIndicatorSrc = t.DataSourceID
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Indicators AS t
							ON RMD.DSMemberID = t.DSMemberID AND
								(
									RMD.DSEntityID = t.DSEntityID OR
									t.DSEntityID IS NULL
								) AND
								RMD.MetricID = t.MetricID AND
								RMD.BatchID = @BatchID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			DROP TABLE #Indicators;

			--5) Calculate exclusions...
			--5a) Identify exclusion-related entities, as well as related metrics
			WITH MetricCount AS
			(
				SELECT  COUNT(DISTINCT CASE WHEN MX.IsInverse = 0 OR 1 = 1 /*Added based on CDC, HEDIS 2014*/ THEN MX.MetricID END) AS CountMetrics,
						MX.MeasureID
				FROM	Measure.Metrics AS MX
				GROUP BY MX.MeasureID
			),
			EntityExclusionKey AS
			(
				SELECT	METMM.EntityID, MIN(METMM.MetricID) AS MetricID
				FROM	Measure.EntityToMetricMapping AS METMM
						INNER JOIN Measure.MappingTypes AS MMT
								ON METMM.MapTypeID = MMT.MapTypeID 
						INNER JOIN Measure.Metrics AS MX
								ON METMM.MetricID = MX.MetricID
						INNER JOIN Measure.Measures AS MM
								ON MX.MeasureID = MM.MeasureID AND
									MM.MeasureSetID = @MeasureSetID
				WHERE	(MMT.MapTypeGuid IN ('C1961C8A-2EA7-4030-BE6A-9179A04D9D64', /*Added "Exclusion, All" due to CIS Test Deck, 12/4/2012*/'8C68B033-AE3D-4EC8-A25D-42BD8D3994B4'))
				GROUP BY METMM.EntityID
				HAVING	COUNT(DISTINCT METMM.MetricID) = 1				
			)
			SELECT	COUNT(DISTINCT CASE WHEN MX.IsInverse = 0 OR 1 = 1 /*Added based on CDC, HEDIS 2014*/ THEN MX.MetricID END) AS CountMetrics, METMM.EntityID, 
					CAST(MAX(CASE WHEN MMT.MapTypeGuid = '8C68B033-AE3D-4EC8-A25D-42BD8D3994B4' THEN 1 ELSE 0 END) AS bit) AS IsExcludeAll,
					K.MetricID AS KeyMetricID,
					MM.MeasureID
			INTO	#MetricExclusionKey
			FROM	Measure.EntityToMetricMapping AS METMM
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID 
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
					INNER JOIN MetricCount AS t
							ON MM.MeasureID = t.MeasureID
					LEFT OUTER JOIN EntityExclusionKey AS K
							ON METMM.EntityID = K.EntityID 
			WHERE	(MMT.MapTypeGuid IN ('C1961C8A-2EA7-4030-BE6A-9179A04D9D64', '8C68B033-AE3D-4EC8-A25D-42BD8D3994B4'))
			GROUP BY METMM.EntityID, K.MetricID, MM.MeasureID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricExclusionKey ON #MetricExclusionKey (EntityID, KeyMetricID, MeasureID);
			
			--5b) Find valid exclusion entity records
			SELECT DISTINCT
					t.CountMetrics,
					TE.DataSourceID,
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					t.EntityID,
					t.IsExcludeAll,
					t.KeyMetricID,
					t.MeasureID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceExclusion
			INTO	#Exclusions
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricExclusionKey AS t
							ON TE.EntityID = t.EntityID;
					
			DROP TABLE #MetricExclusionKey;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#Exclusions ON #Exclusions (RowID);
			CREATE UNIQUE NONCLUSTERED INDEX IX_#Exclusions2 ON #Exclusions (DSMemberID, DSEntityID, EntityID, MeasureID);
						
			--5c) Remove exclusion entities if the mapped metrics are all compliant	
			SELECT DISTINCT
					X.RowID 
			INTO	#RemoveExclusions
			FROM	#Exclusions AS X
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON X.EntityID = METMM.EntityID
					INNER JOIN #Numerators AS N
							ON X.DSMemberID = N.DSMemberID AND
								METMM.MetricID = N.MetricID AND
								X.MeasureID = N.MeasureID AND
								(
									(X.DSEntityID = N.DSEntityID) OR				
									(
										(N.DSEntityID IS NULL)
									)
								)
					INNER JOIN Measure.Metrics AS MX
							ON N.MeasureID = MX.MeasureID AND 
								N.MetricID = MX.MetricID
			GROUP BY X.CountMetrics, X.RowID
			HAVING	(COUNT(DISTINCT CASE WHEN MX.IsInverse = 0 OR 1 = 1 /*Added based on CDC, HEDIS 2014*/ THEN MX.MetricID END) = X.CountMetrics) OR 
					(MAX(CASE WHEN N.MetricID = X.KeyMetricID THEN 1 ELSE 0 END) = 1);
					
			DELETE FROM #Exclusions WHERE RowID IN (SELECT RowID FROM #RemoveExclusions);
					
			--5d) Update the measure result detail with the exclusions
			DECLARE @ExclusionTypeX tinyint;
			SELECT @ExclusionTypeX = ExclusionTypeID FROM Measure.ExclusionTypes WHERE Abbrev = 'X'; --General Exclusion
			
			UPDATE	RMD
			SET		ExclusionTypeID = @ExclusionTypeX,
					IsDenominator = 0,
					IsExclusion = 1,
					IsNumerator = 0,
					IsNumeratorAdmin = 0,
					SourceExclusion = t.SourceExclusion,
					SourceExclusionSrc = t.DataSourceID
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Exclusions AS t
							ON RMD.DSMemberID = t.DSMemberID AND
								(
									RMD.DSEntityID = t.DSEntityID OR
									t.DSEntityID IS NULL
								) AND
								RMD.MeasureID = t.MeasureID AND
								(t.KeyMetricID IS NULL OR t.IsExcludeAll = 1 OR RMD.MetricID = t.KeyMetricID) AND
								RMD.BatchID = @BatchID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			DROP TABLE #Numerators;
			DROP TABLE #Exclusions;
			
			--6) Identify any ineligible denominators...
			--6a) Identify ineligibility-related entities 
			SELECT DISTINCT
					METMM.EntityID, MM.MeasureID, METMM.MetricID 
			INTO	#MetricIneligibleKey
			FROM	Measure.EntityToMetricMapping AS METMM
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID 
					INNER JOIN Measure.Metrics AS MC
							ON METMM.MetricID = MC.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MC.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
			WHERE	(MMT.MapTypeGuid = '23EBD90F-65A5-4F3C-A0CE-1561F9353B90');
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MetricIneligibleKey ON #MetricIneligibleKey (EntityID, MetricID, MeasureID);
			
			--6b) Find valid ineligibility entity records
			SELECT DISTINCT
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					t.MeasureID,
					t.MetricID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceIndicator
			INTO	#Ineligible
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricIneligibleKey AS t
							ON TE.EntityID = t.EntityID;
							
			DROP TABLE #MetricIneligibleKey;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Ineligible ON #Ineligible (RowID);				
			CREATE UNIQUE NONCLUSTERED INDEX IX_#Ineligible2 ON #Ineligible (DSMemberID, DSEntityID, MetricID, SourceIndicator);
								
			--6c) Update the measure result detail by zeroing denominator, numerator, and exclusion fields.		
			UPDATE RMD
			SET		IsDenominator = 0,
					IsExclusion = 0,
					IsNumerator = 0,
					IsNumeratorAdmin = 0
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #Ineligible AS t
							ON RMD.DSMemberID = t.DSMemberID AND
								(
									RMD.DSEntityID = t.DSEntityID OR
									t.DSEntityID IS NULL
								) AND
								RMD.MetricID = t.MetricID AND
								RMD.BatchID = @BatchID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--7) Apply detail for "parent" metrics, including recursive parents (i.e. grandparents, great-grandparents, etc)...
			CREATE TABLE #PopulatedParents
			(
				MetricID int NOT NULL
			);
			
			
			WHILE (1 = 1)
				BEGIN;
					IF OBJECT_ID('tempdb..#MetricParents') IS NOT NULL
						DROP TABLE #MetricParents;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#PopulatedParents ON #PopulatedParents (MetricID);
					
					SELECT DISTINCT
							MX.MetricID, MX.ParentID
					INTO	#MetricParents
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN Measure.Metrics AS MX
									ON RMD.MetricID = MX.MetricID
					WHERE	(RMD.BatchID = @BatchID) AND
							(MX.MetricID NOT IN (SELECT MetricID FROM #PopulatedParents));
					
					CREATE UNIQUE CLUSTERED INDEX IX_#MetricParents ON #MetricParents (MetricID);
					DROP INDEX IX_#PopulatedParents ON #PopulatedParents;
					
					IF EXISTS (SELECT TOP 1 1 FROM #MetricParents)
						BEGIN;
							INSERT INTO Result.MeasureDetail
									(Age,
									AgeMonths,
									AgeBandID,
									AgeBandSegID,
									BatchID,
									BeginDate,
									BitProductLines,
									ClinCondID,
									DataRunID,
									DataSetID,
									DataSourceID,
									[Days],
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
									IsIndicator,
									IsNumerator,
									IsNumeratorAdmin,
									IsNumeratorMedRcd,
									KeyDate,
									MeasureID,
									MeasureXrefID,
									MetricID,
									MetricXrefID,
									PayerID,
									PopulationID,
									ProductLineID,
									Qty,
									ResultTypeID,
									SourceDenominator,
									SourceDenominatorSrc,
									SourceExclusion,
									SourceExclusionSrc,
									SourceIndicator,
									SourceIndicatorSrc,
									SourceNumerator,
									SourceNumeratorSrc,
									SysSampleRefID,
									[Weight])
							SELECT	RMD.Age,
									RMD.AgeMonths,
									RMD.AgeBandID,
									RMD.AgeBandSegID,
									RMD.BatchID,
									RMD.BeginDate,
									RMD.BitProductLines,
									RMD.ClinCondID,
									RMD.DataRunID,
									RMD.DataSetID,
									RMD.DataSourceID,
									RMD.[Days],
									RMD.DSEntityID,
									RMD.DSMemberID,
									RMD.DSProviderID,
									RMD.EndDate,
									RMD.EnrollGroupID,
									RMD.EntityID,
									RMD.ExclusionTypeID,
									RMD.Gender,
									RMD.IsDenominator,
									RMD.IsExclusion,
									RMD.IsIndicator,
									RMD.IsNumerator,
									RMD.IsNumeratorAdmin,
									RMD.IsNumeratorMedRcd,
									RMD.KeyDate,
									PX.MeasureID,
									PM.MeasureXrefID,
									PX.MetricID,
									PX.MetricXrefID,
									RMD.PayerID,
									RMD.PopulationID,
									RMD.ProductLineID,
									RMD.Qty,
									RMD.ResultTypeID,
									RMD.SourceDenominator,
									RMD.SourceDenominatorSrc,
									RMD.SourceExclusion,
									RMD.SourceExclusionSrc,
									RMD.SourceIndicator,
									RMD.SourceIndicatorSrc,
									RMD.SourceNumerator,
									RMD.SourceNumeratorSrc,
									RMD.SysSampleRefID,
									RMD.[Weight]
							FROM	Result.MeasureDetail AS RMD
									INNER JOIN #MetricParents AS MX
											ON RMD.MetricID = MX.MetricID
									INNER JOIN Measure.Metrics AS PX
											ON MX.ParentID = PX.MetricID
									INNER JOIN Measure.Measures AS PM
											ON PX.MeasureID = PM.MeasureID
							WHERE	(RMD.BatchID = @BatchID);	
							
							SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
							
							INSERT INTO #PopulatedParents
							        (MetricID)
							SELECT DISTINCT MetricID FROM #MetricParents;
						END;
					ELSE
						BREAK;
				END;
			
			SET @LogDescr = ' - Calculating detailed measure results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@EntryXrefGuid = @LogEntryXrefGuid, 
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;

			--COMMIT TRANSACTION T1;

			RETURN 0;
		END TRY
		BEGIN CATCH;
			IF @@TRANCOUNT > 0
				ROLLBACK;
				
			DECLARE @ErrorLine int;
			DECLARE @ErrorLogID int;
			DECLARE @ErrorMessage nvarchar(max);
			DECLARE @ErrorNumber int;
			DECLARE @ErrorSeverity int;
			DECLARE @ErrorSource nvarchar(512);
			DECLARE @ErrorState int;
			
			DECLARE @ErrorResult int;
			
			SELECT	@ErrorLine = ERROR_LINE(),
					@ErrorMessage = ERROR_MESSAGE(),
					@ErrorNumber = ERROR_NUMBER(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorSource = ERROR_PROCEDURE(),
					@ErrorState = ERROR_STATE();
					
			EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
													@Message = @ErrorMessage,
													@ErrorNumber = @ErrorNumber,
													@ErrorType = 'Q',
													@ErrLogID = @ErrorLogID OUTPUT,
													@Severity = @ErrorSeverity,
													@Source = @ErrorSource,
													@State = @ErrorState,
													@PerformRollback = 0;
			
			
			SET @LogEndTime = GETDATE();
			SET @LogDescr = ' - Calculating detailed measure results for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
												@EntryXrefGuid = @LogEntryXrefGuid, 
												@ErrLogID = @ErrorLogID,
												@IsSuccess = 0,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;
														
			SET @ErrorMessage = REPLACE(@LogDescr, '!', ': ') + @ErrorMessage + ' (Error: ' + CAST(@ErrorNumber AS nvarchar) + ')';
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
		END CATCH;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(MAX);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END





GO
GRANT EXECUTE ON  [Batch].[CalculateMeasureDetail_v2] TO [Processor]
GO
