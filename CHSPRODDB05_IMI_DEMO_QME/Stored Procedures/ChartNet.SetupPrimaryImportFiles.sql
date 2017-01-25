SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/14/2015
-- Description: Generates the member, sample, scoring and admin event "files" for ChartNet.
-- =============================================
CREATE PROCEDURE [ChartNet].[SetupPrimaryImportFiles]
(
	@CustomerMemberIDPrefix varchar(32) = NULL,
	@DataRunID int,
	@DiabetesValueSetName varchar(32) = 'Diabetes',
	@IncludeEnrollGroup bit = 0,
	@ProductPrefix varchar(32) = NULL,
	@ProductSuffix varchar(32) = NULL,
	@PurgeExistingRecords bit = 1
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
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SetupPrimaryImportFiles'; 
		SET @LogObjectSchema = 'ChartNet'; 

		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------

		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@DataSetID = DS.DataSetID,
				@EndInitSeedDate = DR.EndInitSeedDate,
				@IsLogged = DR.IsLogged,
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID,
				@SeedDate = DR.SeedDate
		FROM	Batch.DataRuns AS DR
				INNER JOIN Batch.DataSets AS DS 
						ON DR.DataSetID = DS.DataSetID 
		WHERE	(DR.DataRunID = @DataRunID);
		
		DECLARE @CountRecords bigint;

		BEGIN TRY;

			--1) Purge results, if specified...
			IF @PurgeExistingRecords = 1 
			BEGIN;
				DELETE FROM [ChartNetImport].AdministrativeEvent;
				DELETE FROM [ChartNetImport].Member;
				DELETE FROM [ChartNetImport].MemberMeasureMetricScoring;
				DELETE FROM [ChartNetImport].MemberMeasureSample;
				DELETE FROM [ChartNetImport].Providers;
				DELETE FROM [ChartNetImport].ProviderSite;
				DELETE FROM [ChartNetImport].PursuitEvent;
			END;

			--2a) Identify systematic samples...
			DECLARE @ResultTypeA tinyint;
			DECLARE @ResultTypeH tinyint;
			SELECT @ResultTypeA = ResultTypeID FROM Result.ResultTypes WHERE Abbrev = 'A';
			SELECT @ResultTypeH = ResultTypeID FROM Result.ResultTypes WHERE Abbrev = 'H';

			IF OBJECT_ID('tempdb..#SystematicSample') IS NOT NULL
				DROP TABLE #SystematicSample;

			CREATE TABLE #MemberList 
			(
				DSMemberID bigint NOT NULL,
				IsAdditional bit NOT NULL DEFAULT(0),
				IsAuxiliary bit NOT NULL DEFAULT(0),
				MeasureID int NOT NULL,
				OutputCustomerMemberID varchar(32) NULL,
				OutputProduct varchar(64) NULL,
				OutputProductLine varchar(64) NULL,
				ProductLineID smallint NOT NULL DEFAULT(0),
				ResultTypeID tinyint NOT NULL,
				SysSampleOrder smallint NULL,
				SysSampleRefID bigint IDENTITY(1, 1) NOT NULL,
				PRIMARY KEY CLUSTERED (DSMemberID, MeasureID, ProductLineID)
			);

			INSERT INTO #MemberList
			        (DSMemberID,
			        MeasureID,
			        ProductLineID,
			        ResultTypeID)
			SELECT	RMD.DSMemberID,
					RMD.MeasureID,
					MIN(ProductLineID) AS ProductLineID,
					RMD.ResultTypeID
			FROM	Result.MeasureDetail_Classic AS RMD
			WHERE	DataRunID = @DataRunID AND
					ResultTypeID = @ResultTypeH
			GROUP BY RMD.DSMemberID,
					RMD.MeasureID,
					RMD.ResultTypeID;

			IF OBJECT_ID('ChartNetImport.AdditionalMembers') IS NOT NULL
				BEGIN;
					INSERT INTO #MemberList
							(DSMemberID,
							IsAdditional,
							MeasureID,
							OutputCustomerMemberID,
							OutputProduct,
							OutputProductLine,
							ProductLineID,
							ResultTypeID)
					SELECT	RDSMK.DSMemberID,
							1 AS IsAdditional,
							MM.MeasureID,
							CAM.OutputCustomerMemberID,
							CAM.OutputProduct,
							CAM.OutputProductLine,
							0 AS ProductLineID,
							@ResultTypeA AS ResultTypeID
					FROM	ChartNetImport.AdditionalMembers AS CAM
							INNER JOIN Result.DataSetMemberKey AS RDSMK
									ON RDSMK.CustomerMemberID = CAM.CustomerMemberID AND
										RDSMK.DataRunID = @DataRunID
							INNER JOIN Batch.DataRuns AS BDR
									ON BDR.DataRunID = RDSMK.DataRunID
							INNER JOIN Measure.Measures AS MM
									ON MM.MeasureSetID = BDR.MeasureSetID AND
										MM.Abbrev = CAM.Measure;

					WITH SampleOrder AS
					(
						SELECT	ML.DSMemberID,
                                ML.MeasureID,
                                ML.ProductLineID,
                                ROW_NUMBER() OVER (PARTITION BY ML.MeasureID ORDER BY ML.DSMemberID, ML.ProductLineID) AS SysSampleOrder
						FROM	#MemberList AS ML
						WHERE	ML.IsAdditional = 1
					)
					UPDATE	ML
					SET		SysSampleOrder = t.SysSampleOrder
					FROM	#MemberList AS ML
							INNER JOIN SampleOrder AS t
									ON t.DSMemberID = ML.DSMemberID AND
										t.MeasureID = ML.MeasureID AND
										t.ProductLineID = ML.ProductLineID;
				END;

			ALTER INDEX ALL ON #MemberList REBUILD;



			WITH PopulationDefaultProductLine AS
			(
				SELECT	MNPPL.PopulationID,
						MAX(MNPPL.ProductLineID) AS ProductLineID,
						BSS.SysSampleID
				FROM	Member.EnrollmentPopulationProductLines AS MNPPL WITH(NOLOCK)
						INNER JOIN Member.EnrollmentPopulations AS MNP WITH(NOLOCK)
								ON MNP.PopulationID = MNPPL.PopulationID
						INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK)
								ON PPL.ProductLineID = MNPPL.ProductLineID
						INNER JOIN Batch.SystematicSamples AS BSS WITH(NOLOCK)
								ON BSS.PopulationID = MNP.PopulationID AND
									BSS.BitProductLines & PPL.BitValue > 0
				WHERE	(BSS.DataRunID = @DataRunID) AND
						(MNP.OwnerID = @OwnerID) AND
						(MNP.DataSetID IS NULL OR MNP.DataSetID = @DataSetID)
				GROUP BY BSS.SysSampleID, MNPPL.PopulationID
				UNION
				SELECT	MNPPL.PopulationID,
						MIN(MNPPL.ProductLineID) AS ProductLineID,
						NULL AS SysSampleID
				FROM	Member.EnrollmentPopulationProductLines AS MNPPL WITH(NOLOCK)
						INNER JOIN Member.EnrollmentPopulations AS MNP WITH(NOLOCK)
								ON MNP.PopulationID = MNPPL.PopulationID
				WHERE	(MNP.OwnerID = @OwnerID) AND
						(MNP.DataSetID IS NULL OR MNP.DataSetID = @DataSetID)
				GROUP BY MNPPL.PopulationID
			)
			SELECT	RMD.DSMemberID,
					M.IhdsMemberID,
					M.MemberID,
					ISNULL(ML.OutputCustomerMemberID, ISNULL(@CustomerMemberIDPrefix, '') + M.CustomerMemberID) AS CustomerMemberID,
					M.DOB,
					M.Gender,
					ISNULL(ML.OutputProductLine, PPL.Descr) AS ProductLine,
					PPL.ProductLineID,
					ISNULL(@ProductPrefix + ' ', '') + ISNULL(ML.OutputProduct, MEP.Abbrev + ISNULL(CASE WHEN @IncludeEnrollGroup = 1 AND BSS.PayerID IS NOT NULL THEN '-' + MNG.Abbrev END, '')) + ISNULL(' ' + @ProductSuffix, '') AS Payer,
					MEP.Abbrev AS PopulationAbbrev,
					MEP.Descr AS PopulationDescr,
					RMD.PopulationID,
					MM.Abbrev AS Measure,
					RMD.MeasureID,
					MX.Abbrev AS Metric,
					RMD.MetricID,
					RMD.KeyDate,
					RMD.IsDenominator,
					RMD.IsIndicator,
					MX.IsInverse,
					RMD.IsNumerator,
					RMD.IsNumeratorAdmin,
					RMD.IsNumeratorMedRcd,
					CONVERT(varchar(1), RMD.ProductLineID) AS PursuitPrefix,
					CONVERT(varchar(1), RMD.ProductLineID) +
						REPLICATE('0', 4 - LEN(CONVERT(varchar(4), RMD.MeasureID))) + CONVERT(varchar(4), RMD.MeasureID) + 
						REPLICATE('0', 4 - LEN(CONVERT(varchar(4), ISNULL(RSS.SysSampleOrder, ML.SysSampleOrder)))) + CONVERT(varchar(4), ISNULL(RSS.SysSampleOrder, ML.SysSampleOrder)) + 
						REPLICATE('0', 11 - LEN(CONVERT(varchar(11), ISNULL(RSS.SysSampleRefID, ML.SysSampleRefID)))) + CONVERT(varchar(11), ISNULL(RSS.SysSampleRefID, ML.SysSampleRefID)) 
						AS PursuitRefNbr,
					RMD.ResultRowID,
					IDENTITY(int, 1, 1) AS RowID,
					RMD.SourceDenominator,
					RMD.SourceIndicator,
					RMD.SourceNumerator,
					ISNULL(RSS.SysSampleOrder, ML.SysSampleOrder) AS SysSampleOrder,
					ISNULL(RSS.IsAuxiliary, ML.IsAuxiliary) AS IsAuxiliary,
					RMD.DSEntityID,
					CONVERT(datetime, NULL) AS LastSegBeginDate,
					CONVERT(datetime, NULL) AS LastSegEndDate,
					CONVERT(datetime, NULL) AS DiabetesDiagnosisDate
			INTO	#SystematicSample
			FROM	Result.MeasureDetail_Classic AS RMD
					LEFT OUTER JOIN Result.SystematicSamples AS RSS
							ON RMD.SysSampleRefID = RSS.SysSampleRefID
					LEFT OUTER JOIN Batch.SystematicSamples AS BSS
							ON BSS.SysSampleID = RSS.SysSampleID
					INNER JOIN Member.Members AS M
							ON RMD.DataSetID = M.DataSetID AND
								RMD.DSMemberID = M.DSMemberID
					INNER JOIN #MemberList AS ML
							ON RMD.DSMemberID = ML.DSMemberID AND
								RMD.MeasureID = ML.MeasureID AND
								(
									RMD.ProductLineID = ML.ProductLineID OR
									ML.ProductLineID = 0 OR
									ML.ProductLineID IS NULL
								) AND
								RMD.DataRunID = @DataRunID AND
								RMD.ResultTypeID = ML.ResultTypeID
					INNER JOIN Measure.Metrics AS MX
							ON RMD.MetricID = MX.MetricID
					INNER JOIN Measure.Measures AS MM
							ON RMD.MeasureID = MM.MeasureID
					INNER JOIN Product.Payers AS PP
							ON RMD.PayerID = PP.PayerID
					INNER JOIN PopulationDefaultProductLine AS PDPP
							ON PDPP.PopulationID = RMD.PopulationID AND
								(
									PDPP.SysSampleID = RSS.SysSampleID OR
									(
										PDPP.SysSampleID IS NULL AND
										RSS.SysSampleID IS NULL
									)
								)
					INNER JOIN Product.ProductLines AS PPL
							ON PPL.ProductLineID = PDPP.ProductLineID
					INNER JOIN Member.EnrollmentPopulations AS MEP
							ON MEP.PopulationID = RMD.PopulationID
					LEFT OUTER JOIN Member.EnrollmentGroups AS MNG
							ON MNG.EnrollGroupID = RMD.EnrollGroupID
			WHERE	--(RMD.IsDenominator = 1)
					(
						RSS.SysSampleRefID IS NOT NULL OR --Normal Sample
						ML.IsAdditional = 1 --Additional Members
					)
			ORDER BY Measure, Metric, SysSampleOrder;

			CREATE UNIQUE CLUSTERED INDEX IX_#SystematicSample ON #SystematicSample (RowID);
			CREATE INDEX IX_#SystematicSample2 ON #SystematicSample (DSMemberID);

			--2b) Populate Diabetes Diagnosis Date...
			IF OBJECT_ID('tempdb..#DiabetesDiagnosisDates') IS NOT NULL
				DROP TABLE #DiabetesDiagnosisDates;

			WITH DiabetesEventCriteria AS
			(
				SELECT DISTINCT
						MVC.EventCritID 
				FROM	Measure.EventCriteria  AS MVC WITH(NOLOCK)
						INNER JOIN Measure.EventCriteriaCodes AS MVCC
								ON MVCC.EventCritID = MVC.EventCritID
						INNER JOIN Claim.CodeTypes AS CCT
								ON CCT.CodeTypeID = MVCC.CodeTypeID
				WHERE	Reference1 = @DiabetesValueSetName AND 
						MeasureSetID = @MeasureSetID AND
						CCT.CodeType = 'D'
			),
			DiabetesEvents AS
			(
				SELECT DISTINCT
						MV.EventID
				FROM	Measure.[Events] AS MV
						INNER JOIN Measure.EventOptions AS MVO
								ON MVO.EventID = MV.EventID AND
									MV.IsEnabled = 1 AND
									MVO.Allow = 1
						INNER JOIN DiabetesEventCriteria AS DVC
								ON DVC.EventCritID = MVO.EventCritID
						INNER JOIN Measure.MeasureEvents AS MMV
								ON MMV.EventID = MV.EventID
						INNER JOIN Measure.Measures AS MM
								ON MM.MeasureID = MMV.MeasureID AND
									MM.IsEnabled = 1 AND
									MM.Abbrev IN ('CBP','CDC')
				WHERE	MV.MeasureSetID = @MeasureSetID
			)
			SELECT	LV.DSMemberID,
					LV.MeasureID,
					MAX(ISNULL(LV.EndDate, LV.BeginDate)) AS ServDate
			INTO	#DiabetesDiagnosisDates
			FROM	Result.MeasureEventDetail AS LV
					INNER JOIN DiabetesEvents AS DV
							ON DV.EventID = LV.EventID
			WHERE	LV.DataRunID = @DataRunID AND
					LV.CodeType IN ('ICD-9 Diagnosis','ICD-10 Diagnosis')
			GROUP BY LV.DSMemberID, LV.MeasureID;

			CREATE UNIQUE CLUSTERED INDEX IX_#DiabetesDiagnosisDates ON #DiabetesDiagnosisDates (DSMemberID, MeasureID);

			UPDATE	SS
			SET		DiabetesDiagnosisDate = DDD.ServDate
			FROM	#SystematicSample AS SS
					INNER JOIN #DiabetesDiagnosisDates AS DDD
							ON SS.DSMemberID = DDD.DSMemberID AND
								SS.MeasureID = DDD.MeasureID
			WHERE	SS.DiabetesDiagnosisDate IS NOT NULL;


			--2c) Populate LastSegBeginDate and LastSegEndDate, as well as a secondary round for DiabetesDiagnosisDate
			CREATE UNIQUE INDEX IX_Log_Entities_DSEntityID_forTemp ON Log.Entities (DSEntityID, DSMemberID, DataRunID);

			UPDATE	SS
			SET		LastSegBeginDate = E.LastSegBeginDate,
					LastSegEndDate = E.LastSegEndDate
			FROM	#SystematicSample AS SS
					INNER JOIN Log.Entities AS E
							ON SS.DSEntityID = E.DSEntityID AND
								SS.DSMemberID = E.DSMemberID AND
								E.DataRunID = @DataRunID AND
								E.DataSetID = @DataSetID;

			UPDATE	SS
			SET		DiabetesDiagnosisDate = ISNULL(E.EndDate, E.BeginDate)
			FROM	#SystematicSample AS SS
					INNER JOIN Log.Entities AS E
							ON	(
									(SS.Measure = 'CBP' AND SS.SourceIndicator = E.DSEntityID) OR
									(SS.Measure = 'CDC' AND SS.SourceDenominator = E.DSEntityID)
								) AND
								SS.DSMemberID = E.DSMemberID AND
								E.DataRunID = @DataRunID AND
								E.DataSetID = @DataSetID
			WHERE	SS.Measure IN ('CBP', 'CDC') AND
					SS.DiabetesDiagnosisDate IS NULL;
					
			DROP INDEX IX_Log_Entities_DSEntityID_forTemp ON Log.Entities;

			UPDATE	SS1
			SET		SS1.DiabetesDiagnosisDate = ISNULL(SS1.DiabetesDiagnosisDate, SS2.DiabetesDiagnosisDate),
					SS1.LastSegBeginDate = ISNULL(SS1.LastSegBeginDate, SS2.LastSegBeginDate),
					SS1.LastSegEndDate = ISNULL(SS1.LastSegEndDate, SS2.LastSegEndDate)
			FROM	#SystematicSample AS SS1 
					INNER JOIN #SystematicSample AS SS2 
							ON SS2.CustomerMemberID = SS1.CustomerMemberID AND 
								SS2.DSMemberID = SS1.DSMemberID AND 
								SS2.MeasureID = SS1.MeasureID 
			WHERE	(
						(SS1.DiabetesDiagnosisDate IS NULL AND SS2.DiabetesDiagnosisDate IS NOT NULL) OR
						(SS1.LastSegBeginDate IS NULL AND SS2.LastSegBeginDate IS NOT NULL) OR
						(SS1.LastSegEndDate IS NULL AND SS2.LastSegEndDate IS NOT NULL)
					) AND
					SS1.Measure = 'CDC';

			DECLARE @ProductLine varchar(64);
			SELECT @ProductLine = MIN(ProductLine) FROM #SystematicSample;

			--3) Load Member data...
			WITH MemberInfo AS
			(
				SELECT DISTINCT
						CustomerMemberID,
						DSMemberID,
						IhdsMemberID,
						MemberID,
						DOB,
						Gender,
						MIN(ProductLineID) AS ProductLineID,
						Payer
				FROM	#SystematicSample
				GROUP BY CustomerMemberID,
						DSMemberID,
						IhdsMemberID,
						MemberID,
						DOB,
						Gender,
						Payer
			)
			INSERT INTO [ChartNetImport].Member
					(ProductLine,
					Product,
					CustomerMemberID,
					SSN,
					NameFirst,
					NameLast,
					NameMiddleInitial,
					NamePrefix,
					NameSuffix,
					DateOfBirth,
					Gender,
					Address1,
					Address2,
					City,
					[State],
					ZipCode,
					Race,
					Ethnicity,
					MemberLanguage,
					InterpreterFlag,
					SecondaryRefID)
			SELECT	PPL.Descr AS ProductLine,
					MI.Payer,
					MI.CustomerMemberID,
					LEFT(M.SSN, 9) AS SSN,
					LEFT(M.NameFirst, 30) AS NameFirst,
					LEFT(M.NameLast, 30) AS NameLast,
					ISNULL(M.NameMiddleInitial, '') AS NameMiddleInitial,
					ISNULL(NULL, '') AS NamePrefix,
					ISNULL(NULL, '') AS NameSuffix,
					M.DateOfBirth,
					LEFT(M.Gender, 1) AS Gender,
					LEFT(ISNULL(M.Address1, ''), 50) AS Address1,
					LEFT(ISNULL(M.Address2, ''), 50) AS Address2,
					LEFT(ISNULL(M.City, ''), 30) AS City,
					LEFT(ISNULL(M.[State], ''), 2) AS [State],
					LEFT(ISNULL(M.ZipCode, ''), 10) AS ZipCode,
					LEFT(ISNULL(M.Race, ''), 2) AS Race,
					LEFT(ISNULL(M.Ethnicity, ''), 2) AS Ethnicity,
					LEFT(ISNULL(M.MemberLanguage, ''), 2) AS MemberLanguage,
					LEFT(ISNULL(M.InterpreterFlag, ''), 1) AS InterpreterFlag,
					NULL
			FROM	dbo.Member AS M
					INNER JOIN MemberInfo AS MI
							ON --M.MemberID = MI.MemberID AND
								M.ihds_member_id = MI.IhdsMemberID
					INNER JOIN Product.ProductLines AS PPL 
							ON PPL.ProductLineID = MI.ProductLineID
					LEFT OUTER JOIN [ChartNetImport].Member AS CNIM
							ON CNIM.CustomerMemberID = MI.CustomerMemberID AND
								CNIM.ProductLine = PPL.Descr AND
								CNIM.Product = MI.Payer
			WHERE	(CNIM.CustomerMemberID IS NULL);

			SET @CountRecords = ISNULL(@CountRecords, 0);

			--3) Load measure systematic samples...
			WITH SysSampleSource AS
			(
				SELECT	CustomerMemberID,
						DSMemberID,
						IhdsMemberID,
						MemberID,
						DOB,
						Gender,
						ProductLine,
						Payer,
						PopulationID,
						Measure,
						MeasureID,
						KeyDate,
						CONVERT(bit, MAX(CONVERT(smallint, IsIndicator))) AS IsIndicator,
						SysSampleOrder,
						IsAuxiliary,
						LastSegBeginDate,
						LastSegEndDate,
						DiabetesDiagnosisDate
				FROM	#SystematicSample
				GROUP BY CustomerMemberID,
						DSMemberID,
						IhdsMemberID,
						MemberID,
						DOB,
						Gender,
						ProductLine,
						Payer,
						PopulationID,
						Measure,
						MeasureID,
						KeyDate,
						SysSampleOrder,
						IsAuxiliary,
						LastSegBeginDate,
						LastSegEndDate,
						DiabetesDiagnosisDate
			)
			INSERT INTO [ChartNetImport].MemberMeasureSample
					(ProductLine,
					Product,
					CustomerMemberID,
					HEDISMeasure,
					EventDate,
					SampleType,
					SampleDrawOrder,
					PPCPrenatalCareStartDate,
					PPCPrenatalCareEndDate,
					PPCPostpartumCareStartDate,
					PPCPostpartumCareEndDate,
					PPCEnrollmentCategory,
					PPCLastEnrollSegStartDate,
					PPCLastEnrollSegEndDate,
					PPCGestationalDays,
					DiabetesDiagnosisDate)
			SELECT DISTINCT
					SS.ProductLine AS ProductLine,
					SS.Payer AS Product,
					SS.CustomerMemberID,
					SS.Measure AS HEDISMeasure,
					SS.KeyDate AS EventDate,
					CASE SS.IsAuxiliary WHEN 0 THEN 'sample' WHEN 1 THEN 'oversample' END SampleType,
					SS.SysSampleOrder AS SampleDrawOrder,
					CASE WHEN SS.Measure IN ('FPC','PPC') THEN   
						CASE WHEN SS.IsIndicator = 1 
							 THEN DATEADD(dd, -280, SS.KeyDate)
							 ELSE SS.LastSegBeginDate
							 END
						END AS PPCPrenatalCareStartDate,
					CASE WHEN SS.Measure IN ('FPC','PPC') THEN  
						CASE WHEN SS.IsIndicator = 1 
							 THEN DATEADD(dd, -176, SS.KeyDate)
							 WHEN SS.LastSegBeginDate BETWEEN DATEADD(dd, -279, SS.KeyDate) AND DATEADD(dd, -219, SS.KeyDate)
							 THEN DATEADD(dd, -176, SS.KeyDate)
							 ELSE DATEADD(dd, 42, SS.LastSegBeginDate)
							 END
						END AS PPCPrenatalCareEndDate,
					CASE WHEN SS.Measure IN ('FPC','PPC') THEN DATEADD(dd, 21, SS.KeyDate) END AS PPCPostpartumCareStartDate,
					CASE WHEN SS.Measure IN ('FPC','PPC') THEN DATEADD(dd, 56, SS.KeyDate) END AS PPCPostpartumCareEndDate,
					CASE WHEN SS.Measure IN ('FPC','PPC') THEN  
						CASE WHEN SS.IsIndicator = 1 
							 THEN 1
							 WHEN SS.LastSegBeginDate BETWEEN DATEADD(dd, -279, SS.KeyDate) AND DATEADD(dd, -219, SS.KeyDate)
							 THEN 2
							 ELSE 3
							 END
						END AS PPCEnrollmentCategory,
					SS.LastSegBeginDate,
					SS.LastSegEndDate,
					280,
					SS.DiabetesDiagnosisDate
			FROM	SysSampleSource AS SS
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id
			ORDER BY HEDISMeasure, SampleDrawOrder;

			SET @CountRecords = ISNULL(@CountRecords, 0);

			--4) Load metric-level scoring...
			INSERT INTO [ChartNetImport].MemberMeasureMetricScoring
					(ProductLine,
					Product,
					CustomerMemberID,
					HEDISMeasure,
					EventDate,
					HEDISSubMetric,
					DenominatorCount,
					AdministrativeHitCount,
					MedicalRecordHitCount,
					HybridHitCount,
					SuppIndicator,
					ExclusionAdmin,
					ExclusionValidDataError,
					ExclusionPlanEmployee)
			SELECT DISTINCT
					SS.ProductLine AS ProductLine,
					SS.Payer AS Product,
					SS.CustomerMemberID,
					SS.Measure AS HEDISMeasure,
					SS.KeyDate AS EventDate,
					SS.Metric AS HEDISSubMetric,
					CONVERT(int, SS.IsDenominator) AS DenominatorCount,
					CONVERT(int, CASE WHEN MX.IsInverse = 1 THEN ISNULL(NULLIF(CONVERT(tinyint, ISNULL(SS.IsNumeratorAdmin, SS.IsNumerator)), 0) - 1, 1) ELSE ISNULL(SS.IsNumeratorAdmin, SS.IsNumerator) END) AS AdministrativeHitCount,
					CONVERT(int, ISNULL(SS.IsNumeratorMedRcd, 0)) AS MedicalRecordHitCount,
					CONVERT(int, SS.IsNumerator) AS HybridHitCount,
					CONVERT(int, SS.IsIndicator) AS SuppIndicator,
					0,
					0,
					0
			FROM	#SystematicSample AS SS
					INNER JOIN Measure.Metrics AS MX
							ON SS.MetricID = MX.MetricID
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id
			ORDER BY HEDISMeasure, CustomerMemberID, HEDISSubMetric;

			SET @CountRecords = ISNULL(@CountRecords, 0);

			--5) Load administrative numerator-related events
			/**************************************************************************************************************************/
			IF OBJECT_ID('tempdb..#HybridEventMembers') IS NOT NULL 
				DROP TABLE #HybridEventMembers;

			SELECT DISTINCT 
					RDSMK.DOB, RMD.DSMemberID 
			INTO	#HybridEventMembers 
			FROM	Result.MeasureDetail AS RMD 
					INNER JOIN Result.DataSetMemberKey AS RDSMK 
							ON RMD.DataRunID = RDSMK.DataRunID AND 
								RMD.DSMemberID = RDSMK.DSMemberID 
			WHERE	RMD.DataRunID = @DataRunID AND 
					RMD.ResultTypeID IN (2, 3);

			CREATE UNIQUE CLUSTERED INDEX IX_#HybridEventMembers ON #HybridEventMembers (DSMemberID);

			IF OBJECT_ID('tempdb..#HybridEventKey') IS NOT NULL
				DROP TABLE #HybridEventKey;

			SELECT DISTINCT
					MAX(MEC.AfterDOBDays) AS AfterDOBDays,
					MAX(MEC.AfterDOBMonths) AS AfterDOBMonths,
					MIN(CASE MDC.DateComparerGuid
							WHEN 'AAB7602B-91AD-4B16-8B09-5280ADADCF1E' 
							THEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, BDR.SeedDate))
							WHEN '393D75A2-B6D1-48E8-9568-AE802F8732F8'
							THEN DATEADD(dd, MEC.BeginDays, DATEADD(mm, MEC.BeginMonths, BDR.BeginInitSeedDate))
							ELSE '1/1/1900'
							END ) AS BeginDate,
					MIN(CASE MDC.DateComparerGuid 
							WHEN 'AAB7602B-91AD-4B16-8B09-5280ADADCF1E' 
							THEN DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, BDR.SeedDate))
							WHEN '393D75A2-B6D1-48E8-9568-AE802F8732F8'
							THEN DATEADD(dd, MEC.EndDays, DATEADD(mm, MEC.EndMonths, BDR.EndInitSeedDate))
							ELSE BDR.EndInitSeedDate
							END ) AS EndDate,
					MIN(ME.Descr) AS EntityDescr,
					ME.EntityID,
					MIN(MV.Descr) AS EventDescr,
					MV.EventID,
					MAX(CASE WHEN MEC.QtyMin > 1 THEN 1 ELSE 0 END) AS HasQtyReqs,
					MIN(MM.Abbrev) AS Measure,
					MM.MeasureID,
					MIN(MX.Abbrev) AS Metric,
					MX.MetricID	
			INTO	#HybridEventKey
			FROM	Measure.Entities AS ME
					INNER JOIN Measure.EntityCriteria AS MEC
							ON ME.EntityID = MEC.EntityID
					INNER JOIN Measure.Events AS MV
							ON MEC.DateComparerInfo = MV.EventID AND
								MV.IsEnabled = 1              
					INNER JOIN Measure.DateComparers AS MDC
							ON MEC.DateComparerID = MDC.DateComparerID
					INNER JOIN Measure.DateComparerTypes AS MDCT
							ON MDC.DateCompTypeID = MDCT.DateCompTypeID AND
								MDCT.Abbrev = 'V'              
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON ME.EntityID = METMM.EntityID
					INNER JOIN Measure.MappingTypes AS MMT
							ON METMM.MapTypeID = MMT.MapTypeID AND
								MMT.Descr = 'Numerator'              
					INNER JOIN Measure.Metrics AS MX
							ON METMM.MetricID = MX.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID
					INNER JOIN Measure.MeasureSets AS MMS
							ON MM.MeasureSetID = MMS.MeasureSetID
					INNER JOIN Batch.DataRuns AS BDR
							ON MMS.MeasureSetID = BDR.MeasureSetID
			WHERE	BDR.DataRunID = @DataRunID AND
					ME.IsEnabled = 1 AND
					MEC.IsEnabled = 1 AND
					MM.IsEnabled = 1 AND
					MMS.IsEnabled = 1 AND     
					MM.IsHybrid = 1 AND 
					MEC.Allow = 1
			GROUP BY ME.EntityID,
					MV.EventID,
					MM.MeasureID,
					MX.MetricID;

			CREATE UNIQUE CLUSTERED INDEX IX_#HybridEventKey ON #HybridEventKey (EntityID, EventID, MetricID);

			IF OBJECT_ID('tempdb..#HybridEvents') IS NOT NULL
				DROP TABLE #HybridEvents;

			SELECT	HK.EntityDescr,
					HK.EntityID,
					HK.EventDescr,
					HK.Measure,
					HK.MeasureID,
					HK.Metric,
					HK.MetricID,
					HK.EventID,
					LV.DSEventID,
					LV.DSMemberID,
					LV.CodeID,
					LV.BeginDate,
					LV.EndDate,
					LV.Value
			INTO	#HybridEvents
			FROM	Log.EntityBase AS LEB
					INNER JOIN #HybridEventKey AS HK
							ON LEB.EntityID = HK.EntityID AND
								LEB.DateComparerInfo = HK.EventID
					INNER JOIN Log.Events AS LV
							ON HK.EventID = LV.EventID AND
								LEB.DSMemberID = LV.DSMemberID AND                  
								(
									(LEB.DataSourceID = LV.DSEventID) OR
									(LEB.QtyMin > 1 AND LV.BeginDate BETWEEN LEB.EntityBeginDate AND LEB.EntityEndDate) OR
									(LEB.QtyMin > 1 AND LV.EndDate BETWEEN LEB.EntityBeginDate AND LEB.EntityEndDate)              
								)
			WHERE	LEB.DataRunID = @DataRunID AND
					LV.DataRunID = @DataRunID AND
					LV.DSMemberID IN (SELECT DISTINCT DSMemberID FROM #HybridEventMembers)      
			UNION
			--This section was added as a stopgap for missing EntityBase records, not all were coming back from the multi-node engine config.
			SELECT	HK.EntityDescr,
					HK.EntityID,
					HK.EventDescr,
					HK.Measure,
					HK.MeasureID,
					HK.Metric,
					HK.MetricID,
					HK.EventID,
					LV.DSEventID,
					LV.DSMemberID,
					LV.CodeID,
					LV.BeginDate,
					LV.EndDate,
					LV.Value
			FROM	Log.Events AS LV
					INNER JOIN #HybridEventMembers AS RDSMK
							ON LV.DSMemberID = RDSMK.DSMemberID
					INNER JOIN #HybridEventKey AS HK
							ON LV.EventID = HK.EventID AND
								LV.BeginDate >= DATEADD(day, HK.AfterDOBDays, DATEADD(month, HK.AfterDOBMonths, RDSMK.DOB)) AND
								(
									(LV.BeginDate BETWEEN HK.BeginDate AND HK.EndDate) OR
									(LV.EndDate BETWEEN HK.BeginDate AND HK.EndDate)                
								) AND
								(
									(HK.Measure NOT IN ('CIS','HPV', 'W15')) OR
									(HK.Measure = 'CIS' AND LV.BeginDate BETWEEN RDSMK.DOB AND DATEADD(year, 2, RDSMK.DOB)) OR
									(HK.Measure = 'HPV' AND LV.BeginDate BETWEEN DATEADD(year, 9, RDSMK.DOB) AND DATEADD(year, 13, RDSMK.DOB)) OR                      
									(HK.Measure = 'W15' AND LV.BeginDate BETWEEN RDSMK.DOB AND DATEADD(day, 90, DATEADD(month, 12, RDSMK.DOB)))
								)         
			WHERE	LV.DataRunID = @DataRunID AND
					HK.HasQtyReqs = 1
			ORDER BY Measure, Metric, EntityDescr, DSMemberID

			--Identify BP readings separately, since BP readings can involve more than one code...
			IF OBJECT_ID('tempdb..#BPCodes') IS NOT NULL
				DROP TABLE #BPCodes;

			SELECT DISTINCT
					MVCC.Code, MVCC.CodeID, MVCC.CodeTypeID
			INTO	#BPCodes
			FROM	Measure.MeasureEvents AS MMV WITH(NOLOCK)
					INNER JOIN Measure.Measures AS MM WITH(NOLOCK)
							ON MM.MeasureID = MMV.MeasureID AND
								MM.MeasureSetID = MMV.MeasureSetID
					INNER JOIN Measure.Events AS MV WITH(NOLOCK)
							ON MV.EventID = MMV.EventID AND
								MV.MeasureSetID = MMV.MeasureSetID
					INNER JOIN Measure.EventOptions AS MVO WITH(NOLOCK)
							ON MVO.EventID = MV.EventID
					INNER JOIN Measure.EventCriteria AS MVC WITH(NOLOCK)
							ON MVC.EventCritID = MVO.EventCritID
					INNER JOIN Measure.EventCriteriaCodes AS MVCC WITH(NOLOCK)
							ON MVCC.EventCritID = MVC.EventCritID
			WHERE	MMV.MeasureSetID = 22 AND
					MM.Abbrev = 'CDC' AND
					MV.Descr LIKE '%Blood Pressure%' AND
					MVC.Descr LIKE '%Blood Pressure%';

			CREATE UNIQUE CLUSTERED INDEX IX_#BPCodes ON #BPCodes (CodeID);

			IF OBJECT_ID('tempdb..#BPHybridEvents') IS NOT NULL
				DROP TABLE #BPHybridEvents;

			SELECT DISTINCT
					HV.EntityDescr,
					HV.EntityID,
					HV.EventDescr,
					HV.Measure,
					HV.MeasureID,
					HV.Metric,
					HV.MetricID,
					HV.EventID,
					HV.DSEventID,
					HV.DSMemberID,
					BP.CodeID,
					HV.BeginDate,
					HV.EndDate,
					HV.Value
			INTO	#BPHybridEvents
			FROM	#HybridEvents AS HV
					INNER JOIN Claim.ClaimLines AS CCL WITH(NOLOCK)
							ON CCL.DSMemberID = HV.DSMemberID AND
								(
									CCL.BeginDate BETWEEN HV.BeginDate AND HV.EndDate OR
									CCL.EndDate BETWEEN HV.BeginDate AND HV.EndDate
								) AND
								CCL.DataSetID = @DataSetID
					INNER JOIN Claim.ClaimCodes AS CCC WITH(NOLOCK)
							ON CCC.DSClaimLineID = CCL.DSClaimLineID
					INNER JOIN #BPCodes AS BP
							ON BP.CodeID = CCC.CodeID AND
								BP.CodeID <> HV.CodeID --Ignore any codes already identified
			WHERE	HV.Metric IN ('CDC8','CDC9');

			/**************************************************************************************************************************/

			INSERT INTO [ChartNetImport].AdministrativeEvent
					(AdministrativeEventID,
					HEDISMeasure,
					HEDISSubMetric,
					CustomerMemberID,
					CustomerProviderID,
					ServiceDate,
					ProcedureCode,
					DiagnosisCode,
					LOINC,
					LabResult,
					NDCCode,
					NDCDescription,
					CPT_IICode,
					Data_Source)
			SELECT DISTINCT
					/*'A' +*/ CONVERT(varchar(20), LV.DSEventID * 100000 + SS.MetricID) AS AdminEventID,
					SS.Measure AS HEDISMeasure,
					SS.Metric AS HEDISSubMetric,
					SS.CustomerMemberID,
					'' AS CustomerProviderID,
					ISNULL(LV.EndDate, LV.BeginDate) AS ServiceDate,
					CASE WHEN CCT.Abbrev IN ('CPT','HCPCS','ICD9Proc','ICD10Proc','SuppCode')
						 THEN CC.Code
						 ELSE ''
						 END AS ProcedureCode,
					CASE WHEN CCT.Abbrev IN ('ICD9Diag','ICD10Diag')
						 THEN CC.Code
						 WHEN CCT.Abbrev IN ('MSDRG')
						 THEN 'MS-DRG ' + CC.Code
						 ELSE ''
						 END AS DiagnosisCode,
					CASE WHEN CCT.Abbrev IN ('LOINC')
						 THEN CC.Code
						 ELSE ''
						 END AS LOINC,
					CASE WHEN CCT.Abbrev IN ('CPT','CPT2','LOINC','SuppCode')
						 THEN ISNULL(CONVERT(varchar(25), LV.[Value]), '')
						 ELSE ''
						 END AS LabResult,
					CASE WHEN CCT.Abbrev IN ('NDC')
						 THEN CC.Code
						 ELSE ''
						 END AS NDCCode,
					'' AS NDCDescription,
					CASE WHEN CCT.Abbrev IN ('CPT2')
						 THEN CC.Code
						 ELSE ''
						 END AS CPT_IICode,
					CASE WHEN LEN('NUM: ' + MV.Descr) > 50 
						 THEN LEFT('NUM: ' + MV.Descr, 47) + '...' 
						 ELSE LEFT('NUM: ' + MV.Descr, 50)
						 END AS DataSource
			FROM	#SystematicSample AS SS
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id	
					INNER JOIN [Log].Entities AS LE
							ON SS.SourceNumerator = LE.DSEntityID AND
								SS.DSMemberID = LE.DSMemberID AND              
								LE.DataRunID = @DataRunID 
					INNER JOIN [Log].EntityBase AS LEB
							ON LE.DSMemberID = LEB.DSMemberID AND
								LE.EntityBaseID = LEB.EntityBaseID AND
								LE.EntityID = LEB.EntityID AND
								LE.BatchID = LEB.BatchID AND
								LEB.DataRunID = @DataRunID            
					INNER JOIN Measure.EntityCriteria AS MEC
							ON LEB.EntityCritID = MEC.EntityCritID AND
								LEB.EntityID = MEC.EntityID AND
								MEC.RankOrder = 1        
					INNER JOIN Measure.DateComparers AS MDC
							ON MEC.DateComparerID = MDC.DateComparerID
					INNER JOIN Measure.DateComparerTypes AS MDCT
							ON MDC.DateCompTypeID = MDCT.DateCompTypeID AND
								MDCT.Abbrev = 'V'
					INNER JOIN [Log].[Events] AS LV
							ON (
									(LEB.SourceID = LV.DSEventID) OR
									(LEB.Qty > 1 AND LV.BeginDate BETWEEN LEB.EntityBeginDate AND LEB.EntityEndDate) OR
									(LEB.Qty > 1 AND LV.EndDate BETWEEN LEB.EntityBeginDate AND LEB.EntityEndDate) --OR
									--(LEB.Qty > 1 AND SS.Measure = 'W15')
								) AND
								MEC.DateComparerInfo = LV.EventID AND 
								LE.DSMemberID = LV.DSMemberID AND
								LV.DataRunID = @DataRunID AND
								LV.BatchID = LEB.BatchID
					INNER JOIN Claim.Codes AS CC
							ON LV.CodeID = CC.CodeID
					INNER JOIN Claim.CodeTypes AS CCT
							ON CC.CodeTypeID = CCT.CodeTypeID
					INNER JOIN Measure.[Events] AS MV
							ON LV.EventID = MV.EventID
			WHERE	(SS.Metric NOT LIKE 'CISCMB%') AND
					(SS.Metric NOT LIKE 'IMACMB%')
			UNION
			SELECT DISTINCT
					/*'B' +*/ CONVERT(varchar(20), HV.DSEventID * 100000 + SS.MetricID) AS AdminEventID,
					SS.Measure AS HEDISMeasure,
					SS.Metric AS HEDISSubMetric,
					SS.CustomerMemberID,
					'' AS CustomerProviderID,
					ISNULL(HV.EndDate, HV.BeginDate) AS ServiceDate,
					CASE WHEN CCT.Abbrev IN ('CPT','HCPCS','ICD9Proc','ICD10Proc','SuppCode')
						 THEN CC.Code
						 ELSE ''
						 END AS ProcedureCode,
					CASE WHEN CCT.Abbrev IN ('ICD9Diag','ICD10Diag')
						 THEN CC.Code
						 WHEN CCT.Abbrev IN ('MSDRG')
						 THEN 'MS-DRG ' + CC.Code
						 ELSE ''
						 END AS DiagnosisCode,
					CASE WHEN CCT.Abbrev IN ('LOINC')
						 THEN CC.Code
						 ELSE ''
						 END AS LOINC,
					CASE WHEN CCT.Abbrev IN ('CPT','CPT2','LOINC','SuppCode')
						 THEN ISNULL(CONVERT(varchar(25), HV.[Value]), '')
						 ELSE ''
						 END AS LabResult,
					CASE WHEN CCT.Abbrev IN ('NDC')
						 THEN CC.Code
						 ELSE ''
						 END AS NDCCode,
					'' AS NDCDescription,
					CASE WHEN CCT.Abbrev IN ('CPT2')
						 THEN CC.Code
						 ELSE ''
						 END AS CPT_IICode,
					CASE WHEN LEN('NUM: ' + MV.Descr) > 50 
						 THEN LEFT('NUM: ' + MV.Descr, 47) + '...' 
						 ELSE LEFT('NUM: ' + MV.Descr, 50)
						 END AS DataSource
			FROM	#SystematicSample AS SS
					INNER JOIN #HybridEvents AS HV
							ON SS.DSMemberID = HV.DSMemberID AND
								SS.MeasureID = HV.MeasureID AND              
								SS.MetricID = HV.MetricID              
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id	
					INNER JOIN Claim.Codes AS CC
							ON HV.CodeID = CC.CodeID
					INNER JOIN Claim.CodeTypes AS CCT
							ON CC.CodeTypeID = CCT.CodeTypeID
					INNER JOIN Measure.[Events] AS MV
							ON HV.EventID = MV.EventID
			WHERE	(SS.Metric NOT LIKE 'CISCMB%') AND
					(SS.Metric NOT LIKE 'IMACMB%')
			UNION
			SELECT DISTINCT
					/*'C' +*/ CONVERT(varchar(20), LV.DSEventID * 100000 + SS.MeasureID) AS AdminEventID,
					SS.Measure AS HEDISMeasure,
					NULL AS HEDISSubMetric,
					SS.CustomerMemberID,
					'' AS CustomerProviderID,
					ISNULL(LV.EndDate, LV.BeginDate) AS ServiceDate,
					CASE WHEN CCT.Abbrev IN ('CPT','HCPCS','ICD9Proc','ICD10Proc','SuppCode')
						 THEN CC.Code
						 ELSE ''
						 END AS ProcedureCode,
					CASE WHEN CCT.Abbrev IN ('ICD9Diag','ICD10Diag')
						 THEN CC.Code
						 WHEN CCT.Abbrev IN ('MSDRG')
						 THEN 'MS-DRG ' + CC.Code
						 ELSE ''
						 END AS DiagnosisCode,
					CASE WHEN CCT.Abbrev IN ('LOINC')
						 THEN CC.Code
						 ELSE ''
						 END AS LOINC,
					CASE WHEN CCT.Abbrev IN ('CPT','CPT2','LOINC','SuppCode')
						 THEN ISNULL(CONVERT(varchar(25), LV.[Value]), '')
						 ELSE ''
						 END AS LabResult,
					CASE WHEN CCT.Abbrev IN ('NDC')
						 THEN CC.Code
						 ELSE ''
						 END AS NDCCode,
					'' AS NDCDescription,
					CASE WHEN CCT.Abbrev IN ('CPT2')
						 THEN CC.Code
						 ELSE ''
						 END AS CPT_IICode,
					CASE WHEN LEN('EP: ' + MV.Descr) > 50 
						 THEN LEFT('EP: ' + MV.Descr, 47) + '...' 
						 ELSE LEFT('EP: ' + MV.Descr, 50)
						 END AS DataSource
			FROM	#SystematicSample AS SS
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id	
					INNER JOIN [Log].Entities AS LE
							ON SS.SourceDenominator = LE.DSEntityID AND
								SS.DSMemberID = LE.DSMemberID AND
								LE.DataRunID = @DataRunID 
					INNER JOIN Log.EntityBase AS LEB
							ON LE.DSMemberID = LEB.DSMemberID AND
								LE.EntityBaseID = LEB.EntityBaseID AND
								LE.BatchID = LEB.BatchID AND
								LE.DataRunID = @DataRunID 
					INNER JOIN Measure.EntityCriteria AS MEC
							ON LEB.EntityCritID = MEC.EntityCritID AND
								LEB.EntityID = MEC.EntityID AND
								MEC.RankOrder = 1                  
					INNER JOIN Measure.DateComparers AS MDC
							ON MEC.DateComparerID = MDC.DateComparerID
					INNER JOIN Measure.DateComparerTypes AS MDCT
							ON MDC.DateCompTypeID = MDCT.DateCompTypeID AND
								MDCT.Abbrev = 'V'
					INNER JOIN [Log].[Events] AS LV
							ON LE.SourceID = LV.DSEventID AND
								LE.DSMemberID = LV.DSMemberID AND              
								LV.DataRunID = @DataRunID
					INNER JOIN Claim.Codes AS CC
							ON LV.CodeID = CC.CodeID
					INNER JOIN Claim.CodeTypes AS CCT
							ON CC.CodeTypeID = CCT.CodeTypeID
					INNER JOIN Measure.[Events] AS MV
							ON LV.EventID = MV.EventID
			UNION
			SELECT DISTINCT
					'D' + CONVERT(varchar(20), HV.DSEventID * 100000 + SS.MetricID) AS AdminEventID,
					SS.Measure AS HEDISMeasure,
					SS.Metric AS HEDISSubMetric,
					SS.CustomerMemberID,
					'' AS CustomerProviderID,
					ISNULL(HV.EndDate, HV.BeginDate) AS ServiceDate,
					CASE WHEN CCT.Abbrev IN ('CPT','HCPCS','ICD9Proc','ICD10Proc','SuppCode')
							THEN CC.Code
							ELSE ''
							END AS ProcedureCode,
					CASE WHEN CCT.Abbrev IN ('ICD9Diag','ICD10Diag')
							THEN CC.Code
							WHEN CCT.Abbrev IN ('MSDRG')
							THEN 'MS-DRG ' + CC.Code
							ELSE ''
							END AS DiagnosisCode,
					CASE WHEN CCT.Abbrev IN ('LOINC')
							THEN CC.Code
							ELSE ''
							END AS LOINC,
					CASE WHEN CCT.Abbrev IN ('CPT','CPT2','LOINC', 'SuppCode')
							THEN ISNULL(CONVERT(varchar(25), HV.[Value]), '')
							ELSE ''
							END AS LabResult,
					CASE WHEN CCT.Abbrev IN ('NDC')
							THEN CC.Code
							ELSE ''
							END AS NDCCode,
					'' AS NDCDescription,
					CASE WHEN CCT.Abbrev IN ('CPT2')
							THEN CC.Code
							ELSE ''
							END AS CPT_IICode,
					CASE WHEN LEN('NUM: ' + MV.Descr) > 50 
							THEN LEFT('NUM: ' + MV.Descr, 47) + '...' 
							ELSE LEFT('NUM: ' + MV.Descr, 50)
							END AS DataSource
			FROM	#SystematicSample AS SS
					INNER JOIN #BPHybridEvents AS HV
							ON SS.DSMemberID = HV.DSMemberID AND
								SS.MeasureID = HV.MeasureID AND              
								SS.MetricID = HV.MetricID              
					INNER JOIN dbo.Member AS M
							ON SS.IhdsMemberID = M.ihds_member_id	
					INNER JOIN Claim.Codes AS CC
							ON HV.CodeID = CC.CodeID
					INNER JOIN Claim.CodeTypes AS CCT
							ON CC.CodeTypeID = CCT.CodeTypeID
					INNER JOIN Measure.[Events] AS MV
							ON HV.EventID = MV.EventID
			WHERE	(SS.Metric NOT LIKE 'CISCMB%') AND
					(SS.Metric NOT LIKE 'IMACMB%')
			UNION
			SELECT DISTINCT
					'E' + CONVERT(varchar(20), RMVD.DSEventID * 100000 + SS.MetricID) AS AdminEventID,
					SS.Measure AS HEDISMeasure,
					SS.Metric AS HEDISSubMetric,
					SS.CustomerMemberID,
					'' AS CustomerProviderID,
					ISNULL(RMVD.EndDate, RMVD.BeginDate) AS ServiceDate,
					CASE WHEN CCT.Abbrev IN ('CPT','HCPCS','ICD9Proc','ICD10Proc','SuppCode')
						 THEN CC.Code
						 ELSE ''
						 END AS ProcedureCode,
					CASE WHEN CCT.Abbrev IN ('ICD9Diag','ICD10Diag')
						 THEN CC.Code
						 WHEN CCT.Abbrev IN ('MSDRG')
						 THEN 'MS-DRG ' + CC.Code
						 ELSE ''
						 END AS DiagnosisCode,
					CASE WHEN CCT.Abbrev IN ('LOINC')
						 THEN CC.Code
						 ELSE ''
						 END AS LOINC,
					CASE WHEN CCT.Abbrev IN ('CPT','CPT2','LOINC', 'SuppCode')
						 THEN Lab.LabValue--ISNULL(CONVERT(varchar(25), RMVD.[Value]), '')
						 ELSE ''
						 END AS LabResult,
					CASE WHEN CCT.Abbrev IN ('NDC')
						 THEN CC.Code
						 ELSE ''
						 END AS NDCCode,
					'' AS NDCDescription,
					CASE WHEN CCT.Abbrev IN ('CPT2')
						 THEN CC.Code
						 ELSE ''
						 END AS CPT_IICode,
					CASE WHEN LEN('NUM: ' + RMVD.EventDescr) > 50 
						 THEN LEFT('NUM: ' + RMVD.EventDescr, 47) + '...' 
						 ELSE LEFT('NUM: ' + RMVD.EventDescr, 50)
						 END AS DataSource
			FROM	#SystematicSample AS SS 
					INNER JOIN Result.MeasureEventDetail AS RMVD 
							ON RMVD.DSMemberID = SS.DSMemberID AND
								RMVD.KeyDate = SS.KeyDate AND
								RMVD.MeasureID = SS.MeasureID AND
								RMVD.MetricID = SS.MetricID AND
								RMVD.DataRunID = @DataRunID
					INNER JOIN Measure.Metrics AS MX 
							ON MX.MetricID = RMVD.MetricID 
					INNER JOIN Claim.CodeTypes AS CCT
							ON CCT.Descr = RMVD.CodeType
					INNER JOIN Claim.Codes AS CC
							ON CC.Code = RMVD.Code AND
								CC.CodeTypeID = CCT.CodeTypeID
					OUTER APPLY	(
									SELECT TOP 1
											CONVERT(varchar(32), tCCL.LabValue) AS LabValue
									FROM	Claim.ClaimCodes AS tCCC WITH(NOLOCK)
											INNER JOIN Claim.ClaimLines AS tCCL WITH(NOLOCK)
													ON tCCL.DSClaimLineID = tCCC.DSClaimLineID AND
														tCCL.DataSetID = tCCC.DataSetID AND
														tCCL.DSMemberID = tCCC.DSMemberID
									WHERE	tCCL.DSMemberID = RMVD.DSMemberID AND
											tCCL.DataSetID = @DataSetID AND
											tCCC.CodeID = CC.CodeID AND
											(
												tCCL.BeginDate BETWEEN RMVD.BeginDate AND RMVD.EndDate OR
												tCCL.EndDate BETWEEN RMVD.BeginDate AND RMVD.EndDate OR
												tCCL.BeginDate = RMVD.ServDate OR
												tCCL.EndDate = RMVD.ServDate
											)
									ORDER BY tCCL.LabValue
								) AS Lab
			WHERE	(SS.Metric NOT LIKE 'CISCMB%') AND
					(SS.Metric NOT LIKE 'IMACMB%') AND
					RMVD.MapTypeID = 2 -- Numerators Only
			ORDER BY HEDISMeasure, CustomerMemberID, HEDISSubMetric, DataSource, ServiceDate;

			--Clean up duplicate admin events...
			IF OBJECT_ID('tempdb..#DeleteDuplicates') IS NOT NULL
				DROP TABLE #DeleteDuplicates;

			WITH AdminEventSource AS
			(
				SELECT	CNIAV.AdministrativeEventID,
						LEFT(CNIAV.AdministrativeEventID, 1) AS Parse1,
						RIGHT(CNIAV.AdministrativeEventID, LEN(CNIAV.AdministrativeEventID) - 1) AS Parse2,
						CNIAV.HEDISMeasure,
						CNIAV.HEDISSubMetric,
						CNIAV.CustomerMemberID,
						CNIAV.CustomerProviderID,
						CNIAV.ServiceDate,
						CNIAV.ProcedureCode,
						CNIAV.DiagnosisCode,
						CNIAV.LOINC,
						CNIAV.LabResult,
						CNIAV.NDCCode,
						CNIAV.NDCDescription,
						CNIAV.CPT_IICode,
						CNIAV.Data_Source
				FROM	ChartNetImport.AdministrativeEvent AS CNIAV
			),
			AdminEventDups AS
			(
				SELECT	MIN(AVS.Parse1) AS Parse1Min,
						MAX(AVS.Parse1) AS Parse1Max,
						MIN(AVS.AdministrativeEventID) AS AdministrativeEventIDMin,
						MAX(AVS.AdministrativeEventID) AS AdministrativeEventIDMax,
						AVS.Parse2,
						AVS.HEDISMeasure,
						AVS.HEDISSubMetric,
						AVS.CustomerMemberID,
						AVS.CustomerProviderID,
						AVS.ServiceDate,
						AVS.ProcedureCode,
						AVS.DiagnosisCode,
						AVS.LOINC,
						AVS.LabResult,
						AVS.NDCCode,
						AVS.NDCDescription,
						AVS.CPT_IICode,
						AVS.Data_Source
				FROM	AdminEventSource AS AVS
				GROUP BY AVS.Parse2,
						AVS.HEDISMeasure,
						AVS.HEDISSubMetric,
						AVS.CustomerMemberID,
						AVS.CustomerProviderID,
						AVS.ServiceDate,
						AVS.ProcedureCode,
						AVS.DiagnosisCode,
						AVS.LOINC,
						AVS.LabResult,
						AVS.NDCCode,
						AVS.NDCDescription,
						AVS.CPT_IICode,
						AVS.Data_Source
				HAVING (COUNT(*) > 1)
			)
			SELECT DISTINCT
					t.AdministrativeEventIDMax AS AdministrativeEventID,
					t.HEDISMeasure,
					t.HEDISSubMetric,
					t.CustomerMemberID
			INTO	#DeleteDuplicates
			FROM	AdminEventDups AS t;

			DELETE	CNIAV 
			FROM	ChartNetImport.AdministrativeEvent AS CNIAV 
					INNER JOIN #DeleteDuplicates AS t 
							ON t.AdministrativeEventID = CNIAV.AdministrativeEventID AND
								t.CustomerMemberID = CNIAV.CustomerMemberID AND
								t.HEDISMeasure = CNIAV.HEDISMeasure AND
								t.HEDISSubMetric = CNIAV.HEDISSubMetric;

			SET @CountRecords = ISNULL(@CountRecords, 0);

			----------------------------------------------

			--6) Return summary result sets of what was generated...
			SELECT 'AdministrativeEvent' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].AdministrativeEvent
			UNION ALL
			SELECT 'Member' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].Member
			UNION ALL
			SELECT 'MemberMeasureMetricScoring' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].MemberMeasureMetricScoring
			UNION ALL
			SELECT 'MemberMeasureSample' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].MemberMeasureSample
			UNION ALL
			SELECT 'Providers' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].Providers
			UNION ALL
			SELECT 'ProviderSite' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].ProviderSite
			UNION ALL
			SELECT 'PursuitEvent' AS [Source], COUNT(*) AS CountRecords FROM [ChartNetImport].PursuitEvent;

			SELECT	'Pursuit Event' AS Resultset,
					HEDISMeasure,
					ProductLine + ', ' + Product AS [Population],
					COUNT(DISTINCT CustomerMemberID) AS CountMembers,
					COUNT(DISTINCT CustomerProviderID) AS CountProviders,
					COUNT(*) AS CountRecords
			FROM	[ChartNetImport].PursuitEvent
			GROUP BY HEDISMeasure, ProductLine, Product
			ORDER BY 2, 3;

			SELECT	'Measure Sample' AS Resultset,
					HEDISMeasure,
					ProductLine + ', ' + Product AS [Population],
					COUNT(DISTINCT CustomerMemberID) AS CountMembers,
					COUNT(*) AS CountRecords,
					COUNT(DISTINCT SampleDrawOrder) AS CountSamples
			FROM	[ChartNetImport].MemberMeasureSample
			GROUP BY HEDISMeasure, ProductLine, Product
			ORDER BY 2, 3;

			SELECT	'Metric Scoring' AS Resultset,
					HEDISMeasure,
					ProductLine + ', ' + Product AS [Population],
					COUNT(DISTINCT CustomerMemberID) AS CountMembers,
					COUNT(*) AS CountRecords
			FROM	[ChartNetImport].MemberMeasureMetricScoring
			GROUP BY HEDISMeasure, ProductLine, Product
			ORDER BY 2, 3;			

			SET @LogDescr = 'Setting up member, sample, scoring and administrative event data for ChartNet completed succcessfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
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
			SET @LogDescr = 'Setting up member, sample, scoring and administrative event data for ChartNet  failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
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
GRANT EXECUTE ON  [ChartNet].[SetupPrimaryImportFiles] TO [Processor]
GO
