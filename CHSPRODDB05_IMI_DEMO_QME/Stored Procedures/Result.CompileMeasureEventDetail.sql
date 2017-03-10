SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/9/2012
-- Description:	Compiles the event/claim-level detail from multiple sources.
-- =============================================
CREATE PROCEDURE [Result].[CompileMeasureEventDetail]
(
	@BatchID int = NULL,
	@CountRecords int = NULL OUTPUT,
	@DataRunID int,
	@IsLogged bit = 1
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

	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileMeasureEventDetail'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			
			SELECT TOP 1	
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;
			
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E'; --Encounter
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L'; --Lab
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P'; --Pharmacy

			DECLARE @DateCompTypeE tinyint; --Entity
			DECLARE @DateCompTypeN tinyint; --Enrollment
			DECLARE @DateCompTypeS tinyint; --Seed Date
			DECLARE @DateCompTypeV tinyint; --Event
			DECLARE @DateCompTypeM tinyint; --Member Demographics

			SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
			SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
			SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
			SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
			SELECT @DateCompTypeM = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'M';

			--------------------------------------------------------------------------------------------------------------------------

			--#DSEntityKey: Base table to store Metric/Key (Event) Date/Entity keys, used to identify the originating EntityBase records...
			IF OBJECT_ID('tempdb..#DSEntityKey') IS NOT NULL
				DROP TABLE #DSEntityKey;

			CREATE TABLE #DSEntityKey
			(
				[@i] tinyint NOT NULL,
				BatchID int NOT NULL,
				DSMemberID bigint NULL,
				DSEntityID bigint NOT NULL,
				EntityBaseID bigint NULL,
				EntityID int NULL,
				Iteration tinyint NULL,
				KeyDate datetime NOT NULL,
				MetricID int NOT NULL,
				OrigDSEntityID bigint NULL,
				OrigEntityID int NULL,
				RowID bigint IDENTITY(1, 1) NOT NULL
			);

			--#EntityBaseKey: Base table to store EntityBase-level keys, used to identify the underlying events...
			IF OBJECT_ID('tempdb..#EntityBaseKey') IS NOT NULL	
				DROP TABLE #EntityBaseKey;

			CREATE TABLE #EntityBaseKey
			(
				[@i] tinyint NOT NULL,
				AllowActiveScript bit NOT NULL,
				AllowBeginDate bit NOT NULL,
				AllowEndDate bit NOT NULL,
				AllowServDate bit NOT NULL,
				BatchID int NOT NULL,
				DateComparerID smallint NOT NULL,
				DateComparerInfo int NOT NULL,
				DateCompTypeID tinyint NULL,
				DSEntityID bigint NOT NULL,
				DSMemberID bigint NOT NULL,
				EntityBeginDate datetime NOT NULL,
				EntityBaseID bigint NOT NULL,
				EntityEndDate datetime NOT NULL,
				EntityID int NOT NULL,
				EventBaseID bigint NULL,
				Iteration tinyint NOT NULL,
				KeyDate datetime NOT NULL,
				MetricID int NOT NULL,
				OrigDSEntityID bigint NULL,
				OrigEntityID int NULL,
				QtyComparerID tinyint NULL,
				Qty smallint NOT NULL,
				RowID bigint IDENTITY(1, 1) NOT NULL,
				SourceID bigint NULL,
				SourceLinkID bigint NULL,
				SourceRowID bigint NOT NULL
			);

			--PRINT 'i) ' + CONVERT(varchar(128), GETDATE(), 109)
			--i) Populate initial #DSEntityKey values...
			INSERT INTO #DSEntityKey
					([@i],
					BatchID,
					DSEntityID,
					KeyDate,
					MetricID)
			SELECT DISTINCT
					0 AS [@i], RMD.BatchID, RMD.DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.DSEntityID IS NOT NULL) AND
					((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			UNION 
			SELECT DISTINCT
					0 AS [@i], 
					RMD.BatchID, RMD.SourceDenominator AS DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.SourceDenominator IS NOT NULL) AND
					((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			UNION 
			SELECT DISTINCT
					0 AS [@i], 
					RMD.BatchID, RMD.SourceExclusion AS DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.SourceExclusion IS NOT NULL) AND
					((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			UNION
			SELECT DISTINCT
					0 AS [@i], 
					RMD.BatchID, RMD.SourceIndicator AS DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.SourceIndicator IS NOT NULL) AND
					((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			UNION 
			SELECT DISTINCT
					0 AS [@i], 
					RMD.BatchID, RMD.SourceNumerator AS DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
			WHERE	(RMD.SourceNumerator IS NOT NULL) AND
					((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			UNION
			SELECT DISTINCT
					0 AS [@i], 
					LE.BatchID, LE.DSEntityID,
					ISNULL(LE.EndDate, LE.BeginDate) AS KeyDate, METMM.MetricID
			FROM	Log.Entities AS LE
					INNER JOIN Measure.Entities AS ME
							ON ME.EntityID = LE.EntityID
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON METMM.EntityID = LE.EntityID
					INNER JOIN Measure.MappingTypes AS MMT
							ON MMT.MapTypeID = METMM.MapTypeID AND
								MMT.MapTypeGuid = '94E8A1C2-CDEA-4BA8-A00B-1AEF4835D40B' --Component
			WHERE	((@BatchID IS NULL) OR (LE.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (LE.DataRunID = @DataRunID))
			UNION
			SELECT DISTINCT
					0 AS [@i], 
					RMD.BatchID, LE.DSEntityID AS DSEntityID,
					RMD.KeyDate, RMD.MetricID
			FROM	Result.MeasureDetail AS RMD
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON RMD.EntityID = METMM.EntityID AND
								RMD.MetricID = METMM.MetricID AND
								METMM.MapTypeID IN (SELECT MapTypeID FROM Measure.MappingTypes WHERE IsCounter = 1)
					INNER JOIN [Log].[Entities] AS LE
							ON RMD.EntityID = LE.EntityID AND
								METMM.EntityID = LE.EntityID AND
								RMD.DSEntityID <> LE.DSEntityID AND
								RMD.DSMemberID = LE.DSMemberID AND
								ISNULL(LE.EndDate, LE.BeginDate) BETWEEN RMD.BeginDate AND RMD.EndDate
			WHERE	((@BatchID IS NULL) OR (RMD.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (RMD.DataRunID = @DataRunID))
			OPTION (RECOMPILE);

			DECLARE @i tinyint;
			DECLARE @CountInternal bigint;

			--1) Identify EntityBase-level key values, looping through child Entities to identify all involved EntityBase-level records...
			WHILE (1 = 1)
				BEGIN		
					SET @i = ISNULL(@i, 0) + 1;
						
					CREATE UNIQUE CLUSTERED INDEX IX_#DSEntityKey ON #DSEntityKey (DSEntityID, MetricID, KeyDate, BatchID);
							
					--PRINT '1a) ' + CONVERT(varchar(128), GETDATE(), 109)
					--1a) Populate missing values in #DSEntityKey...
					UPDATE	DL
					SET		DSMemberID = LE.DSMemberID,
							EntityBaseID = LE.EntityBaseID,
							EntityID = LE.EntityID,
							Iteration = LE.Iteration
					FROM	[Log].Entities AS LE
							INNER JOIN #DSEntityKey AS DL
									ON LE.BatchID = DL.BatchID AND
										LE.DSEntityID = DL.DSEntityID
					WHERE	(DL.EntityBaseID IS NULL);

					DROP INDEX IX_#DSEntityKey ON #DSEntityKey;

					DELETE FROM #DSEntityKey WHERE DSMemberID IS NULL;

					CREATE UNIQUE CLUSTERED INDEX IX_#DSEntityKey ON #DSEntityKey (EntityBaseID, DSMemberID, Iteration, MetricID, KeyDate, EntityID, BatchID, DSEntityID);

					--PRINT '1b) ' + CONVERT(varchar(128), GETDATE(), 109)
					--1b) Identity new EntityBase-level key records for this iteration of the loop.
					INSERT INTO #EntityBaseKey
							([@i],
							AllowActiveScript,
							AllowBeginDate,
							AllowEndDate,
							AllowServDate,
							BatchID,
							DateComparerID,
							DateComparerInfo,
							DateCompTypeID,
							DSEntityID,
							DSMemberID,
							EntityBeginDate,
							EntityBaseID,
							EntityEndDate,
							EntityID,
							Iteration,
							KeyDate,
							MetricID,
							OrigDSEntityID,
							OrigEntityID,
							QtyComparerID,
							Qty,
							SourceID,
							SourceLinkID,
							SourceRowID)
					SELECT	@i AS [@i], --tinyint
							MEC.AllowActiveScript,
							MEC.AllowBeginDate, --bit
							MEC.AllowEndDate, --bit
							MEC.AllowServDate, --bit
							DL.BatchID, --int
							LEB.DateComparerID, --smallint
							LEB.DateComparerInfo, --int
							MDC.DateCompTypeID, --tinyint
							DL.DSEntityID, --bigint
							DL.DSMemberID, --bigint
							LEB.EntityBeginDate, --datetime
							DL.EntityBaseID, --bigint
							LEB.EntityEndDate, --datetime
							DL.EntityID, --int
							DL.Iteration, --tinyint
							DL.KeyDate, --datetime
							DL.MetricID, --int
							DL.OrigDSEntityID, --bigint
							DL.OrigEntityID, --int
							MEC.QtyComparerID, --tinyint
							LEB.Qty, --smallint
							LEB.SourceID, --bigint
							LEB.SourceLinkID, --bigint
							DL.RowID AS SourceRowID --bigint
					FROM	Log.EntityBase AS LEB
							INNER JOIN #DSEntityKey AS DL
									ON LEB.BatchID = DL.BatchID AND
										LEB.DSMemberID = DL.DSMemberID AND
										LEB.EntityBaseID = DL.EntityBaseID AND
										LEB.EntityID = DL.EntityID AND
										LEB.Iteration = DL.Iteration AND
										LEB.Allow = 1
							INNER JOIN Measure.EntityCriteria AS MEC
									ON LEB.EntityCritID = MEC.EntityCritID AND
										LEB.EntityID = MEC.EntityID
							INNER JOIN Measure.DateComparers AS MDC
									ON LEB.DateComparerID = MDC.DateComparerID
					WHERE	(DL.[@i] = (@i - 1));
					
					CREATE UNIQUE CLUSTERED INDEX IX_#EntityBaseKey ON #EntityBaseKey (DSMemberID, BatchID, KeyDate, RowID);
									
					DROP INDEX IX_#DSEntityKey ON #DSEntityKey;
					
					CREATE UNIQUE CLUSTERED INDEX IX_#DSEntityKey ON #DSEntityKey (DSEntityID, MetricID, KeyDate, BatchID);
							
					--PRINT '1c) ' + CONVERT(varchar(128), GETDATE(), 109)		
					--1c) Identify child-Entities of the current EntityBase-level records...
					--Entity Sources *Without* QuantityComparers
					INSERT INTO #DSEntityKey
							([@i],
							BatchID,
							DSEntityID,
							KeyDate,
							MetricID,
							OrigDSEntityID,
							OrigEntityID)
					SELECT DISTINCT
							@i AS [@i],
							EBL.BatchID,
							EBL.SourceID AS DSEntityID,
							EBL.KeyDate,
							EBL.MetricID,
							ISNULL(EBL.OrigDSEntityID, EBL.DSEntityID) AS OrigDSEntityID,
							ISNULL(EBL.OrigEntityID, EBL.EntityID) AS OrigEntityID
					FROM	#EntityBaseKey AS EBL
							LEFT OUTER JOIN #DSEntityKey AS DL
									ON EBL.BatchID = DL.BatchID AND
										EBL.SourceID = DL.DSEntityID AND
										EBL.KeyDate = DL.KeyDate AND
										EBL.MetricID = DL.MetricID
					WHERE	(EBL.DateCompTypeID = @DateCompTypeE) AND
							(EBL.[@i] = (@i - 1)) AND
							(
								(EBL.Qty = 1) OR
								(EBL.QtyComparerID IS NULL)
							) AND
							(DL.DSEntityID IS NULL)
					UNION 
					--Entity Sources *With* QuantityComparers
					SELECT DISTINCT
							@i AS [@i],
							EBL.BatchID,
							LE.DSEntityID AS DSEntityID,
							EBL.KeyDate,
							EBL.MetricID,
							ISNULL(EBL.OrigDSEntityID, EBL.DSEntityID) AS OrigDSEntityID,
							ISNULL(EBL.OrigEntityID, EBL.EntityID) AS OrigEntityID
					FROM	#EntityBaseKey AS EBL
							INNER JOIN Log.Entities AS LE
									ON EBL.BatchID = LE.BatchID AND
										EBL.DSMemberID = LE.DSMemberID AND
										EBL.DateComparerInfo = LE.EntityID AND
										EBL.Iteration > LE.Iteration AND
										(
											(
												(EBL.AllowBeginDate = 1) AND
												(LE.BeginDate BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
											) OR
											(
												(EBL.AllowEndDate = 1) AND
												(LE.EndDate BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
											) OR
											(
												(EBL.AllowServDate = 1) AND
												(ISNULL(LE.EndDate, LE.BeginDate) BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
											)
										)
							LEFT OUTER JOIN #DSEntityKey AS DL
									ON EBL.BatchID = DL.BatchID AND
										LE.DSEntityID = DL.DSEntityID AND
										EBL.KeyDate = DL.KeyDate AND
										EBL.MetricID = DL.MetricID
					WHERE	(EBL.DateCompTypeID = @DateCompTypeE) AND
							(EBL.[@i] = (@i - 1)) AND
							(EBL.QtyComparerID IS NOT NULL) AND
							(EBL.Qty > 1) AND
							(DL.DSEntityID IS NULL)
					UNION 
					--Linked Entity Sources
					SELECT DISTINCT
							@i AS [@i],
							EBL.BatchID,
							EBL.SourceLinkID AS DSEntityID,
							EBL.KeyDate,
							EBL.MetricID,
							ISNULL(EBL.OrigDSEntityID, EBL.DSEntityID) AS OrigDSEntityID,
							ISNULL(EBL.OrigEntityID, EBL.EntityID) AS OrigEntityID
					FROM	#EntityBaseKey AS EBL
							LEFT OUTER JOIN #DSEntityKey AS DL
									ON EBL.BatchID = DL.BatchID AND
										EBL.SourceLinkID = DL.DSEntityID AND
										EBL.KeyDate = DL.KeyDate AND
										EBL.MetricID = DL.MetricID
					WHERE	(EBL.SourceLinkID IS NOT NULL) AND
							(EBL.DateCompTypeID IN (@DateCompTypeE, @DateCompTypeV)) AND
							(EBL.[@i] = (@i - 1)) AND
							(DL.DSEntityID IS NULL);
							
					SET @CountInternal = @@ROWCOUNT;
							
					DROP INDEX IX_#EntityBaseKey ON #EntityBaseKey; 
									
					DROP INDEX IX_#DSEntityKey ON #DSEntityKey;
							
					IF @CountInternal = 0 OR @i = 255		
						BREAK;
				END;
				
			DELETE FROM #EntityBaseKey WHERE DateCompTypeID = @DateCompTypeE;
				
			CREATE UNIQUE CLUSTERED INDEX IX_#EntityBaseKey ON #EntityBaseKey (SourceID, DateComparerInfo, DSMemberID, BatchID, RowID);
				
			IF OBJECT_ID('tempdb..#Detail') IS NOT NULL
				DROP TABLE #Detail;
				
			--PRINT '2a) ' + CONVERT(varchar(128), GETDATE(), 109)
			--2a) Convert the SourceID/DSEventID to EventBaseID/EventBaseID associated with all events...
			UPDATE	EBL
			SET		EventBaseID = LV.EventBaseID
			FROM	#EntityBaseKey AS EBL
					INNER JOIN [Log].[Events] AS LV
							ON EBL.BatchID = LV.BatchID AND
								EBL.DateComparerInfo = LV.EventID AND
								EBL.DSMemberID = LV.DSMemberID AND
								EBL.SourceID = LV.DSEventID
			WHERE	(EBL.DateCompTypeID = @DateCompTypeV);
				
			--PRINT '2b) ' + CONVERT(varchar(128), GETDATE(), 109)
			--2b) Insert additional key records for events of entites with quantity comparers...
			INSERT INTO #EntityBaseKey
					([@i],
					AllowActiveScript,
					AllowBeginDate,
					AllowEndDate,
					AllowServDate,
					BatchID,
					DateComparerID,
					DateComparerInfo,
					DateCompTypeID,
					DSEntityID,
					DSMemberID,
					EntityBeginDate,
					EntityBaseID,
					EntityEndDate,
					EntityID,
					EventBaseID,
					Iteration,
					KeyDate,
					MetricID,
					OrigDSEntityID,
					OrigEntityID,
					QtyComparerID,
					Qty,
					SourceID,
					SourceLinkID,
					SourceRowID)
			SELECT DISTINCT
					EBL.[@i],
					EBL.AllowActiveScript,
					EBL.AllowBeginDate,
					EBL.AllowEndDate,
					EBL.AllowServDate,
					EBL.BatchID,
					EBL.DateComparerID,
					EBL.DateComparerInfo,
					EBL.DateCompTypeID,
					EBL.DSEntityID,
					EBL.DSMemberID,
					EBL.EntityBeginDate,
					EBL.EntityBaseID,
					EBL.EntityEndDate,
					EBL.EntityID,
					LV.EventBaseID,
					EBL.Iteration,
					EBL.KeyDate,
					EBL.MetricID,
					EBL.OrigDSEntityID,
					EBL.OrigEntityID,
					EBL.QtyComparerID,
					EBL.Qty,
					LV.DSEventID AS SourceID,
					EBL.SourceLinkID,
					EBL.SourceRowID
			FROM	#EntityBaseKey AS EBL
					INNER JOIN [Log].[Events] AS LV
							ON EBL.BatchID = LV.BatchID AND
								EBL.DateComparerInfo = LV.EventID AND
								EBL.DSMemberID = LV.DSMemberID AND
								EBL.SourceID <> LV.DSEventID AND
								(
									(
										(EBL.AllowBeginDate = 1) AND
										(LV.BeginDate BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
									) OR
									(
										(EBL.AllowEndDate = 1) AND
										(LV.EndDate BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
									) OR
									(
										(EBL.AllowServDate = 1) AND
										(ISNULL(LV.EndDate, LV.BeginDate) BETWEEN EBL.EntityBeginDate AND EBL.EntityEndDate)
									) OR
									/*Pharmacy Active Script Date Criteria*/
									(	
										(EBL.AllowActiveScript = 1) AND 
										(LV.EndOrigDate IS NOT NULL) AND
										(EBL.EntityBeginDate > LV.BeginDate) AND
										(EBL.EntityBeginDate BETWEEN LV.BeginDate AND LV.EndOrigDate)
									)
								)
			WHERE	(EBL.DateCompTypeID = @DateCompTypeV) AND
					(EBL.QtyComparerID IS NOT NULL) AND
					(EBL.Qty > 1);
				
			DROP INDEX IX_#EntityBaseKey ON #EntityBaseKey; 
				
			CREATE UNIQUE CLUSTERED INDEX IX_#EntityBaseKey ON #EntityBaseKey (EventBaseID, DSMemberID, BatchID, RowID);

			DECLARE @CloseTag varchar(16);	
			DECLARE @OpenTag varchar(16);

			SET @CloseTag = '</ b>';
			SET @OpenTag = '<b>';

			--PRINT '3) ' + CONVERT(varchar(128), GETDATE(), 109)
			--3) Refresh the Measure Event Detail with the identified events...
			DECLARE @ResultTypeID tinyint;
			SELECT @ResultTypeID = ResultTypeID FROM Result.ResultTypes WHERE (Abbrev = 'A');

			DELETE FROM Result.MeasureEventDetail WHERE ((@BatchID IS NULL) OR (BatchID = @BatchID)) AND ((@DataRunID IS NULL) OR (DataRunID = @DataRunID)) AND (ResultTypeID = @ResultTypeID);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureEventDetail)
				TRUNCATE TABLE Result.MeasureEventDetail;

			IF OBJECT_ID('tempdb..#EventDetail') IS NOT NULL
				DROP TABLE #EventDetail;

			--Create the Code Key (used in 3a)...
			SELECT	CC.Code,
					CC.CodeID,
					CCT.Descr AS CodeType,
					CC.CodeTypeID
			INTO	#Codes 
			FROM	Claim.Codes AS CC
					INNER JOIN Claim.CodeTypes AS CCT
							ON CC.CodeTypeID = CCT.CodeTypeID;
							
			CREATE UNIQUE CLUSTERED INDEX IX_#Codes ON #Codes (CodeID);
							
			--Create the EventBase Key (used in 3a)...
			SELECT DISTINCT
					EBL.BatchID,
					LV.BeginDate,
					CONVERT(nvarchar(32), NULL) AS ClaimNum,
					LV.ClaimTypeID,
					LV.CodeID,
					LV.DataSourceID,
					EBL.DateCompTypeID,
					LV.[Days],
					LV.DSClaimLineID,
					EBL.DSEntityID, 
					EBL.SourceID AS DSEventID,
					EBL.DSMemberID,
					LV.DSProviderID,
					LV.EndDate,
					EBL.EntityID, 
					LV.EventBaseID,
					LV.EventCritID,
					LV.EventID,
					CONVERT(bit, NULL) AS IsOnly,
					CONVERT(bit, NULL) AS IsPrimary,
					LV.IsSupplemental,
					EBL.Iteration,
					EBL.KeyDate, 
					EBL.MetricID,
					EBL.OrigEntityID, 
					IDENTITY(bigint, 1, 1) AS RowID,
					ISNULL(LV.EndDate, LV.BeginDate) AS ServDate
			INTO	#EventBaseKey
			FROM	[Log].[EventBase] AS LV
					INNER JOIN #EntityBaseKey AS EBL
							ON LV.BatchID = EBL.BatchID AND
								LV.DataRunID = @DataRunID AND
								LV.EventBaseID = EBL.EventBaseID AND
								LV.EventID = EBL.DateComparerInfo
			WHERE	(EBL.DateCompTypeID = @DateCompTypeV) AND
					(LV.Allow = 1);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventBaseKey ON #EventBaseKey (DSClaimLineID, RowID);
			
			--Populate the empty Claim Number field...
			UPDATE	VBK
			SET		ClaimNum = CCL.ClaimNum
			FROM	#EventBaseKey AS VBK
					INNER JOIN Claim.ClaimLines AS CCL
							ON VBK.DSClaimLineID = CCL.DSClaimLineID
			WHERE	(CCL.DataSetID = @DataSetID);

			--Populate the empty Event Criteria-related fields...
			UPDATE	VBK
			SET		IsOnly = MVC.RequireOnly,
					IsPrimary = MVC.RequirePrimary
			FROM	#EventBaseKey AS VBK
					INNER JOIN Measure.EventCriteria AS MVC
							ON VBK.EventCritID = MVC.EventCritID;

			--PRINT '3a&b) ' + CONVERT(varchar(128), GETDATE(), 109)
			--3a) Identify claim-level detail from EventBase and ClaimLines...
			SELECT DISTINCT
					VBK.BatchID,
					VBK.BeginDate,
					VBK.ClaimNum,
					VBK.ClaimTypeID,
					CC.Code,
					VBK.CodeID,
					CC.CodeType,
					VBK.DataSourceID,
					VBK.DateCompTypeID,
					CONVERT(nvarchar(2048),
						CASE VBK.ClaimTypeID WHEN @ClaimTypeP THEN 'Pharmacy' WHEN @ClaimTypeL THEN 'Lab' ELSE 'Encounter' END + ' ' +
						'Claim #' + ISNULL(VBK.ClaimNum, '<Unknown>') + 
						ISNULL(' with ' + CASE WHEN VBK.IsOnly = 1 THEN 'only ' ELSE '' END + 'a(n) ' + 
						CASE WHEN VBK.IsPrimary = 1 THEN 'Primary ' ELSE '' END + RTRIM(CC.CodeType) + ' Code of ' + CC.Code, '') + 
						CASE WHEN VBK.EndDate IS NOT NULL AND VBK.ClaimTypeID <> @ClaimTypeP THEN ', admitted' 
							 WHEN VBK.ClaimTypeID = @CLaimTypeP THEN ' dispensed'
							 ELSE '' END + ' on ' + 
						CONVERT(varchar(256), VBK.BeginDate, 101) + 
						ISNULL(' and discharged on ' + CONVERT(varchar(256), CASE WHEN VBK.ClaimTypeID <> @ClaimTypeP THEN VBK.EndDate END, 101), '') + 
						ISNULL(CASE WHEN VBK.ClaimTypeID = @ClaimTypeP THEN ' with a ' + CONVERT(varchar(256), VBK.[Days]) + ' day supply' END, '') +
						'.') AS Descr,
					CONVERT(nvarchar(2048),  
						@OpenTag + CASE VBK.ClaimTypeID WHEN @ClaimTypeP THEN 'Pharmacy' WHEN @ClaimTypeL THEN 'Lab' ELSE 'Encounter' END + ' ' +
						'Claim #' + ISNULL(VBK.ClaimNum, '<Unknown>') + @CloseTag + 
						ISNULL(' with ' + CASE WHEN VBK.IsOnly = 1 THEN @OpenTag + 'only' + @CloseTag + ' ' ELSE '' END + 'a(n) ' + 
						@OpenTag + CASE WHEN VBK.IsPrimary = 1 THEN 'Primary ' ELSE '' END + RTRIM(CC.CodeType) + ' Code' + @CloseTag + ' of ' + @OpenTag + CC.Code + @CloseTag, '') + 
						CASE WHEN VBK.EndDate IS NOT NULL AND VBK.ClaimTypeID <> @ClaimTypeP THEN ', admitted' 
							 WHEN VBK.ClaimTypeID = @CLaimTypeP THEN ' dispensed'
							 ELSE '' END + ' on ' + 
						@OpenTag + CONVERT(varchar(256), VBK.BeginDate, 101) + @CloseTag +
						ISNULL(' and discharged on ' + @OpenTag + CONVERT(varchar(256), CASE WHEN VBK.ClaimTypeID <> @ClaimTypeP THEN VBK.EndDate END, 101) + @CloseTag, '') + 
						ISNULL(CASE WHEN VBK.ClaimTypeID = @ClaimTypeP THEN ' with a ' + @OpenTag + CONVERT(varchar(256), VBK.[Days]) + @CloseTag + ' day supply' END, '') +
						'.') AS DescrHtml, 
					VBK.DSClaimLineID,
					VBK.DSEntityID, 
					VBK.DSEventID,
					VBK.DSMemberID,
					VBK.DSProviderID,
					VBK.EndDate,
					VBK.EntityID, 
					VBK.EventBaseID,
					VBK.EventID,
					VBK.IsSupplemental,
					VBK.Iteration,
					VBK.KeyDate, 
					VBK.MetricID,
					ISNULL(VBK.OrigEntityID, VBK.EntityID) AS RefID,
					ISNULL(CASE WHEN VBK.ClaimTypeID <> @ClaimTypeP THEN VBK.EndDate END, VBK.BeginDate) AS ServDate
			INTO	#EventDetail
			FROM	#EventBaseKey AS VBK
					LEFT OUTER JOIN #Codes AS CC
							ON VBK.CodeID = CC.CodeID
			UNION
			--3b) Compile the non-event-related entries (member demographics only)...
			SELECT DISTINCT
					EBL.BatchID,
					M.DOB AS BeginDate,
					NULL AS ClaimNum,
					NULL AS ClaimTypeID,
					NULL AS Code,
					NULL AS CodeID,
					NULL AS CodeType,
					M.DataSourceID,
					EBL.DateCompTypeID,
					CONVERT(nvarchar(2048),
						CASE M.Gender WHEN 0 THEN 'Female' WHEN 1 THEN 'Male' ELSE 'Unknown Gender' END + 
						' born on ' + CONVERT(varchar(256), M.DOB, 101) + 
						'.') AS Descr, 
					CONVERT(nvarchar(2048),
						@OpenTag + CASE M.Gender WHEN 0 THEN 'Female' WHEN 1 THEN 'Male' ELSE 'Member of unknown gender' END + @CloseTag +
						' born on ' + @OpenTag + CONVERT(varchar(256), M.DOB, 101) + @CloseTag +
						'.') AS DescrHtml, 
					NULL AS DSClaimLineID,
					EBL.DSEntityID, 
					NULL AS  DSEventID,
					EBL.DSMemberID,
					NULL AS DSProviderID,
					M.DOB AS EndDate,
					EBL.EntityID, 
					NULL AS EventBaseID,
					NULL AS EventID,
					0 AS IsSupplemental,
					EBL.Iteration,
					EBL.KeyDate, 
					EBL.MetricID,
					ISNULL(EBL.OrigEntityID, EBL.EntityID) AS RefID,
					M.DOB AS ServDate
			FROM	#EntityBaseKey AS EBL
					INNER JOIN Member.Members AS M
							ON EBL.DSMemberID = M.DSMemberID AND
								M.DataSetID = @DataSetID
			WHERE	(EBL.DateCompTypeID = @DateCompTypeM);

			--PRINT '3c) ' + CONVERT(varchar(128), GETDATE(), 109)
			--3c) Insert the detail into the results table...
			INSERT INTO Result.MeasureEventDetail
					(BatchID,
					BeginDate,
					ClaimNum,
					ClaimTypeID,
					Code,
					CodeID,
					CodeType,
					DataRunID,
					DataSetID,
					DataSourceID,
					Descr,
					DescrHtml,
					DSClaimLineID,
					DSEntityID,
					DSEventID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EntityDescr,
					EntityID,
					EventBaseID,
					EventDescr,
					EventID,
					IsSupplmental,
					Iteration,
					KeyDate,
					--MapTypeDescr,
					MapTypeID,
					MeasureID,
					MetricID,
					ResultTypeID,
					ServDate)
			SELECT	VD.BatchID,
					VD.BeginDate,
					VD.ClaimNum,
					VD.ClaimTypeID,
					VD.Code,
					VD.CodeID,
					VD.CodeType,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					VD.DataSourceID,
					VD.Descr,
					VD.DescrHtml,
					VD.DSClaimLineID,
					VD.DSEntityID,
					VD.DSEventID,
					VD.DSMemberID,
					VD.DSProviderID,
					VD.EndDate,
					ME.Descr AS EntityDescr,
					VD.EntityID,
					VD.EventBaseID,
					ISNULL(MV.Descr, CASE WHEN VD.DateCompTypeID = @DateCompTypeM THEN 'Member Demographics' END) AS EventDescr,
					VD.EventID,
					VD.IsSupplemental,
					VD.Iteration,
					VD.KeyDate,
					--MMT.Descr AS MapTypeDescr,
					METMM.MapTypeID,
					MX.MeasureID,
					VD.MetricID,
					@ResultTypeID AS ResultTypeID,
					VD.ServDate
			FROM	#EventDetail AS VD
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON VD.RefID = METMM.EntityID AND
								VD.MetricID = METMM.MetricID
					--INNER JOIN Measure.MappingTypes AS MMT
					--		ON METMM.MapTypeID = MMT.MapTypeID
					INNER JOIN Measure.Entities AS ME
							ON VD.RefID = ME.EntityID
					INNER JOIN Measure.Metrics AS MX
							ON VD.MetricID = MX.MetricID		
					LEFT OUTER JOIN Measure.[Events] AS MV
							ON VD.EventID = MV.EventID
			ORDER BY DSMemberID, 
					MetricID,
					KeyDate, 
					MapTypeID, 
					ServDate, 
					CodeType,
					Code;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--PRINT 'Done) ' + CONVERT(varchar(128), GETDATE(), 109)
			
			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;
						
			SET @LogDescr = 'Compiling measure claim/event detail completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			IF @IsLogged = 1
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
			SET @LogDescr = 'Compiling measure claim/event detail failed!';
			
			IF @IsLogged = 1
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
GRANT VIEW DEFINITION ON  [Result].[CompileMeasureEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileMeasureEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileMeasureEventDetail] TO [Processor]
GO
