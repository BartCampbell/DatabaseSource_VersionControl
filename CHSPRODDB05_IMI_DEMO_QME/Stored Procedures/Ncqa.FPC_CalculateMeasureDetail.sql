SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/22/2012
-- Description:	Calculates the detailed results of the FPC measure.
-- =============================================
CREATE PROCEDURE [Ncqa].[FPC_CalculateMeasureDetail]
(
	@BatchID int = NULL,
	@CountRecords bigint = NULL OUTPUT
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

	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @MeasureYear smallint;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;

	BEGIN TRY;
			
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@CalculateXml = DR.CalculateXml,
				@DataRunID = DR.DataRunID,
				@DataSetID = DS.DataSetID,
				@EndInitSeedDate = DR.EndInitSeedDate,
				@IsLogged = DR.IsLogged,
				@MeasureSetID = DR.MeasureSetID,
				@MeasureYear = YEAR(MMS.DefaultSeedDate),
				@OwnerID = DS.OwnerID,
				@SeedDate = DR.SeedDate
		FROM	Batch.[Batches] AS B 
				INNER JOIN Batch.DataRuns AS DR
						ON B.DataRunID = DR.DataRunID
				INNER JOIN Batch.DataSets AS DS 
						ON B.DataSetID = DS.DataSetID 
				INNER JOIN Measure.MeasureSets AS MMS
						ON MMS.MeasureSetID = DR.MeasureSetID
		WHERE	(B.BatchID = @BatchID);
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'FPC_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
		
			DECLARE @FPCMetricID int;
			SELECT	@FPCMetricID = MetricID 
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
			WHERE	(MM.Abbrev = 'FPC') AND
					(MX.Abbrev = 'FPC');
			
			--SET THE DEFAULT GESTATIONAL AGE (IN DAYS) FOR THOSE WITHOUT AN AGE
			UPDATE	RMD
			SET		[Days] = 280
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND		
					(RMD.DataSetID = @DataSetID) AND
					(RMD.[Days] IS NULL) AND
					(RMD.MetricID = @FPCMetricID);
			
			IF OBJECT_ID('tempdb..#FPCBase') IS NOT NULL 
				DROP TABLE #FPCBase;
			
			SELECT	RMD.BatchID,
					RMD.Qty AS CountActual,
					CONVERT(int, NULL) AS CountExpected,
					RMD.DataRunID,
					RMD.DataSetID,
					RMD.DSMemberID,
					DATEDIFF(dd, DATEADD(dd, (RMD.[Days] * -1), RMD.KeyDate), PE.LastSegBeginDate) AS EnrollDays,
					ROUND(CONVERT(decimal(18,6), DATEDIFF(dd, DATEADD(dd, (RMD.[Days] * -1), RMD.KeyDate), PE.LastSegBeginDate)) / 30, 0) AS EnrollMonths,
					RMD.[Days] AS GestDays,
					DATEADD(dd, (RMD.[Days] * -1), RMD.KeyDate) AS GestStartDate,
					FLOOR(CONVERT(decimal(18,6), RMD.[Days]) / 7) AS [GestWeeks],
					RMD.KeyDate,
					PE.LastSegBeginDate,
					PE.LastSegEndDate,
					RMD.ResultInfo,
					RMD.ResultTypeID,
					RMD.ResultRowGuid AS SourceRowGuid,
					RMD.ResultRowID AS SourceRowID
			INTO	#FPCBase
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Proxy.Entities AS PE
							ON RMD.SourceDenominator = PE.DSEntityID AND
								RMD.BatchID = PE.BatchID AND
								RMD.DataRunID = PE.DataRunID AND
								RMD.DataSetID = PE.DataSetID
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND		
					(RMD.DataSetID = @DataSetID) AND
					(RMD.MetricID = @FPCMetricID);
					
			--Added 12/3/2015 per certification.  NCQA made counting of multiple "services" more complicated, due to the Cert Team's interpretation of not double counting "services".
			IF @MeasureYear >= 2015
				BEGIN;
					DECLARE @MappingTypeComponent tinyint;
					SELECT @MappingTypeComponent = MapTypeID FROM Measure.MappingTypes WHERE MapTypeGuid = '94e8a1c2-cdea-4ba8-a00b-1aef4835d40b';  --Component

					IF OBJECT_ID('tempdb..#FPCComponents') IS NOT NULL
						DROP TABLE #FPCComponents;

					SELECT	ME.Descr, ME.EntityID
					INTO	#FPCComponents
					FROM	Measure.EntityToMetricMapping AS METMM
							INNER JOIN Measure.Entities AS ME
									ON ME.EntityID = METMM.EntityID
					WHERE	METMM.MetricID = @FPCMetricID AND
							METMM.MapTypeID = @MappingTypeComponent;

					CREATE UNIQUE CLUSTERED INDEX IX_#FPCComponents ON #FPCComponents(EntityID);

					IF OBJECT_ID('tempdb..#FPCComponentEntities') IS NOT NULL
						DROP TABLE #FPCComponentEntities;

					/*
					Stand-Alone Prenatal Visits
					Prenatal Visits
					Obstetric Panel
					Ultrasound
					Toxoplasma
					Rubella
					Cytomegalovirus
					Herpes Simplex
					ABO/Rh/Both
					*/

					SELECT	0 AS CountVisit,
							PE.DSMemberID,
							MAX(CASE WHEN t.Descr LIKE '%ABO/Rh/Both%' THEN 1 ELSE 0 END) AS HasAboRhBoth,
							MAX(CASE WHEN t.Descr LIKE '%Cytomegalovirus%' THEN 1 ELSE 0 END) AS HasCytomegalovirus,
							MAX(CASE WHEN t.Descr LIKE '%Herpes Simplex%' THEN 1 ELSE 0 END) AS HasHerpesSimplex,
							MAX(CASE WHEN t.Descr LIKE '%Obstetric Panel%' THEN 1 ELSE 0 END) AS HasObstetric,
							MAX(CASE WHEN t.Descr LIKE '%Rubella%' THEN 1 ELSE 0 END) AS HasRubella,
							MAX(CASE WHEN t.Descr LIKE '%Stand-Alone Prenatal Visits%' THEN 1 ELSE 0 END) AS HasStandAlone,
							MAX(CASE WHEN t.Descr LIKE '%Toxoplasma%' THEN 1 ELSE 0 END) AS HasToxoplasma,
							MAX(CASE WHEN t.Descr LIKE '%Ultrasound%' THEN 1 ELSE 0 END) AS HasUltrasound,
							MAX(CASE WHEN t.Descr LIKE '%Prenatal Visits%' AND t.Descr NOT LIKE '%Stand-Alone%' THEN 1 ELSE 0 END) AS HasVisit,
							CONVERT(bit, 0) AS IsTrimester1,
							FPC.KeyDate,
							ISNULL(PE.EndDate, PE.BeginDate) AS ServDate,
							FPC.SourceRowGuid,
							FPC.SourceRowID,
							DATEADD(dd, -280, FPC.KeyDate) AS Trimester1BeginDate,
							DATEADD(dd, -176, FPC.KeyDate) AS Trimester1EndDate,
							DATEADD(dd, -175, FPC.KeyDate) AS Trimester2BeginDate,
							DATEADD(dd, 0, FPC.KeyDate) AS Trimester3EndDate
					INTO	#FPCComponentEntities
					FROM	Proxy.Entities AS PE
							INNER JOIN #FPCComponents AS t
									ON t.EntityID = PE.EntityID
							INNER JOIN #FPCBase AS FPC
									ON FPC.BatchID = PE.BatchID AND
										FPC.DataRunID = PE.DataRunID AND
										FPC.DataSetID = PE.DataSetID AND
										FPC.DSMemberID = PE.DSMemberID
					GROUP BY PE.DSMemberID,
							ISNULL(PE.EndDate, PE.BeginDate),
							FPC.KeyDate,
							FPC.SourceRowGuid,
							FPC.SourceRowID;

					DELETE FROM #FPCComponentEntities WHERE ServDate NOT BETWEEN Trimester1BeginDate AND Trimester3EndDate;
					
					UPDATE	#FPCComponentEntities 
					SET		CountVisit =   CASE 
												--Stand-Alone Visit
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester3EndDate AND
													 HasStandAlone = 1 
												THEN 1
												--Visit w/ Obsteric panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasObstetric = 1
												THEN 1
												--Visit w/ Ultrasound
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester3EndDate AND
													 HasVisit = 1 AND
													 HasUltrasound = 1
												THEN 1
												--Visit w/ Rubella and ABO/Rh/Both panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasRubella = 1 AND
													 HasAboRhBoth = 1
												THEN 1
												--Visit w/ Rubella, Toxoplasma, Cytomegalovirus, and Herpes Simplex panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasRubella = 1 AND
													 HasCytomegalovirus = 1 AND 
													 HasHerpesSimplex = 1 AND
													 HasToxoplasma = 1
												THEN 1
												ELSE 0
												END,
							IsTrimester1 = CASE WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate THEN 1 ELSE 0 END
					WHERE	CountVisit = 0;

					CREATE UNIQUE CLUSTERED INDEX IX_#FPCComponentEntities ON #FPCComponentEntities (SourceRowID, ServDate);

					--1) First, count services that are covered on a single date...
					UPDATE	#FPCComponentEntities 
					SET		CountVisit =   CASE 
												--Stand-Alone Visit
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester3EndDate AND
													 HasStandAlone = 1 
												THEN 1
												--Visit w/ Obsteric panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasObstetric = 1
												THEN 1
												--Visit w/ Ultrasound
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester3EndDate AND
													 HasVisit = 1 AND
													 HasUltrasound = 1
												THEN 1
												--Visit w/ Rubella and ABO/Rh/Both panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasRubella = 1 AND
													 HasAboRhBoth = 1
												THEN 1
												--Visit w/ Rubella, Toxoplasma, Cytomegalovirus, and Herpes Simplex panels
												WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate AND
													 HasVisit = 1 AND
													 HasRubella = 1 AND
													 HasCytomegalovirus = 1 AND 
													 HasHerpesSimplex = 1 AND
													 HasToxoplasma = 1
												THEN 1
												ELSE 0
												END,
							IsTrimester1 = CASE WHEN ServDate BETWEEN Trimester1BeginDate AND Trimester1EndDate THEN 1 ELSE 0 END
					WHERE	CountVisit = 0;
					
					--2) Second, count services that span multiple dates, but haven't already been counted on step #1...
					SELECT	DSMemberID,
                            SUM(HasAboRhBoth) AS CountAboRhBoth,
                            SUM(HasCytomegalovirus) AS CountCytomegalovirus,
                            SUM(HasHerpesSimplex) AS CountHerpesSimplex,
                            SUM(HasObstetric) AS CountObstetric,
                            SUM(HasRubella) AS CountRubella,
                            SUM(HasToxoplasma) AS CountToxoplasma,
                            SUM(HasUltrasound) AS CountUltrasound,
                            0 AS CountVisit,
							SUM(HasVisit) AS CountVisitPart1,
							0 AS CountVisitPart2,
                            IsTrimester1,
                            KeyDate,
                            SourceRowGuid,
                            SourceRowID,
                            Trimester1BeginDate,
                            Trimester1EndDate,
                            Trimester2BeginDate,
                            Trimester3EndDate
					INTO	#FPCComponentEntities2
					FROM	#FPCComponentEntities
					WHERE	(CountVisit = 0)
					GROUP BY DSMemberID,
							IsTrimester1,
							KeyDate,
							SourceRowGuid,
							SourceRowID,
							Trimester1BeginDate,
                            Trimester1EndDate,
                            Trimester2BeginDate,
                            Trimester3EndDate;

					CREATE UNIQUE CLUSTERED INDEX IX_#FPCComponentEntities2 ON #FPCComponentEntities2 (SourceRowID, IsTrimester1);

					UPDATE	#FPCComponentEntities2
					SET		CountVisitPart2 = 
												 --Count of Rubella w/ ABO/Rh/Both panels
												CASE
													WHEN IsTrimester1 = 1 AND
														 CountAboRhBoth <= CountRubella
													THEN CountAboRhBoth
													WHEN IsTrimester1 = 1 AND
														 CountRubella <= CountAboRhBoth
													THEN CountRubella
													ELSE 0 END + 
												--Count of Rubella w/ Cytomegalovirus, Herpes Simples & Toxoplasma panels
												CASE
													WHEN IsTrimester1 = 1 AND
														 CountRubella - CountAboRhBoth > 0 AND
														 CountRubella - CountAboRhBoth <= CountCytomegalovirus AND
														 CountRubella - CountAboRhBoth <= CountHerpesSimplex AND
														 CountRubella - CountAboRhBoth <= CountToxoplasma
													THEN CountRubella - CountAboRhBoth
													WHEN IsTrimester1 = 1 AND
														 CountRubella - CountAboRhBoth > 0 AND
														 CountCytomegalovirus <= CountRubella - CountAboRhBoth AND
														 CountCytomegalovirus <= CountHerpesSimplex AND
														 CountCytomegalovirus <= CountToxoplasma
													THEN CountCytomegalovirus
													WHEN IsTrimester1 = 1 AND
														 CountRubella - CountAboRhBoth > 0 AND
														 CountHerpesSimplex <= CountRubella - CountAboRhBoth AND
														 CountHerpesSimplex <= CountCytomegalovirus AND
														 CountHerpesSimplex <= CountToxoplasma
													THEN CountHerpesSimplex
													WHEN IsTrimester1 = 1 AND
														 CountRubella - CountAboRhBoth > 0 AND
														 CountToxoplasma <= CountRubella - CountAboRhBoth AND
														 CountToxoplasma <= CountCytomegalovirus AND
														 CountToxoplasma <= CountHerpesSimplex
													THEN CountToxoplasma
													ELSE 0 END +
												--Count of Obstetric panels
												CASE WHEN IsTrimester1 = 1
												     THEN CountObstetric 
													 ELSE 0
													 END +
												--Count of Ultrasound
												CountUltrasound;

					--Set count of total number of visits that meet base criteria...
					UPDATE #FPCComponentEntities2 SET CountVisit = CASE WHEN CountVisitPart1 < CountVisitPart2 THEN CountVisitPart1 ELSE CountVisitPart2 END;

					--Combine same-date and multi-date visits to set new "Actual" count...
					UPDATE FPC
					SET		FPC.CountActual = ISNULL(SameDate.CountVisits, 0) + ISNULL(MultiDate.CountVisits, 0)
					FROM	#FPCBase AS FPC
							OUTER APPLY
										(
											SELECT	SUM(tA.CountVisit) AS CountVisits
											FROM	#FPCComponentEntities AS tA
											WHERE	tA.SourceRowID = FPC.SourceRowID
										) AS SameDate
							OUTER APPLY
										(
											SELECT	SUM(tA.CountVisit) AS CountVisits
											FROM	#FPCComponentEntities2 AS tA
											WHERE	tA.SourceRowID = FPC.SourceRowID
										) AS MultiDate;
				END;

			UPDATE	#FPCBase 
			SET		EnrollDays = 0,
					EnrollMonths = 0
			WHERE	EnrollDays < 0 OR EnrollMonths < 0 OR EnrollDays IS NULL OR EnrollMonths IS NULL;
					
			UPDATE	t
			SET		CountExpected = FPC.CountExpected
			FROM	#FPCBase AS t
					INNER JOIN Ncqa.FPC_ExpectedVisitsKey AS FPC
							ON t.EnrollMonths = FPC.EnrollMonths AND
								t.GestWeeks = FPC.GestWeeks;
			IF @CalculateXml = 1
				WITH FPCBase AS
				(
					SELECT	(
								SELECT	CountActual AS actual, 
										CountExpected AS expected, 
										dbo.ConvertDateToYYYYMMDD(LastSegBeginDate) AS lastSegBeginDate,
										dbo.ConvertDateToYYYYMMDD(LastSegEndDate) AS lastSegEndDate,
										EnrollMonths AS monthsEnrolled,
										GestWeeks AS weeksGestation,
										CONVERT(decimal(18,6), CountActual)/CONVERT(decimal(18,6), CountExpected) AS [percent]
								FOR XML RAW('fpc'), TYPE
							) AS FPCInfo,
							SourceRowID
					FROM	#FPCBase
				)
				UPDATE	t
				SET		ResultInfo.modify('insert sql:column("FPC.FPCInfo") as first into (/result[1])')
				FROM	#FPCBase AS t
						INNER JOIN FPCBase AS FPC
								ON FPC.SourceRowID = t.SourceRowID
				WHERE	(ResultInfo IS NOT NULL);
								
			DELETE FROM Result.MeasureDetail_FPC WHERE BatchID = @BatchID;
								
			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail_FPC)
				TRUNCATE TABLE Result.MeasureDetail_FPC;
								
			INSERT INTO Result.MeasureDetail_FPC
			        (BatchID,
					CountActual,
					CountExpected,
					DataRunID,
					DataSetID,
					DSMemberID,
					EnrollDays,
					EnrollMonths,
					GestDays,
					GestStartDate,
					GestWeeks,
					KeyDate,
					LastSegBeginDate,
					LastSegEndDate,
					ResultTypeID,
					SourceRowGuid,
					SourceRowID)
			SELECT	BatchID,
					CountActual,
					ISNULL(CountExpected, -1) AS CountExpected,
					DataRunID,
					DataSetID,
					DSMemberID,
					EnrollDays,
					EnrollMonths,
					GestDays,
					GestStartDate,
					GestWeeks,
					KeyDate,
					ISNULL(LastSegBeginDate, 0) AS LastSegBeginDate,
					ISNULL(LastSegEndDate, 0) AS LastSegEndDate,
					ResultTypeID,
					SourceRowGuid,
					SourceRowID
			FROM	#FPCBase;
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#FPCBase ON #FPCBase (SourceRowID ASC);
			
			WITH FPCMetricKey AS
			(
				SELECT 'FPC0' AS Metric, CONVERT(decimal(18,6), -999999) AS PercentMin, CONVERT(decimal(18,6), 0.20) AS PercentMax
				UNION
				SELECT 'FPC1' AS Metric, CONVERT(decimal(18,6), 0.21) AS PercentMin, CONVERT(decimal(18,6), 0.40) AS PercentMax
				UNION
				SELECT 'FPC2' AS Metric, CONVERT(decimal(18,6), 0.41) AS PercentMin, CONVERT(decimal(18,6), 0.60) AS PercentMax
				UNION
				SELECT 'FPC3' AS Metric, CONVERT(decimal(18,6), 0.61) AS PercentMin, CONVERT(decimal(18,6), 0.80) AS PercentMax
				UNION
				SELECT 'FPC4' AS Metric, CONVERT(decimal(18,6), 0.81) AS PercentMin, CONVERT(decimal(18,6), 999999) AS PercentMax
			)
			SELECT	MX.MetricID, MX.MetricXrefID, t.PercentMax, t.PercentMin
			INTO	#FPCMetricKey
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @MeasureSetID
					INNER JOIN FPCMetricKey AS t
							ON MX.Abbrev = t.Metric;		
							
			DELETE FROM Result.MeasureDetail WHERE BatchID = @BatchID AND DataRunID = @DataRunID AND DataSetID = @DataSetID AND MetricID IN (SELECT MetricID FROM #FPCMetricKey);

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
					ProductLineID,
					Qty,
					ResultInfo,
					ResultTypeID,
					SourceDenominator,
					SourceExclusion,
					SourceIndicator,
					SourceNumerator,
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
					RMD.[Days],
					RMD.DSEntityID,
					RMD.DSMemberID,
					RMD.DSProviderID,
					RMD.EndDate,
					RMD.EnrollGroupID,
					RMD.EntityID,
					RMD.Gender,
					RMD.IsDenominator,
					RMD.IsExclusion,
					RMD.IsIndicator,
					CASE WHEN (CONVERT(decimal(18,6), FPC.CountActual)/CONVERT(decimal(18,6), FPC.CountExpected)) BETWEEN t.PercentMin AND t.PercentMax 
						THEN 1 
						ELSE 0 
						END AS IsNumerator,
					NULL AS IsNumeratorAdmin,
					NULL AS IsNumeratorMedRcd,
					RMD.KeyDate,
					RMD.MeasureID,
					RMD.MeasureXrefID,
					t.MetricID,
					t.MetricXrefID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID,
					RMD.Qty,
					FPC.ResultInfo,
					RMD.ResultTypeID,
					RMD.SourceDenominator,
					RMD.SourceExclusion,
					RMD.SourceIndicator,
					RMD.SourceNumerator,
					RMD.[Weight]
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN #FPCBase AS FPC
							ON RMD.ResultRowID = FPC.SourceRowID
					CROSS JOIN #FPCMetricKey AS t
			WHERE	(RMD.BatchID = @BatchID) AND
					(RMD.DataRunID = @DataRunID) AND		
					(RMD.DataSetID = @DataSetID) AND
					(RMD.MetricID = @FPCMetricID);
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			SET @LogDescr = ' - Calculating FPC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating FPC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Ncqa].[FPC_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[FPC_CalculateMeasureDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[FPC_CalculateMeasureDetail] TO [Processor]
GO
