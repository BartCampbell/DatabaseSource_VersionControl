SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/30/2012
-- Description:	Refreshes medical record and hybrid results from ChartNet.
-- =============================================
CREATE PROCEDURE [ChartNet].[RefreshResults]
(
	@DataRunID int = NULL,
	@FlexDaysforFPCPPC tinyint = 30,
	@FlexDaysForMRP tinyint = 7,
	@FromDataRunID int = NULL,
	@IgnoreValidation bit = 0,
	@IncludeEnrollGroup bit = 0,
	@ProductPrefix varchar(32) = NULL,
	@ProductSuffix varchar(32) = NULL,
	@ToDataRunID int = NULL
)
AS
BEGIN
	
	IF @DataRunID IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Result.DataSetRunKey WHERE DataRunID = @DataRunID)
		BEGIN;
			SET @FromDataRunID = @DataRunID;
			SET @ToDataRunID = @DataRunID;			
		END;

	----------------------------------------------------------------------------------------------------------------------------------

	DECLARE @Message nvarchar(max);
	DECLARE @Severity int;
	DECLARE @State int;

	SET @Severity = 16;
	SET @State = 1;

	----------------------------------------------------------------------------------------------------------------------------------

	DECLARE @FromDataSetID int;
	DECLARE @FromMeasureSetID int;
	DECLARE @FromOwnerID int;
	DECLARE @ToDataSetID int;
	DECLARE @ToMeasureSetID int;
	DECLARE @ToOwnerID int;

	SELECT	@FromDataSetID = DR.DataSetID, 
			@FromMeasureSetID = DR.MeasureSetID,
			@FromOwnerID = DS.OwnerID
	FROM	Batch.DataRuns AS DR
			INNER JOIN Batch.DataSets AS DS
					ON DR.DataSetID = DS.DataSetID
	WHERE	(DR.DataRunID = @FromDataRunID);

	SELECT	@ToDataSetID = DR.DataSetID, 
			@ToMeasureSetID = DR.MeasureSetID,
			@ToOwnerID = DS.OwnerID
	FROM	Batch.DataRuns AS DR
			INNER JOIN Batch.DataSets AS DS
					ON DR.DataSetID = DS.DataSetID
	WHERE	(DR.DataRunID = @ToDataRunID);

	IF @FromOwnerID IS NULL OR @ToOwnerID IS NULL OR @FromOwnerID <> @ToOwnerID 
		BEGIN
			SET @Message = 'Invalid conversion.  The data owners do not match.';
			
			RAISERROR(@Message, @Severity, @State);
		END;

	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------
	--This process is designed combine metric results from ChartNet and a potentially-separate data run into the specified data run.--  
	----------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------

	SET NOCOUNT ON;

	--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
	DECLARE @Ansi_Warnings bit;
	SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

	IF @Ansi_Warnings = 1
		SET ANSI_WARNINGS OFF;

	DECLARE @CountActual bigint;
	DECLARE @CountExpected bigint;

	BEGIN TRY;
	
		IF @FromDataRunID IS NULL OR @ToDataRunID IS NULL OR 
			NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetRunKey WHERE DataRunID = @FromDataRunID) OR
			NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetRunKey WHERE DataRunID = @ToDataRunID)
			BEGIN;
			
				SET @Message = 'The specified data run information is invalid.';
				RAISERROR(@Message, @Severity, @State);			
			END;
		
	
		--i) Execute the refresh of ChartNet data in Staging...
			EXEC ChartNet.RefreshAll;
			
	
		--1) Create a member conversion key, verified by Customer Member ID, DOB, and Gender...
		IF OBJECT_ID('tempdb..#MemberKey') IS NOT NULL
			DROP TABLE #MemberKey;
			
		WITH Members AS
		(
			SELECT DISTINCT
					CSS.CustomerMemberID,
					M.DateOfBirth AS DOB,
					CONVERT(tinyint, CASE M.Gender WHEN 'F' THEN 0 WHEN 'M' THEN 1 ELSE 2 END) AS Gender,
					CSS.IhdsMemberID,
					CSS.MemberID,
					CSS.StagingMemberID
			FROM	ChartNet.SystematicSamples AS CSS
					INNER JOIN dbo.Member AS M
							ON CSS.CustomerMemberID = M.CustomerMemberID AND
								CSS.IhdsMemberID = M.ihds_member_id AND
								CSS.StagingMemberID = M.MemberID
		)
		SELECT DISTINCT
				t.CustomerMemberID,
				FM.DSMemberID AS FromDSMemberID,
				t.IhdsMemberID,
				t.MemberID,
				t.StagingMemberID,
				TM.DSMemberID AS ToDSMemberID
		INTO	#MemberKey
		FROM	Members AS t
				LEFT OUTER JOIN Result.DataSetMemberKey AS FM
						ON t.CustomerMemberID = FM.CustomerMemberID AND
							--t.DOB = FM.DOB AND
							--t.Gender = FM.Gender AND
							t.IhdsMemberID = FM.IhdsMemberID AND
							FM.DataRunID = @FromDataRunID AND
							FM.DataSetID = @FromDataSetID
				LEFT OUTER JOIN Result.DataSetMemberKey AS TM
						ON t.CustomerMemberID = TM.CustomerMemberID AND
							--t.DOB = TM.DOB AND
							--t.Gender = TM.Gender AND
							t.IhdsMemberID = TM.IhdsMemberID AND
							TM.DataRunID = @ToDataRunID AND
							TM.DataSetID = @ToDataSetID;

		SELECT @CountActual = COUNT(*) FROM #MemberKey WHERE FromDSMemberID IS NOT NULL AND ToDSMemberID IS NOT NULL;
		SELECT @CountExpected = COUNT(DISTINCT CustomerMemberID) FROM ChartNet.SystematicSamples;

		IF @CountActual = 0 OR @CountExpected = 0  OR @CountActual <> @CountExpected
			BEGIN;
				SET @Message = 'Staging-to-Engine member conversion failed. (Expected Rows: ' + 
								CONVERT(nvarchar(max), @CountExpected) + ', Actual Rows: ' + CONVERT(nvarchar(max), @CountActual) + ').';
								
				RAISERROR(@Message, @Severity, @State);
			END;
			
		CREATE UNIQUE CLUSTERED INDEX IX_#MemberKey ON #MemberKey (IhdsMemberID);


		--1) Create a systematic sample conversion key...
		IF OBJECT_ID('tempdb..#SysSampleKey') IS NOT NULL
			DROP TABLE #SysSampleKey;

		WITH SystematicSamples AS
		(
			SELECT	RSS.DataRunID,
					RSS.DataSetID,
					RSS.DSMemberID,
					RSS.IsAuxiliary,
					BSS.IsSysSampleAscending,
					RSS.KeyDate,
					MM.Abbrev AS MeasureAbbrev,
					BSS.MeasureID,
					BSS.PayerID,
					BSS.PopulationID,
					-- Borrowed from ChartNet.SetupPrimaryImportFiles ("Payer" field) ------------------------------------------------------------
					ISNULL(@ProductPrefix + ' ', '') + MEP.Abbrev + ISNULL(CASE WHEN @IncludeEnrollGroup = 1 AND BSS.PayerID IS NOT NULL THEN '-' + MNG.Abbrev END, '') + ISNULL(' ' + @ProductSuffix, '') AS Product, 
					------------------------------------------------------------------------------------------------------------------------------
					BSS.ProductClassID,
					BSS.ProductLineID,
					RSS.ResultRowID,
					BSS.SysSampleGuid,
					RSS.SysSampleID,
					RSS.SysSampleOrder,
					BSS.SysSampleRand,
					BSS.SysSampleRate, 
					RSS.SysSampleRefGuid,    
					RSS.SysSampleRefID,
					BSS.SysSampleSize
			FROM	Result.SystematicSamples AS RSS
					INNER JOIN Batch.SystematicSamples AS BSS
							ON RSS.DataRunID = BSS.DataRunID AND
								RSS.SysSampleID = BSS.SysSampleID
					OUTER APPLY (
									SELECT TOP 1
											tRMD.EnrollGroupID
									FROM	Result.MeasureDetail AS tRMD
									WHERE	tRMD.DataRunID = RSS.DataRunID AND
											tRMD.DSMemberID = RSS.DSMemberID AND
											tRMD.MeasureID = BSS.MeasureID AND
											tRMD.PopulationID = BSS.PopulationID AND
											tRMD.SysSampleRefID = RSS.SysSampleRefID
								) AS RMD
					INNER JOIN Measure.Measures AS MM
							ON BSS.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @FromMeasureSetID	
					INNER JOIN Member.EnrollmentPopulations AS MEP
							ON MEP.PopulationID = BSS.PopulationID	
					LEFT OUTER JOIN Member.EnrollmentGroups AS MNG
							ON MNG.PopulationID = BSS.PopulationID AND
								MNG.EnrollGroupID = RMD.EnrollGroupID
			WHERE	(RSS.DataRunID = @FromDataRunID)
		)
		SELECT	CSS.ChartNetSampleID,
				CSS.KeyDate AS ChartNetKeyDate,
				MC.FromDSMemberID,
				RSS.KeyDate AS FromKeyDate,
				RSS.MeasureID AS FromMeasureID,
				RSS.SysSampleGuid AS FromSysSampleGuid,
				RSS.SysSampleID AS FromSysSampleID,
				RSS.SysSampleRefGuid AS FromSysSampleRefGuid,
				RSS.SysSampleRefID AS FromSysSampleRefID,
				--MC.IhdsMemberID,
				CSS.MeasureAbbrev,
				CSS.RowID,
				CONVERT(uniqueidentifier, CONVERT(binary, 0)) AS SysSampleGuid,
				RSS.SysSampleOrder,
				CONVERT(uniqueidentifier, CONVERT(binary, 0)) AS SysSampleRefGuid,
				MC.ToDSMemberID,
				CONVERT(int, NULL) AS ToMeasureID,
				CONVERT(int, NULL) AS ToSysSampleID
		INTO	#SysSampleKey
		FROM	ChartNet.SystematicSamples AS CSS
				LEFT OUTER JOIN #MemberKey AS MC
						ON CSS.CustomerMemberID = MC.CustomerMemberID AND
							CSS.IhdsMemberID = MC.IhdsMemberID AND
							CSS.MemberID = MC.MemberID AND
							CSS.StagingMemberID = MC.StagingMemberID
				LEFT OUTER JOIN SystematicSamples AS RSS
						ON MC.FromDSMemberID = RSS.DSMemberID AND
							(
								(CSS.MeasureAbbrev NOT IN ('FPC','PPC','MRP')) OR 
								(CSS.MeasureAbbrev IN ('FPC','PPC') AND CSS.KeyDate BETWEEN DATEADD(dd, @FlexDaysforFPCPPC * -1, RSS.KeyDate) AND DATEADD(dd, @FlexDaysforFPCPPC, RSS.KeyDate)) OR
								(CSS.MeasureAbbrev IN ('MRP') AND CSS.KeyDate BETWEEN DATEADD(dd, @FlexDaysForMRP * -1, RSS.KeyDate) AND DATEADD(dd, @FlexDaysForMRP, RSS.KeyDate))
							) AND
							CSS.Product LIKE '%' + RSS.Product AND
							CSS.MeasureAbbrev = RSS.MeasureAbbrev AND
							CSS.SysSampleOrder = RSS.SysSampleOrder;
						
		--If any samples could not be matched, return a list of them...
		IF EXISTS (SELECT TOP 1 1 FROM #SysSampleKey WHERE (FromSysSampleRefID IS NULL))
			SELECT	'Unmatched Samples' AS [Source], 
					ChartNetSampleID AS [ChartNet Sample ID], 
					MeasureAbbrev AS [Measure], 
					RowID AS [Row ID], 
					CASE WHEN FromDSMemberID IS NULL THEN 'Member Key' WHEN FromSysSampleRefID IS NULL THEN 'Sample Key' ELSE 'Other' END AS [Missing Reference]
			FROM	#SysSampleKey WHERE FromSysSampleRefID IS NULL 
			ORDER BY 3, 2;
		
		--If there are duplicates matches, return a list of them...
		IF EXISTS (SELECT TOP 1 1 FROM #SysSampleKey GROUP BY FromSysSampleRefID HAVING COUNT(*) > 1)
			WITH Duplicates AS
			(
				SELECT FromSysSampleRefID FROM #SysSampleKey GROUP BY FromSysSampleRefID HAVING COUNT(*) > 1
			)
			SELECT	'Duplicate Samples' AS [Source],
					t.ChartNetSampleID AS [ChartNet Sample ID], 
					t.MeasureAbbrev AS [Measure], 
					t.RowID AS [Row ID],
					t.FromSysSampleRefID AS [Sys Sample Ref ID],
					t.ChartNetKeyDate AS [Chart Net - Key Date],
					t.FromKeyDate AS [QME - Key Date]
			FROM	#SysSampleKey AS t
					INNER JOIN Duplicates AS d
							ON d.FromSysSampleRefID = t.FromSysSampleRefID
			ORDER BY 3, 5, 6; 

		DELETE FROM #SysSampleKey WHERE FromSysSampleRefID IS NULL;

		IF OBJECT_ID('tempdb..#GuidKey') IS NOT NULL
			DROP TABLE #GuidKey;
							
		WITH FromGuids AS
		(			
			SELECT DISTINCT
					FromSysSampleGuid AS FromGuid
			FROM	#SysSampleKey
			UNION
			SELECT DISTINCT
					FromSysSampleRefGuid AS FromGuid
			FROM	#SysSampleKey
		)
		SELECT	FromGuid, NEWID() AS ToGuid
		INTO	#GuidKey
		FROM	FromGuids
		ORDER BY FromGuid;

		CREATE UNIQUE CLUSTERED INDEX IX_#GuidKey ON #GuidKey (FromGuid);

		UPDATE	SSK
		SET		SysSampleGuid = GK1.ToGuid,
				SysSampleRefGuid = GK2.ToGuid
		FROM	#SysSampleKey AS SSK
				INNER JOIN #GuidKey AS GK1
						ON SSK.FromSysSampleGuid = GK1.FromGuid
				INNER JOIN #GuidKey AS GK2
						ON SSK.FromSysSampleRefGuid = GK2.FromGuid;
							
		--Verify the "From" side, Part 1...
		SELECT @CountActual = COUNT(*) FROM #SysSampleKey;
		SELECT @CountExpected = COUNT(*) FROM Result.SystematicSamples WHERE DataRunID = @FromDataRunID;

		IF @IgnoreValidation = 0 AND (@CountActual = 0 OR @CountExpected = 0  OR @CountActual <> @CountExpected)
			BEGIN;
				SET @Message = 'Staging-to-Engine sample conversion failed. (Expected Rows: ' + 
								CONVERT(nvarchar(max), @CountExpected) + ', Actual Rows: ' + CONVERT(nvarchar(max), @CountActual) + ').';
								
				PRINT 'FROM-side, Part 1...';
				RAISERROR(@Message, @Severity, @State);
			END;
			
		--Verify the "From" side, Part 2...
		SELECT @CountActual = COUNT(DISTINCT FromSysSampleRefID) FROM #SysSampleKey;

		IF @IgnoreValidation = 0 AND (@CountActual = 0 OR @CountExpected = 0  OR @CountActual <> @CountExpected)
			BEGIN;
				SET @Message = 'Staging-to-Engine sample conversion failed. (Expected Rows: ' + 
								CONVERT(nvarchar(max), @CountExpected) + ', Actual Rows: ' + CONVERT(nvarchar(max), @CountActual) + ').';
								
				PRINT 'FROM-side, Part 2...';
				RAISERROR(@Message, @Severity, @State);
			END;
						
		--Verify the "ChartNet" side...
		SELECT @CountActual = COUNT(DISTINCT RowID) FROM #SysSampleKey;
		SELECT @CountExpected = COUNT(*) FROM ChartNet.SystematicSamples;

		IF @IgnoreValidation = 0 AND (@CountActual = 0 OR @CountExpected = 0  OR @CountActual <> @CountExpected)
			BEGIN;
				SET @Message = 'Staging-to-Engine sample conversion failed. (Expected Rows: ' + 
								CONVERT(nvarchar(max), @CountExpected) + ', Actual Rows: ' + CONVERT(nvarchar(max), @CountActual) + ').';
								
				PRINT 'ChartNet-side...';
				RAISERROR(@Message, @Severity, @State);
			END;
			
		CREATE UNIQUE CLUSTERED INDEX IX_#SysSampleKey ON #SysSampleKey (FromSysSampleRefID);


		--3) Create a metric results key...
		IF OBJECT_ID('tempdb..#MetricResultsKey') IS NOT NULL
			DROP TABLE #MetricResultsKey;

		WITH MetricResults AS
		(
			SELECT	RMD.Age,
					RMD.AgeMonths,
					RMD.AgeBandID,
					RMD.AgeBandSegID,
					RMD.BatchID,
					RMD.BeginDate,
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
					MX.IsInverse,
					RMD.IsNumerator,
					RMD.IsNumeratorAdmin,
					RMD.IsNumeratorMedRcd,
					RMD.KeyDate,
					MM.Abbrev AS MeasureAbbrev,
					RMD.MeasureID,
					MX.Abbrev AS MetricAbbrev,
					RMD.MetricID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID,
					RMD.Qty,
					RMD.ResultRowID,
					RRT.Abbrev AS ResultType,
					RMD.ResultTypeID,
					RMD.SourceDenominator,
					RMD.SourceExclusion,
					RMD.SourceIndicator,
					RMD.SourceNumerator,
					RMD.SysSampleRefID,
					RMD.[Weight]
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Measure.Metrics AS MX
							ON RMD.MetricID = MX.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID
					INNER JOIN Result.ResultTypes AS RRT
							ON RMD.ResultTypeID = RRT.ResultTypeID AND
								RRT.Abbrev IN ('H','M')
			WHERE	(RMD.DataRunID = @FromDataRunID) AND
					(MM.MeasureSetID = @FromMeasureSetID)
		)
		SELECT	--SSK.ChartNetSampleID,
				CMR.ExclusionReason,
				CONVERT(tinyint, NULL) AS ExclusionTypeID,
				SSK.FromDSMemberID,
				RMD.MeasureID AS FromMeasureID,
				RMD.MetricID AS FromMetricID,
				RMD.ResultRowID AS FromResultRowID,
				--SSK.FromSysSampleID,
				SSK.FromSysSampleRefID,
				--SSK.IhdsMemberID,
				CONVERT(bit, 0) AS HasAdminUpdates,
				CMR.IsDenominator,
				CMR.IsExclusion,
				CMR.IsReqExcl AS IsIndicator,
				--RMD.IsInverse,
				COALESCE(/*RMD.IsNumeratorAdmin,*/ CMR.IsNumeratorAdmin, 0) AS IsNumeratorAdmin,
				CONVERT(bit, CASE 
								WHEN RMD.IsInverse = 1 AND 1 = 2 --AND COALESCE(RMD.IsNumeratorAdmin, CMR.IsNumeratorAdmin, 0) = 0 
								THEN ISNULL(NULLIF(CONVERT(tinyint, CMR.IsNumeratorMedRcd), 0), 2) - 1 
								ELSE CMR.IsNumeratorMedRcd 
								END) AS IsNumeratorMedRcd,
				CASE RMD.ResultType WHEN 'H' THEN CONVERT(bit, CASE 
																	WHEN RMD.IsInverse = 1 AND 1 = 2
																	THEN ISNULL(NULLIF(CONVERT(tinyint, CMR.IsNumerator), 0), 2) - 1 
																	ELSE CMR.IsNumerator 
																	END) 
									WHEN 'M' THEN CONVERT(bit, CASE 
																	WHEN RMD.IsInverse = 1 AND 1 = 2--AND COALESCE(RMD.IsNumeratorAdmin, CMR.IsNumeratorAdmin, 0) = 0 
																	THEN ISNULL(NULLIF(CONVERT(tinyint, CMR.IsNumeratorMedRcd), 0), 2) - 1 
																	ELSE CMR.IsNumeratorMedRcd 
																	END)
									END AS IsNumerator,
				CMR.IsSampleVoid,
				RMD.KeyDate,
				RMD.MeasureAbbrev,
				RMD.MetricAbbrev,
				IDENTITY(int, 1, 1) AS RowID,
				--RMD.ResultType,
				RMD.ResultTypeID,
				--SSK.SysSampleGuid,
				SSK.RowID AS SysSampleKeyRowID,
				SSK.SysSampleOrder,
				SSK.SysSampleRefGuid,
				SSK.ToDSMemberID,
				CONVERT(int, NULL) AS ToMeasureID,
				CONVERT(int, NULL) AS ToMetricID,
				CONVERT(int, NULL) AS ToSysSampleID,
				CONVERT(int, NULL) AS ToSysSampleRefID
		INTO	#MetricResultsKey
		FROM	#SysSampleKey AS SSK
				INNER JOIN MetricResults AS RMD
						ON SSK.FromDSMemberID = RMD.DSMemberID AND
							SSK.FromMeasureID = RMD.MeasureID AND
							SSK.FromSysSampleRefID = RMD.SysSampleRefID
				INNER JOIN ChartNet.MeasureResults AS CMR
						ON SSK.ChartNetSampleID = CMR.ChartNetSampleID AND
							(
								(CMR.MeasureAbbrev NOT IN ('FPC','PPC','MRP')) OR 
								(CMR.MeasureAbbrev IN ('FPC','PPC') AND RMD.KeyDate BETWEEN DATEADD(dd, @FlexDaysforFPCPPC * -1, CMR.KeyDate) AND DATEADD(dd, @FlexDaysforFPCPPC, CMR.KeyDate)) OR
								(CMR.MeasureAbbrev IN ('MRP') AND RMD.KeyDate BETWEEN DATEADD(dd, @FlexDaysForMRP * -1, CMR.KeyDate) AND DATEADD(dd, @FlexDaysForMRP, CMR.KeyDate))
							) AND
							RMD.MeasureAbbrev = CMR.MeasureAbbrev AND
							RMD.MetricAbbrev = CMR.MetricAbbrev
		ORDER BY ResultTypeID, MeasureAbbrev, MetricAbbrev, SysSampleOrder;


		IF OBJECT_ID('tempdb..#MetricConversionKey') IS NOT NULL
			DROP TABLE #MetricConversionKey;

		WITH FromMetrics AS
		(
			SELECT	MX.*, MM.Abbrev AS MeasureAbbrev
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @FromMeasureSetID
			WHERE	MX.Abbrev IN (SELECT DISTINCT MetricAbbrev FROM #MetricResultsKey)
		),
		ToMetrics AS
		(
			SELECT	MX.*, MM.Abbrev AS MeasureAbbrev
			FROM	Measure.Metrics AS MX
					INNER JOIN Measure.Measures AS MM
							ON MX.MeasureID = MM.MeasureID AND
								MM.MeasureSetID = @ToMeasureSetID
			WHERE	MX.Abbrev IN (SELECT DISTINCT MetricAbbrev FROM #MetricResultsKey)
		)
		SELECT	FMX.MeasureID AS FromMeasureID, FMX.MetricID AS FromMetricID,
				FMX.MeasureAbbrev, FMX.Abbrev AS MetricAbbrev,
				TMX.MeasureID AS ToMeasureID, TMX.MetricID AS ToMetricID
		INTO	#MetricConversionKey
		FROM	FromMetrics AS FMX
				INNER JOIN ToMetrics AS TMX
						ON FMX.Abbrev = TMX.Abbrev AND
							FMX.MeasureAbbrev = TMX.MeasureAbbrev;

		CREATE UNIQUE CLUSTERED INDEX IX_#MetricConversionKey ON #MetricConversionKey (FromMetricID);

		WITH MeasureConversion AS
		(
			SELECT DISTINCT
					FromMeasureID, ToMeasureID
			FROM	#MetricConversionKey
		)
		UPDATE	SSK
		SET		ToMeasureID = MC.ToMeasureID
		FROM	#SysSampleKey AS SSK
				INNER JOIN #MetricConversionKey AS MC
						ON SSK.FromMeasureID = MC.FromMeasureID;

		UPDATE	MRK
		SET		ToMeasureID = MC.ToMeasureID,
				ToMetricID = MC.ToMetricID
		FROM	#MetricResultsKey AS MRK
				INNER JOIN #MetricConversionKey AS MC
						ON MRK.FromMeasureID = MC.FromMeasureID AND
							MRK.FromMetricID = MC.FromMetricID;

		DECLARE @ExclusionTypeF tinyint;
		DECLARE @ExclusionTypeH tinyint;
		DECLARE @ExclusionTypeV tinyint;
		DECLARE @ExclusionTypeX tinyint;
		DECLARE @ExclusionTypeA tinyint;

		SELECT @ExclusionTypeF = ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE Abbrev = 'F';
		SELECT @ExclusionTypeH = ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE Abbrev = 'H';
		SELECT @ExclusionTypeV = ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE Abbrev = 'V';
		SELECT @ExclusionTypeX = ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE Abbrev = 'X';
		SELECT @ExclusionTypeA = ExclusionTypeID FROM Measure.ExclusionTypes WITH(NOLOCK) WHERE Abbrev = 'A';

		UPDATE	#MetricResultsKey
		SET		ExclusionTypeID = CASE 
									WHEN IsSampleVoid = 1 AND ExclusionReason LIKE '%valid data error%' 
									THEN @ExclusionTypeV
									WHEN IsSampleVoid = 1 AND ExclusionReason LIKE '%employee%'
									THEN @ExclusionTypeH
									WHEN (IsSampleVoid = 1 OR IsExclusion = 1) AND ExclusionReason LIKE '%false positive diagnosis%'
									THEN @ExclusionTypeF
									WHEN (IsSampleVoid = 1 OR IsExclusion = 1) AND ExclusionReason LIKE '%administrative data refresh%'
									THEN @ExclusionTypeA
									ELSE @ExclusionTypeX
									END,
				IsExclusion = 1
		WHERE	(IsExclusion = 1) OR
				(IsSampleVoid = 1);

		--4) Apply administrative hits from new "To" data set (for applying Final vs. Preliminary admin scoring)...
		IF (@FromDataRunID <> @ToDataRunID)
			BEGIN;
				DECLARE @CountAdminUpdates int;
			
				WITH MetricResults AS
				(
					SELECT	RMD.Age,
							RMD.AgeMonths,
							RMD.AgeBandID,
							RMD.AgeBandSegID,
							RMD.BatchID,
							RMD.BeginDate,
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
							0 AS IsInverse,
							RMD.IsNumerator,
							RMD.IsNumeratorAdmin,
							RMD.IsNumeratorMedRcd,
							RMD.KeyDate,
							MM.Abbrev AS MeasureAbbrev,
							RMD.MeasureID,
							MX.Abbrev AS MetricAbbrev,
							RMD.MetricID,
							RMD.PayerID,
							RMD.PopulationID,
							RMD.ProductLineID,
							RMD.Qty,
							RMD.ResultRowID,
							RRT.Abbrev AS ResultType,
							RMD.ResultTypeID,
							RMD.SourceDenominator,
							RMD.SourceExclusion,
							RMD.SourceIndicator,
							RMD.SourceNumerator,
							RMD.SysSampleRefID,
							RMD.[Weight]
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN Measure.Metrics AS MX
									ON RMD.MetricID = MX.MetricID
							INNER JOIN Measure.Measures AS MM
									ON MX.MeasureID = MM.MeasureID AND 
										MM.IsHybrid = 1
							INNER JOIN Result.ResultTypes AS RRT
									ON RMD.ResultTypeID = RRT.ResultTypeID AND
										RRT.Abbrev NOT IN ('H', 'M')
					WHERE	(RMD.DataRunID = @ToDataRunID) AND
							(MM.MeasureSetID = @ToMeasureSetID)
				)		
				UPDATE	MRK
				SET		HasAdminUpdates = CASE WHEN MRK.IsNumeratorAdmin <> t.IsNumerator THEN 1 ELSE 0 END,
						IsNumeratorAdmin = t.IsNumerator,
						IsNumerator = CASE 
											--"Normally-scored" Metrics
											WHEN t.IsInverse = 0 AND t.IsNumerator = 1
											THEN 1
											--Inversely-scored Metrics (such as HbA1c Poor Control > 9)
											WHEN t.IsInverse = 1 AND T.IsNumerator = 0 
											THEN 0
											ELSE MRK.IsNumerator
											END
				FROM	#MetricResultsKey AS MRK
						INNER JOIN MetricResults AS t
								ON MRK.ToDSMemberID = t.DSMemberID AND
									MRK.ToMeasureID = t.MeasureID AND
									MRK.ToMetricID = t.MetricID
				WHERE	((MRK.KeyDate IS NULL) OR (MRK.KeyDate = t.KeyDate)) AND
						(MRK.ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE (Abbrev IN ('H'))));
				
				SET @CountAdminUpdates = @@ROWCOUNT;
				
				PRINT ' * Administrative Data Numerator Changes: ' + CONVERT(varchar(256), @CountAdminUpdates);
			END;
		
		--5) Remove medical record compliance flags that were already compliant administratively, or are not really hybrid hits...
		UPDATE	MRK
		SET		IsNumeratorMedRcd = 0
		FROM	#MetricResultsKey AS MRK
		WHERE	(MRK.IsNumeratorAdmin = 1) OR
				(MRK.IsNumerator = 0); --Added 5/10/2013 to prevent against seemingly contradictory results from ChartNet's scoring of HbA1c and LDL-C metrics.
			
		UPDATE	MRK
		SET		IsNumerator = IsNumeratorMedRcd
		FROM	#MetricResultsKey AS MRK
		WHERE	(MRK.ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE (Abbrev IN ('M'))));	
					
		--6) Populate the final results in the "To" data set...
		DECLARE @CountChanged bigint;
		DECLARE @HasRecords bit;

		PRINT '';

		IF EXISTS (
						SELECT TOP 1 
								1 
						FROM	Result.MeasureDetail 
						WHERE	(DataRunID = @ToDataRunID) AND 
								(ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE Abbrev IN ('H','M')))
					) OR
			EXISTS (
						SELECT TOP 1
								1
						FROM	Result.SystematicSamples
						WHERE	(DataRunID = @ToDataRunID)
			
					)
					
			SET @HasRecords = 1;
		ELSE
			SET @HasRecords = 0;

		IF @Ansi_Warnings = 1
			SET ANSI_WARNINGS ON;

		IF @HasRecords = 1 AND @FromDataRunID = @ToDataRunID --Refresh of existing data run's medical record and hybrid results
			BEGIN;
			
				PRINT 'Refreshing medical record and hybrid results...';
				
				--SELECT t.* FROM #SysSampleKey AS t INNER JOIN Result.DataSetMemberKey AS RDSMK ON t.ToDSMemberID = RDSMK.DSMemberID AND RDSMK.DataRunID = @ToDataRunID WHERE RDSMK.CustomerMemberID = 'ICO_1050410'
				--SELECT t.* FROM #MetricResultsKey AS t INNER JOIN Result.DataSetMemberKey AS RDSMK ON t.ToDSMemberID = RDSMK.DSMemberID AND RDSMK.DataRunID = @ToDataRunID WHERE RDSMK.CustomerMemberID = 'ICO_1050410'

				UPDATE	RMD
				SET		ExclusionTypeID = MRK.ExclusionTypeID,
						IsDenominator = CASE WHEN MRK.IsIndicator = 1 THEN 0 ELSE MRK.IsDenominator END,
						IsExclusion = MRK.IsExclusion,
						IsIndicator = MRK.IsIndicator,
						IsNumerator = MRK.IsNumerator,
						IsNumeratorAdmin = MRK.IsNumeratorAdmin,
						IsNumeratorMedRcd = MRK.IsNumeratorMedRcd
				FROM	Result.MeasureDetail AS RMD
						INNER JOIN #MetricResultsKey AS MRK
								ON RMD.DSMemberID = MRK.FromDSMemberID AND
									RMD.MeasureID = MRK.FromMeasureID AND
									RMD.MetricID = MRK.FromMetricID AND
									RMD.ResultRowID = MRK.FromResultRowID AND
									RMD.ResultTypeID = MRK.ResultTypeID
				WHERE	(RMD.DataRunID = @FromDataRunID) AND
						(RMD.DataRunID = @ToDataRunID) AND
						(
							(COALESCE(RMD.ExclusionTypeID, -1) <> COALESCE(MRK.ExclusionTypeID, -1)) OR
							(COALESCE(RMD.IsDenominator, -1) <> COALESCE(MRK.IsDenominator, -1)) OR
							(COALESCE(RMD.IsExclusion, -1) <> COALESCE(MRK.IsExclusion, -1)) OR
							(COALESCE(RMD.IsIndicator, -1) <> COALESCE(MRK.IsIndicator, -1)) OR                          
							(COALESCE(RMD.IsNumerator, -1) <> COALESCE(MRK.IsNumerator, -1)) OR
							(COALESCE(RMD.IsNumeratorAdmin, -1) <> COALESCE(MRK.IsNumeratorAdmin, -1)) OR
							(COALESCE(RMD.IsNumeratorMedRcd, -1) <> COALESCE(MRK.IsNumeratorMedRcd, -1)) OR 1 = 1
						);
						
				SET @CountChanged = @@ROWCOUNT;
			END;
		ELSE IF @HasRecords = 0 AND @FromDataRunID <> @ToDataRunID --Copy of previous data run's medical record and hybrid results
			BEGIN;
				
				PRINT 'Applying medical record and hybrid results...';
				
				BEGIN TRANSACTION T1;
				
				DELETE FROM Batch.SystematicSamples WHERE DataRunID = @ToDataRunID;
				
				IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.SystematicSamples)
					TRUNCATE TABLE Batch.SystematicSamples;
				
				WITH MeasureConversion AS
				(
					SELECT DISTINCT
							FromMeasureID, ToMeasureID
					FROM	#MetricConversionKey
				)
				INSERT INTO Batch.SystematicSamples 
						(BitProductLines,
						DataRunID,
						IsSysSampleAscending,
						MeasureID,
						PayerID,
						PopulationID,
						ProductClassID,
						ProductLineID,
						SysSampleGuid,
						SysSampleRand,
						SysSampleRate,
						SysSampleSize)
				SELECT	BSS.BitProductLines,
						@ToDataRunID AS DataRunID,
						BSS.IsSysSampleAscending,
						MC.ToMeasureID AS MeasureID,
						BSS.PayerID,
						BSS.PopulationID,
						BSS.ProductClassID,
						BSS.ProductLineID,
						GK.ToGuid AS SysSampleGuid,
						BSS.SysSampleRand,
						BSS.SysSampleRate,
						BSS.SysSampleSize
				FROM	Batch.SystematicSamples AS BSS
						INNER JOIN MeasureConversion AS MC
								ON BSS.MeasureID = MC.FromMeasureID
						INNER JOIN #GuidKey AS GK
								ON BSS.SysSampleGuid = GK.FromGuid
				WHERE	(BSS.DataRunID = @FromDataRunID)
				ORDER BY BSS.SysSampleID;
				
				COMMIT TRANSACTION T1;
				
				UPDATE	SSK
				SET		ToSysSampleID = BSS.SysSampleID
				FROM	#SysSampleKey AS SSK
						INNER JOIN Batch.SystematicSamples AS BSS
								ON SSK.SysSampleGuid = BSS.SysSampleGuid
				WHERE	(BSS.DataRunID = @ToDataRunID);
				
				UPDATE	MRK
				SET		ToSysSampleID = SSK.ToSysSampleID
				FROM	#MetricResultsKey AS MRK
						INNER JOIN #SysSampleKey AS SSK
								ON MRK.SysSampleKeyRowID = SSK.RowID;
								
				INSERT INTO Result.SystematicSamples 
						(DataRunID,
						DataSetID,
						DSMemberID,
						IsAuxiliary,
						KeyDate,
						SysSampleID,
						SysSampleOrder,
						ResultRowGuid)
				SELECT	@ToDataRunID AS DataRunID,
						@ToDataSetID AS DataSetID,
						SSK.ToDSMemberID AS DSMemberID,
						RSS.IsAuxiliary,
						RSS.KeyDate,
						SSK.ToSysSampleID AS SysSampleID,
						RSS.SysSampleOrder,
						SSK.SysSampleRefGuid
				FROM	Result.SystematicSamples AS RSS
						INNER JOIN #SysSampleKey AS SSK
								ON RSS.DSMemberID = SSK.FromDSMemberID AND
									RSS.SysSampleID = SSK.FromSysSampleID AND
									RSS.SysSampleRefID = SSK.FromSysSampleRefID
				WHERE	(RSS.DataRunID = @FromDataRunID);		

				UPDATE	MRK
				SET		ToSysSampleRefID = RSS.SysSampleRefID
				FROM	#MetricResultsKey AS MRK
						INNER JOIN Result.SystematicSamples AS RSS
								ON MRK.SysSampleRefGuid = RSS.SysSampleRefGuid
				WHERE	(RSS.DataRunID = @ToDataRunID);
				
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
						Qty2,
						Qty3,
						Qty4,
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
						-1 AS BatchID,
						RMD.BeginDate,
						RMD.BitProductLines,
						RMD.ClinCondID,
						@ToDataRunID AS DataRunID,
						@ToDataSetID AS DataSetID,
						RMD.[Days],
						NULL AS DSEntityID,
						MRK.ToDSMemberID AS DSMemberID,
						NULL AS DSProviderID,
						RMD.EndDate,
						RMD.EnrollGroupID,
						NULL AS EntityID,
						MRK.ExclusionTypeID,
						RMD.Gender,
						CASE WHEN MRK.IsIndicator = 1 THEN 0 ELSE MRK.IsDenominator END AS IsDenominator,
						MRK.IsExclusion,
						MRK.IsIndicator,
						MRK.IsNumerator,
						MRK.IsNumeratorAdmin,
						MRK.IsNumeratorMedRcd,
						RMD.IsSupplementalDenominator,
						RMD.IsSupplementalExclusion,
						RMD.IsSupplementalIndicator,
						RMD.IsSupplementalNumerator,
						RMD.KeyDate,
						MRK.ToMeasureID AS MeasureID,
						RMD.MeasureXrefID,
						MRK.ToMetricID AS MetricID,
						RMD.MetricXrefID,
						RMD.PayerID,
						RMD.PopulationID,
						RMD.ProductLineID,
						RMD.Qty,
						RMD.Qty2,
						RMD.Qty3,
						RMD.Qty4,
						RMD.ResultTypeID,
						RMD.SourceDenominator,
						RMD.SourceDenominatorSrc,
						RMD.SourceExclusion,
						RMD.SourceExclusionSrc,
						RMD.SourceIndicator,
						RMD.SourceIndicatorSrc,
						RMD.SourceNumerator,
						RMD.SourceNumeratorSrc,
						MRK.ToSysSampleRefID,
						RMD.[Weight]
				FROM	Result.MeasureDetail AS RMD
						INNER JOIN #MetricResultsKey AS MRK
								ON RMD.DSMemberID = MRK.FromDSMemberID AND
									RMD.MeasureID = MRK.FromMeasureID AND
									RMD.MetricID = MRK.FromMetricID AND
									RMD.ResultRowID = MRK.FromResultRowID AND
									RMD.ResultTypeID = MRK.ResultTypeID
				WHERE	(RMD.DataRunID = @FromDataRunID);
				
				SET @CountChanged = @@ROWCOUNT;
				
				UPDATE	Result.DataSetRunKey
				SET		AllowAutoRefresh = 1
				WHERE	DataRunID = @ToDataRunID;
				
				EXEC ChartNet.UpdateResultSources @FromDataRunID = @FromDataRunID, @ToDataRunID = @ToDataRunID;
			END;
		ELSE --Protect against unintended overwrite of existing data
			BEGIN;
				SET @Message = 'Cannot perform update.  The specified data run has existing medical record and/or hybrid results.';
				
				RAISERROR(@Message, @Severity, @State);
			END;
		
		IF ISNULL(@CountChanged, 0) > 0	
			BEGIN;
				ALTER INDEX ALL ON Result.MeasureDetail REBUILD;
				
				EXEC Result.SummarizeMeasureDetail @DataRunID = @ToDataRunID;
				EXEC Result.SummarizeMeasureProviderDetail @DataRunID = @ToDataRunID;
				
				EXEC Result.SummarizeMeasureByAgeBand @DataRunID = @ToDataRunID;
			END;
		
		PRINT '   ...Completed (' + CONVERT(varchar(max), ISNULL(@CountChanged, 0)) + ' row(s) affected).';
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(max);
		DECLARE @ErrSv int;
		DECLARE @ErrSt int;
		
		SET @ErrMsg = ERROR_MESSAGE();
		SET @ErrSv = ERROR_SEVERITY();
		SET @ErrSt = ERROR_STATE();
		
		RAISERROR(@ErrMsg, @ErrSv, @ErrSt);
	END CATCH;

	RETURN 0;
END
GO
GRANT EXECUTE ON  [ChartNet].[RefreshResults] TO [Processor]
GO
