SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/22/2011
-- Description:	Calculates the detailed measure results.
-- =============================================
CREATE PROCEDURE [Batch].[CalculateMeasureDetail]
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
	DECLARE @CalculateXml bit;
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
					@CalculateXml = DR.CalculateXml,
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
			
			--1c) Create a temp table version of Result.MeasureDetail...
			CREATE TABLE #Result_MeasureDetail
			(
				[Age] [tinyint] NULL,
				[AgeMonths] [smallint] NULL,
				[AgeBandID] [int] NULL,
				[AgeBandSegID] [int] NULL,
				[BatchID] [int] NOT NULL,
				[BeginDate] [datetime] NULL,
				[BitProductLines] [bigint] NOT NULL DEFAULT ((0)),
				[ClinCondID] [int] NULL,
				[DataRunID] [int] NOT NULL,
				[DataSetID] [int] NOT NULL,
				[DataSourceID] [int] NOT NULL DEFAULT ((-1)),
				[Days] [smallint] NULL,
				[DSEntityID] [bigint] NULL,
				[DSMemberID] [bigint] NOT NULL,
				[DSProviderID] [bigint] NULL,
				[EndDate] [datetime] NULL,
				[EnrollGroupID] [int] NULL,
				[EntityID] [int] NULL,
				[ExclusionTypeID] [tinyint] NULL,
				[Gender] [tinyint] NULL,
				[IsDenominator] [bit] NULL,
				[IsExclusion] [bit] NULL,
				[IsIndicator] [bit] NULL,
				[IsNumerator] [bit] NULL,
				[IsNumeratorAdmin] [bit] NULL,
				[IsNumeratorMedRcd] [bit] NULL,
				[IsSupplementalDenominator] [bit] NULL,
				[IsSupplementalExclusion] [bit] NULL,
				[IsSupplementalIndicator] [bit] NULL,
				[IsSupplementalNumerator] [bit] NULL,
				[KeyDate] [datetime] NOT NULL,
				[MeasureID] [int] NOT NULL,
				[MeasureXrefID] [int] NULL,
				[MetricID] [int] NOT NULL,
				[MetricXrefID] [int] NULL,
				[PayerID] [smallint] NOT NULL,
				[PopulationID] [int] NOT NULL,
				[ProductLineID] [smallint] NOT NULL DEFAULT ((0)),
				[Qty] [int] NULL,
				[ResultInfo] [xml] NULL,
				[ResultRowGuid] [uniqueidentifier] NOT NULL DEFAULT (NEWID()),
				[ResultRowID] [bigint] IDENTITY(1,1) NOT NULL,
				[ResultTypeID] [tinyint] NOT NULL,
				[SourceDenominator] [bigint] NULL,
				[SourceDenominatorSrc] [int] NULL,
				[SourceExclusion] [bigint] NULL,
				[SourceExclusionSrc] [int] NULL,
				[SourceIndicator] [bigint] NULL,
				[SourceIndicatorSrc] [int] NULL,
				[SourceNumerator] [bigint] NULL,
				[SourceNumeratorSrc] [int] NULL,
				[SysSampleRefID] [bigint] NULL,
				[Weight] [decimal](18, 10) NULL,
				PRIMARY KEY CLUSTERED ([ResultRowID] ASC)
			);
			
			--1d) Compile eligible populations (denominators) and insert into the (temp) measure result detail...
			INSERT INTO #Result_MeasureDetail
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
					IsSupplementalDenominator,
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
					ISNULL(PBP.BitProductLines & TE.BitProductLines & t.BitProductLines, 0) AS BitProductLines,
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
					CONVERT(bit, MIN(CONVERT(tinyint, TE.IsSupplemental))) AS IsSupplementalDenominator,
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
							(PBP.BitProductLines & TE.BitProductLines & t.BitProductLines > 0) 
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

			IF @CalculateXml = 1
				UPDATE	t
				SET		ResultInfo =	(
											SELECT	t.ResultRowGuid AS id, 
													MX.Abbrev AS metric, 
													t.MetricID AS metricID, 
													(
														SELECT PE.EntityInfo AS [denominator] FOR XML PATH(''), TYPE
													) 
											FOR XML RAW('result')
										)
				FROM	#Result_MeasureDetail AS t
						LEFT OUTER JOIN Measure.Metrics AS MX
								ON MX.MetricID = t.MetricID
						INNER JOIN Proxy.Entities AS PE
								ON PE.DSEntityID = t.DSEntityID AND
									PE.BatchID = t.BatchID AND
									PE.DataRunID = t.DataRunID AND
									PE.DataSetID = t.DataSetID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			CREATE NONCLUSTERED INDEX IX_#Result_MeasureDetail ON #Result_MeasureDetail (DSMemberID, MetricID, DSEntityID) INCLUDE (BatchID, IsDenominator, MeasureID);

			--2) Identify any ineligible denominators...
			--2a) Identify ineligibility-related entities 
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
			
			--2b) Find valid ineligibility entity records
			SELECT DISTINCT
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					TE.IsSupplemental,
					t.MeasureID,
					t.MetricID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceIneligible
			INTO	#Ineligible
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricIneligibleKey AS t
							ON TE.EntityID = t.EntityID;

			ALTER TABLE #Ineligible ADD ResultInfo xml NULL;

			DROP TABLE #MetricIneligibleKey;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Ineligible ON #Ineligible (RowID);				
			CREATE NONCLUSTERED INDEX IX_#Ineligible2 ON #Ineligible (DSMemberID, MetricID, DSEntityID) INCLUDE (MeasureID,  SourceIneligible);
				
			IF @CalculateXml = 1						
				UPDATE	t
				SET		ResultInfo = (SELECT PE.EntityInfo AS [ineligible] FOR XML PATH(''), TYPE)
				FROM	#Ineligible AS t
						INNER JOIN Proxy.Entities AS PE
								ON PE.DSEntityID = t.SourceIneligible AND
									PE.DSMemberID = t.DSMemberID
				WHERE	(PE.BatchID = @BatchID);

			--2c) Update the measure result detail by zeroing denominator, numerator, and exclusion fields.	
			IF @CalculateXml = 1 --(1 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)
				UPDATE RMD
				SET		IsDenominator = 0,
						IsExclusion = 0,
						IsNumerator = 0,
						IsNumeratorAdmin = 0,
						ResultInfo.modify('insert sql:column("t.ResultInfo") as last into (/result[1])')
				FROM	#Result_MeasureDetail AS RMD
						INNER JOIN #Ineligible AS t
								ON RMD.DSMemberID = t.DSMemberID AND
									(
										RMD.DSEntityID = t.DSEntityID OR
										t.DSEntityID IS NULL
									) AND
									RMD.MetricID = t.MetricID AND
									RMD.BatchID = @BatchID;
			ELSE --(2 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)
				UPDATE RMD
				SET		IsDenominator = 0,
						IsExclusion = 0,
						IsNumerator = 0,
						IsNumeratorAdmin = 0
				FROM	#Result_MeasureDetail AS RMD
						INNER JOIN #Ineligible AS t
								ON RMD.DSMemberID = t.DSMemberID AND
									(
										RMD.DSEntityID = t.DSEntityID OR
										t.DSEntityID IS NULL
									) AND
									RMD.MetricID = t.MetricID AND
									RMD.BatchID = @BatchID;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

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
					CONVERT(bit, NULL) AS IsSupplemental,
					t.MeasureID,
					t.MetricID,
					CONVERT(xml, NULL) AS ResultInfo,
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
			CREATE NONCLUSTERED INDEX IX_#Numerators2 ON #Numerators (DSMemberID, MetricID, DSEntityID) INCLUDE (DataSourceID, MeasureID, SourceNumerator);

			IF @CalculateXml = 1						
				UPDATE	t
				SET		ResultInfo = (SELECT PE.EntityInfo AS [numerator] FOR XML PATH(''), TYPE)
				FROM	#Numerators AS t
						INNER JOIN Proxy.Entities AS PE
								ON PE.DSEntityID = t.SourceNumerator AND
									PE.DSMemberID = t.DSMemberID
				WHERE	(PE.BatchID = @BatchID);

			UPDATE	t
			SET		IsSupplemental = PE.IsSupplemental
			FROM	#Numerators AS t
					INNER JOIN Proxy.Entities AS PE
							ON PE.DSEntityID = t.SourceNumerator
			WHERE	(t.IsSupplemental IS NULL);

			--3d) Update the measure result detail with numerator compliance 
			IF @CalculateXml = 1 --(1 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)
				UPDATE RMD
				SET		IsNumerator = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsNumerator END,
						IsNumeratorAdmin = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsNumeratorAdmin END,
						RMD.IsSupplementalNumerator = t.IsSupplemental,
						Qty = CASE WHEN RMD.IsDenominator = 1 THEN t.CountNumerator ELSE RMD.Qty END,
						SourceNumerator = t.SourceNumerator,
						SourceNumeratorSrc = t.DataSourceID,
						ResultInfo.modify('insert sql:column("t.ResultInfo") as last into (/result[1])')
				FROM	#Result_MeasureDetail AS RMD
						INNER JOIN #Numerators AS t
								ON RMD.DSMemberID = t.DSMemberID AND
									(
										RMD.DSEntityID = t.DSEntityID OR
										t.DSEntityID IS NULL
									) AND
									RMD.MetricID = t.MetricID AND
									RMD.BatchID = @BatchID;
			ELSE --(2 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)
				UPDATE RMD
				SET		IsNumerator = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsNumerator END,
						IsNumeratorAdmin = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsNumeratorAdmin END,
						RMD.IsSupplementalNumerator = t.IsSupplemental,
						Qty = CASE WHEN RMD.IsDenominator = 1 THEN t.CountNumerator ELSE RMD.Qty END,
						SourceNumerator = t.SourceNumerator,
						SourceNumeratorSrc = t.DataSourceID
				FROM	#Result_MeasureDetail AS RMD
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
					TE.IsSupplemental,
					t.MetricID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceIndicator
			INTO	#Indicators
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricIndicatorKey AS t
							ON TE.EntityID = t.EntityID;
				
			ALTER TABLE #Indicators ADD ResultInfo xml NULL;

			DROP TABLE #MetricIndicatorKey;
							
			CREATE UNIQUE CLUSTERED INDEX IX_#Indicators ON #Indicators (RowID);				
			CREATE NONCLUSTERED INDEX IX_#Indicators2 ON #Indicators (DSMemberID, MetricID, DSEntityID) INCLUDE (DataSourceID, MeasureID, SourceIndicator);
					
			IF @CalculateXml = 1						
				UPDATE	t
				SET		ResultInfo = (SELECT PE.EntityInfo AS [indicator] FOR XML PATH(''), TYPE)
				FROM	#Indicators AS t
						INNER JOIN Proxy.Entities AS PE
								ON PE.DSEntityID = t.SourceIndicator AND
									PE.DSMemberID = t.DSMemberID
				WHERE	(PE.BatchID = @BatchID);

			--4c) Update the measure result detail with indicator settings	
			IF @CalculateXml = 1 --(1 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)				
				UPDATE RMD
				SET		IsIndicator = 1,
						IsSupplementalIndicator = t.IsSupplemental,
						SourceIndicator = t.SourceIndicator,
						SourceIndicatorSrc = t.DataSourceID,
						ResultInfo.modify('insert sql:column("t.ResultInfo") as last into (/result[1])')
				FROM	#Result_MeasureDetail AS RMD
						INNER JOIN #Indicators AS t
								ON RMD.DSMemberID = t.DSMemberID AND
									(
										RMD.DSEntityID = t.DSEntityID OR
										t.DSEntityID IS NULL
									) AND
									RMD.MetricID = t.MetricID AND
									RMD.BatchID = @BatchID;
			ELSE --(2 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)		
				UPDATE RMD
				SET		IsIndicator = 1,
						IsSupplementalIndicator = t.IsSupplemental,
						SourceIndicator = t.SourceIndicator,
						SourceIndicatorSrc = t.DataSourceID
				FROM	#Result_MeasureDetail AS RMD
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
			SELECT	COUNT(DISTINCT CASE WHEN MX.IsInverse = 0 OR 1 = 1 /*Added based on CDC, HEDIS 2014*/ THEN MX.MetricID END) AS CountMetrics, 
					METMM.EntityID, 
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
					CONVERT(bigint, NULL) AS CountNumerator,
					TE.DataSourceID,
					TE.SourceLinkID AS DSEntityID,
					TE.DSMemberID, 
					t.EntityID,
					t.IsExcludeAll,
					TE.IsSupplemental,
					t.KeyMetricID,
					t.MeasureID,
					IDENTITY(bigint, 1, 1) AS RowID,
					TE.DSEntityID AS SourceExclusion
			INTO	#Exclusions
			FROM	Proxy.Entities AS TE
					INNER JOIN #MetricExclusionKey AS t
							ON TE.EntityID = t.EntityID;
			
			ALTER TABLE #Exclusions ADD ResultInfo xml NULL;

			DROP TABLE #MetricExclusionKey;

			CREATE UNIQUE CLUSTERED INDEX IX_#Exclusions ON #Exclusions (RowID);
			--CREATE UNIQUE NONCLUSTERED INDEX IX_#Exclusions2 ON #Exclusions (DSMemberID, DSEntityID, EntityID, MeasureID);
			CREATE NONCLUSTERED INDEX IX_#Exclusions2 ON #Exclusions (DSMemberID, KeyMetricID, DSEntityID) INCLUDE (DataSourceID, IsExcludeAll, MeasureID);

			--5c) Identify fully-compliants for actual metrics counts of denominator records...
			--Added 12/1/2014 as part of CDC requirements for Marketplace reporting...
			IF OBJECT_ID('tempdb..#ExclusionMetricCounts') IS NOT NULL
				DROP TABLE #ExclusionMetricCounts;

			SELECT DISTINCT
					t.RowID
			INTO	#ExclusionMetricCounts
			FROM	#Result_MeasureDetail AS RMD
					INNER JOIN #Exclusions AS t
							ON RMD.DSMemberID = t.DSMemberID AND
								(
									RMD.DSEntityID = t.DSEntityID OR
									t.DSEntityID IS NULL
								) AND
								RMD.MeasureID = t.MeasureID AND
								(t.KeyMetricID IS NULL OR t.IsExcludeAll = 1 OR RMD.MetricID = t.KeyMetricID) AND
								RMD.BatchID = @BatchID
			GROUP BY t.RowID
			HAVING (COUNT(DISTINCT CASE WHEN RMD.IsDenominator = 1 THEN RMD.MetricID END) <= COUNT(DISTINCT CASE WHEN RMD.IsDenominator = 1 AND RMD.IsNumerator = 1 THEN RMD.MetricID END));
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ExclusionMetricCounts ON #ExclusionMetricCounts (RowID);
					
			--5d) Remove exclusion entities if the mapped metrics are all compliant	
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
					(MAX(CASE WHEN N.MetricID = X.KeyMetricID THEN 1 ELSE 0 END) = 1)
			UNION --Added 12/1/2014 as part of CDC requirements for Marketplace reporting...
			SELECT DISTINCT
					X.RowID
			FROM	#Exclusions AS X
					INNER JOIN #ExclusionMetricCounts AS t
							ON t.RowID = X.RowID;
					
			DELETE FROM #Exclusions WHERE RowID IN (SELECT RowID FROM #RemoveExclusions);
					
			IF @CalculateXml = 1						
				UPDATE	t
				SET		ResultInfo = (SELECT PE.EntityInfo AS [exclusion] FOR XML PATH(''), TYPE)
				FROM	#Exclusions AS t
						INNER JOIN Proxy.Entities AS PE
								ON PE.DSEntityID = t.SourceExclusion AND
									PE.DSMemberID = t.DSMemberID
				WHERE	(PE.BatchID = @BatchID);

			--5e) Update the measure result detail with the exclusions
			DECLARE @ExclusionTypeX tinyint;
			SELECT @ExclusionTypeX = ExclusionTypeID FROM Measure.ExclusionTypes WHERE Abbrev = 'X'; --General Exclusion
			
			IF @CalculateXml = 1 --(1 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)		
				UPDATE	RMD
				SET		ExclusionTypeID = @ExclusionTypeX,
						IsDenominator = 0,
						IsExclusion = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsExclusion END, 
						IsNumerator = CASE WHEN RMD.IsDenominator = 1 THEN 0 ELSE RMD.IsNumerator END,
						IsNumeratorAdmin = CASE WHEN RMD.IsDenominator = 1 THEN 0 ELSE RMD.IsNumeratorAdmin END,
						IsSupplementalExclusion = t.IsSupplemental,
						SourceExclusion = t.SourceExclusion,
						SourceExclusionSrc = t.DataSourceID,
						ResultInfo.modify('insert sql:column("t.ResultInfo") as last into (/result[1])')
				FROM	#Result_MeasureDetail AS RMD
						INNER JOIN #Exclusions AS t
								ON RMD.DSMemberID = t.DSMemberID AND
									(
										RMD.DSEntityID = t.DSEntityID OR
										t.DSEntityID IS NULL
									) AND
									RMD.MeasureID = t.MeasureID AND
									(t.KeyMetricID IS NULL OR t.IsExcludeAll = 1 OR RMD.MetricID = t.KeyMetricID) AND
									RMD.BatchID = @BatchID;
			ELSE --(2 of 2.  Due to the requirements of .modify(), two different versions of the UPDATE are required based on whether XML is on/off...)		
				UPDATE	RMD
				SET		ExclusionTypeID = @ExclusionTypeX,
						IsDenominator = 0,
						IsExclusion = CASE WHEN RMD.IsDenominator = 1 THEN 1 ELSE RMD.IsExclusion END, 
						IsNumerator = CASE WHEN RMD.IsDenominator = 1 THEN 0 ELSE RMD.IsNumerator END,
						IsNumeratorAdmin = CASE WHEN RMD.IsDenominator = 1 THEN 0 ELSE RMD.IsNumeratorAdmin END,
						IsSupplementalExclusion = t.IsSupplemental,
						SourceExclusion = t.SourceExclusion,
						SourceExclusionSrc = t.DataSourceID
				FROM	#Result_MeasureDetail AS RMD
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

			--6) Insert temp MeasureDetail into real MeasureDetail...
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
					IsSupplementalDenominator,
					IsSupplementalExclusion,
					IsSupplementalIndicator,
					IsSupplementalNumerator,
			        KeyDate,
			        MeasureID,
			        MeasureXrefID,
			        MetricID,
			        MetricXrefID,
			        PayerID,
			        PopulationID,
			        ProductLineID,
			        Qty,
					ResultInfo,
			        ResultRowGuid,
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
			SELECT	Age,
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
					IsSupplementalDenominator,
					IsSupplementalExclusion,
					IsSupplementalIndicator,
					IsSupplementalNumerator,
			        KeyDate,
			        MeasureID,
			        MeasureXrefID,
			        MetricID,
			        MetricXrefID,
			        PayerID,
			        PopulationID,
			        ProductLineID,
			        Qty,
					ResultInfo,
			        ResultRowGuid,
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
			        [Weight]
			FROM	#Result_MeasureDetail
			ORDER BY ResultRowID;
									
			--7) Insert the counter populations (UOS-like) measures...
			IF OBJECT_ID('tempdb..#Counters') IS NOT NULL
				DROP TABLE #Counters;

			DECLARE @RequireBenefit bit;
			SET @RequireBenefit = 0;		--Is necessary for some UOS measures, but causes problems for others (ABX = 1, AMB/FSP/IAD/MPT = 0)

			--7a) Counter: Unique Dates
			WITH Proxy_Entities AS
			(
				SELECT *, (SELECT PE.EntityInfo AS [counter] FOR XML PATH(''), TYPE) AS ResultInfo FROM Proxy.Entities AS PE
			)
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
					COUNT(DISTINCT ISNULL(PE.EndDate, PE.BeginDate)) AS Qty,
					CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(PE.ResultInfo, 1) END AS ResultInfo
			INTO	#Counters
			FROM	Proxy_Entities AS PE
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
								
			--7b) Counter: Unique Dates/Providers
			WITH Proxy_Entities AS
			(
				SELECT *, (SELECT PE.EntityInfo AS [counter] FOR XML PATH(''), TYPE) AS ResultInfo FROM Proxy.Entities AS PE
			)
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
					Qty,
					ResultInfo)		
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
					COUNT(DISTINCT CONVERT(varchar(8), ISNULL(PE.EndDate, PE.BeginDate), 112) + CONVERT(char(16), DSProviderID)) AS Qty,
					CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(PE.ResultInfo, 1) END AS ResultInfo
			FROM	Proxy_Entities AS PE
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
					
			--7c) Counter: Unique Entites (DSEntityIDs)
			WITH Proxy_Entities AS
			(
				SELECT *, (SELECT PE.EntityInfo AS [counter] FOR XML PATH(''), TYPE) AS ResultInfo FROM Proxy.Entities AS PE
			)
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
					Qty,
					ResultInfo)		
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
					COUNT(DISTINCT PE.DSEntityID) AS Qty,
					CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(PE.ResultInfo, 1) END AS ResultInfo
			FROM	Proxy_Entities AS PE
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
					
			--7d) Counter: Unique Dates/Sources
			WITH Proxy_Entities AS
			(
				SELECT *, (SELECT PE.EntityInfo AS [counter] FOR XML PATH(''), TYPE) AS ResultInfo FROM Proxy.Entities AS PE
			)
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
					Qty,
					ResultInfo)		
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
							) AS Qty,
					CASE WHEN @CalculateXml = 1 THEN dbo.CombineXml(PE.ResultInfo, 1) END AS ResultInfo
			FROM	Proxy_Entities AS PE
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
					
			--7e) Insert the "counter" records into the measure results detail.
			SELECT	SUM(DISTINCT PPL.BitValue) AS BitProductLines,
					MMPL.MeasureID
			INTO	#MeasureProductLines
			FROM	Measure.MeasureProductLines AS MMPL
					INNER JOIN Product.ProductLines AS PPL
							ON MMPL.ProductLineID = PPL.ProductLineID
			GROUP BY MMPL.MeasureID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#MeasureProductLines ON #MeasureProductLines (MeasureID);
				
			ALTER TABLE #Counters ADD ResultRowGuid uniqueidentifier NOT NULL DEFAULT (NEWID());

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
					ResultInfo,
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
					CASE WHEN @CalculateXml = 1 THEN
					(
							SELECT	C.ResultRowGuid AS id, 
									MX.Abbrev AS metric, 
									MX.MetricID AS metricID, 
									C.ResultInfo
							FOR XML RAW('result')
					) END AS ResultInfo,
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
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--8) Apply detail for "parent" metrics, including recursive parents (i.e. grandparents, great-grandparents, etc)...
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
									IsSupplementalDenominator,
									IsSupplementalExclusion,
									IsSupplementalIndicator,
									IsSupplementalNumerator,
									KeyDate,
									MeasureID,
									MeasureXrefID,
									MetricID,
									MetricXrefID,
									PayerID,
									PopulationID,
									ProductLineID,
									Qty,
									ResultInfo,
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
									RMD.IsSupplementalDenominator,
									RMD.IsSupplementalExclusion,
									RMD.IsSupplementalIndicator,
									RMD.IsSupplementalNumerator,
									RMD.KeyDate,
									PX.MeasureID,
									PM.MeasureXrefID,
									PX.MetricID,
									PX.MetricXrefID,
									RMD.PayerID,
									RMD.PopulationID,
									RMD.ProductLineID,
									RMD.Qty,
									RMD.ResultInfo,
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
		DECLARE @ErrMessage nvarchar(max);
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
GRANT VIEW DEFINITION ON  [Batch].[CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CalculateMeasureDetail] TO [Processor]
GO
