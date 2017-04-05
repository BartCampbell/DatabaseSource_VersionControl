SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/29/2016
-- Description:	Determines the actual quantities for entity criteria. (v5)
-- =============================================
CREATE PROCEDURE [Batch].[QuantifyEntityCriteria_v5]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT,
	@Iteration tinyint
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
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'QuantifyEntityCriteria'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
			
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
		
		----------------------------------------------------------------------------------------------
		IF @BatchID IS NOT NULL AND	@Iteration IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Proxy.EntityBase)
			BEGIN;
				DECLARE @Result int;

				DECLARE @DateCompTypeE tinyint; --Entity
				DECLARE @DateCompTypeN tinyint; --Enrollment
				DECLARE @DateCompTypeS tinyint; --Seed Date
				DECLARE @DateCompTypeV tinyint; --Event
				DECLARE @DateCompTypeM tinyint; --Member/Demographics

				SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
				SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
				SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
				SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
				SELECT @DateCompTypeM = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'M';

				DECLARE @QtyComparerC tinyint;
				DECLARE @QtyComparerD tinyint;
				DECLARE @QtyComparerE tinyint;
				DECLARE @QtyComparerF tinyint;
				DECLARE @QtyComparerG tinyint;
				DECLARE @QtyComparerK tinyint;
				DECLARE @QtyComparerL tinyint;
				DECLARE @QtyComparerP tinyint;
				DECLARE @QtyComparerS tinyint;
				DECLARE @QtyComparerT tinyint;
				DECLARE @QtyComparerU tinyint;
				DECLARE @QtyComparerV tinyint;
				DECLARE @QtyComparerW tinyint;

				SELECT @QtyComparerC = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'C';
				SELECT @QtyComparerD = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'D';
				SELECT @QtyComparerE = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'E';
				SELECT @QtyComparerF = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'F';
				SELECT @QtyComparerG = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'G';
				SELECT @QtyComparerK = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'K';
				SELECT @QtyComparerL = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'L';
				SELECT @QtyComparerP = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'P';
				SELECT @QtyComparerS = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'S';
				SELECT @QtyComparerT = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'T';
				SELECT @QtyComparerU = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'U';
				SELECT @QtyComparerV = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'V';
				SELECT @QtyComparerW = QtyComparerID FROM Measure.QuantityComparers WHERE Abbrev = 'W';
				
				--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
				DECLARE @Ansi_Warnings bit;
				SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS OFF;
				
				--1) Determine future potentially valid entity's as identified by entity base records, 
				--	 ignoring the unknown quantity and enrollment requirements...
				--	 (Step #1's code is adapted from Batch.IdentifyEntityEpisodesForAll)
				WITH EntitiesWithQuantityComparers AS
				(
					SELECT DISTINCT
							MEC.EntityID
					FROM	Measure.EntityCriteria AS MEC
							INNER JOIN Measure.Entities AS M
									ON MEC.EntityID = M.EntityID AND
										M.IsEnabled  = 1 AND
										MEC.IsEnabled = 1 AND
										M.MeasureSetID = @MeasureSetID
					WHERE	(QtyComparerID IS NOT NULL)
				)
				SELECT	COUNT(CASE WHEN Allow = 1 THEN MEC.EntityCritID END) AS CountAllowed,
						COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountAllowedAfterIndex,
						COUNT(CASE WHEN Allow = 1 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountAllowedForIndex,	
						COUNT(MEC.EntityCritID) AS CountCriteria,
						COUNT(CASE WHEN Allow = 0 THEN MEC.EntityCritID END) AS CountDenied,
						COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 0 THEN MEC.EntityCritID END) AS CountDeniedAfterIndex,
						COUNT(CASE WHEN Allow = 0 AND MEC.IsForIndex = 1 THEN MEC.EntityCritID END) AS CountDeniedForIndex,
						MEC.EntityID,
						MEC.OptionNbr
				INTO	#EntityOptions
				FROM	Measure.EntityCriteria AS MEC
						INNER JOIN EntitiesWithQuantityComparers AS t
								ON MEC.EntityID = t.EntityID
				WHERE	MEC.IsEnabled = 1 
				GROUP BY MEC.EntityID, MEC.OptionNbr
				
				CREATE UNIQUE CLUSTERED INDEX IX_EntityOptions ON #EntityOptions (EntityID, OptionNbr);

				SELECT DISTINCT
						TEB.EntityBaseID,
						CAST(CASE 
								WHEN COUNT(DISTINCT CASE WHEN TEB.Allow = 0 AND TEB.IsForIndex = 0 THEN TEB.EntityCritID END) = 0 AND
										COUNT(DISTINCT CASE WHEN TEB.Allow = 1 AND TEB.IsForIndex = 0 THEN TEB.EntityCritID END) = EO.CountAllowedAfterIndex
								THEN 1
								ELSE 0 
								END AS bit) AS IsValid,
						MIN(TEB.SourceLinkID) AS SourceLinkID
				INTO	#PossibleEntities
				FROM	Proxy.EntityBase AS TEB
						INNER JOIN #EntityOptions AS EO
								ON TEB.EntityID = EO.EntityID AND
									TEB.OptionNbr = EO.OptionNbr 
				--Evaluate potential entities as if quantity requirements were met, since qty is calculated in this procedure and is currently unknown
				--WHERE	((TEB.Qty >= TEB.QtyMin) OR (TEB.QtyMin IS NULL)) AND
				--		((TEB.Qty <= TEB.QtyMax) OR (TEB.QtyMax IS NULL))
				GROUP BY TEB.EntityBaseID, EO.OptionNbr, EO.EntityID,
						EO.CountAllowedForIndex, EO.CountAllowedAfterIndex
				HAVING	--(COUNT(DISTINCT CASE WHEN Allow = 0 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = 0) AND --Cannot evaluate denial due to unknown qty criteria
						(COUNT(DISTINCT CASE WHEN Allow = 1 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = EO.CountAllowedForIndex);
						
				--Added once QuantifyEntityCriteria was moved to post-CalulateEntityEnrollment (see ProcessEntities)
				DELETE FROM #PossibleEntities WHERE EntityBaseID NOT IN (SELECT DISTINCT EntityBaseID FROM Proxy.EntityEligible);
						
				CREATE CLUSTERED INDEX IX_#PossibleEntities ON #PossibleEntities (EntityBaseID ASC);

				--2) Identify entity base records requiring quantity comparison...
				SELECT	DATEADD(dd, MEC.AfterDOBDays, DATEADD(mm, MEC.AfterDOBMonths, M.DOB)) AS AfterDOBDate,
						PEB.Allow,
						MEC.AllowActiveScript,
						MEC.AllowBeginDate,
						MEC.AllowEndDate,
						MEC.AllowServDate,
						MEC.AllowSupplemental,
						MEC.AllowXfers,
						PEB.BatchID,
						PEB.DateComparerID,
						PEB.DateComparerInfo,
						MDC.DateCompTypeID,
						PEB.DataRunID,
						PEB.DataSetID,
						PEB.DataSourceID,
						MEC.DaysMax,
						MEC.DaysMin,
						PEB.DSMemberID,
						PEB.EntityBaseID,
						PEB.EntityBeginDate,
						PEB.EntityCritID,
						PEB.EntityEndDate,
						DATEADD(DAY, MEC.BeginDays * -1, DATEADD(MONTH, MEC.BeginMonths * -1, PEB.EntityBeginDate)) AS EntityDate,
						PEB.EntityID,
						MEC.QtyComparerID,
						PEB.RowID,
						MEC.RequirePaid,
						MEC.ValueMax,
						MEC.ValueMin
				INTO	#QtyLookup
				FROM	Proxy.EntityBase AS PEB
						INNER JOIN #PossibleEntities AS PE
								ON PEB.EntityBaseID = PE.EntityBaseID
						INNER JOIN Proxy.Members AS M
								ON PEB.DataSetID = M.DataSetID AND
									PEB.DSMemberID = M.DSMemberID
						INNER JOIN Measure.EntityCriteria AS MEC
								ON PEB.EntityCritID = MEC.EntityCritID AND
									PEB.EntityID = MEC.EntityID
						INNER JOIN Measure.DateComparers AS MDC
								ON PEB.DateComparerID = MDC.DateComparerID AND
									MDC.DateCompTypeID IN(@DateCompTypeE, @DateCompTypeV)
						INNER JOIN Measure.QuantityComparers AS MQC 
								ON MEC.QtyComparerID = MQC.QtyComparerID;

				--2) Break QtyLookup into the three versions of comparisons to try to improve performance...
				SELECT * INTO #QtyLookupV1Of2 FROM #QtyLookup AS QL WHERE QL.DateCompTypeID IN (@DateCompTypeV) AND QL.QtyComparerID IN (@QtyComparerC, @QtyComparerD, @QtyComparerF, @QtyComparerG, @QtyComparerK, @QtyComparerL, @QtyComparerP, @QtyComparerE);
				CREATE CLUSTERED INDEX IX_#QtyLookupV1Of2 ON #QtyLookupV1Of2 
					--(DSMemberID, DateComparerInfo, DateCompTypeID, RowID);
					(DSMemberID, DateComparerInfo, EntityBeginDate, EntityEndDate, AllowBeginDate, AllowEndDate, AllowServDate, AllowActiveScript, RequirePaid, AllowSupplemental, AllowXfers, DateCompTypeID, RowID);


				SELECT * INTO #QtyLookupV2Of2 FROM #QtyLookup AS QL WHERE QL.DateCompTypeID IN (@DateCompTypeV) AND QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerU, @QtyComparerV, @QtyComparerW);
				CREATE CLUSTERED INDEX IX_#QtyLookupV2Of2 ON #QtyLookupV2Of2 
					--(DSMemberID, DateComparerInfo, DateCompTypeID, RowID);
					(DSMemberID, DateComparerInfo, EntityBeginDate, EntityEndDate, AllowBeginDate, AllowEndDate, AllowServDate, AllowActiveScript, RequirePaid, AllowSupplemental, AllowXfers, DateCompTypeID, RowID);

				SELECT * INTO #QtyLookupE1Of1 FROM #QtyLookup AS QL WHERE QL.DateCompTypeID IN (@DateCompTypeE) AND NOT(QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerU, @QtyComparerV, @QtyComparerW));
				CREATE CLUSTERED INDEX IX_#QtyLookupE1Of1 ON #QtyLookupE1Of1 
					--(DSMemberID, DateComparerInfo, DateCompTypeID, RowID);
					(DSMemberID, DateComparerInfo, EntityBeginDate, EntityEndDate, AllowBeginDate, AllowEndDate, AllowServDate, AllowActiveScript, RequirePaid, AllowSupplemental, AllowXfers, DateCompTypeID, RowID);

				--3) Calculate quantities...
				
				--  3a/b) Event-related Prerequisites
				
				--PREREQ: Determine what event data is needed for the quantity calculations...
				SELECT	ISNULL(MIN(QL.AfterDOBDate), MIN(QL.EntityBeginDate)) AS AfterDOBDate,
						CONVERT(bit, MAX(CONVERT(smallint, QL.AllowActiveScript))) AS AllowActiveScript,
						QL.DSMemberID,
						MIN(QL.EntityBeginDate) AS EntityBeginDate,
						MAX(QL.EntityEndDate) AS EntityEndDate,
						QL.DateComparerInfo AS EventID
				INTO	#EventLookup
				FROM	#QtyLookup AS QL
				WHERE	DateCompTypeID IN (@DateCompTypeV)
				GROUP BY QL.DSMemberID, 
						QL.DateComparerInfo;
						
				DROP TABLE #QtyLookup;
				CREATE UNIQUE CLUSTERED INDEX IX_#EventLookup ON #EventLookup (DSMemberID, EventID);

				--PREREQ: Pull the related event data...
				SELECT	PV.BeginDate,
				        PV.BeginOrigDate,
				        PV.ClaimTypeID,
				        PV.CodeID,
						PV.DataSourceID,
				        PV.[Days],
				        PV.DispenseID,
				        PV.DSClaimID,
				        PV.DSClaimLineID,
				        PV.DSEventID,
				        PV.DSMemberID,
				        PV.DSProviderID,
				        PV.EndDate,
				        PV.EndOrigDate,
				        CONVERT(xml, null) AS EntityQtyInfo,
						PV.EventBaseID,
				        PV.EventCritID,
				        PV.EventID,
				        PV.IsPaid,
						PV.IsSupplemental,
				        PV.IsXfer,
				        PV.Value,
				        PV.XferID
				INTO	#Events
				FROM	Proxy.[Events] AS PV
						INNER JOIN #EventLookup AS VL
								ON PV.DSMemberID = VL.DSMemberID AND
									PV.EventID = VL.EventID
				WHERE	(
							(PV.BeginDate BETWEEN VL.EntityBeginDate AND VL.EntityEndDate) OR
							(
								(PV.EndDate IS NOT NULL) AND
								(PV.EndDate BETWEEN VL.EntityBeginDate AND VL.EntityEndDate)
							) OR
							(PV.EndOrigDate IS NOT NULL) AND
							(VL.AllowActiveScript = 1) AND
							(PV.EndOrigDate BETWEEN VL.EntityBeginDate AND VL.EntityEndDate)
						) AND
						(PV.BeginDate >= VL.AfterDOBDate);
				
				DROP TABLE #EventLookup;
				
				CREATE UNIQUE CLUSTERED INDEX IX_#Events ON #Events 
					--(DSMemberID, EventID, DSEventID);
					(DSMemberID, EventID, EndDate, BeginDate, EndOrigDate, Value, IsPaid, IsSupplemental, IsXfer, EventBaseID, DSEventID);

				CREATE NONCLUSTERED INDEX IX_#Events2 ON #Events (EventID) INCLUDE (BeginDate, EndDate, EndOrigDate);

				--	3a) Events (Part 1 of 2, see WHERE Clause)...
				SELECT	COUNT(*) AS CountRecords,
						MIN(PV.DataSourceID) AS DataSourceID,
						CONVERT(xml, null) AS EntityQtyInfo,
						QL.RowID,
						CONVERT(decimal(12, 6), CASE QL.QtyComparerID 
							WHEN @QtyComparerC THEN COUNT(DISTINCT PV.DSClaimID)
							WHEN @QtyComparerD THEN COUNT(DISTINCT REPLACE(CONVERT(char(16), PV.EventCritID) + CONVERT(char(16), PV.EventBaseID) + CONVERT(char(8), ISNULL(PV.DispenseID, 1)), ' ', '_'))
							--WHEN @QtyComparerD THEN COUNT(DISTINCT REPLACE(CONVERT(char(16), PV.EventCritID) + CONVERT(char(8), PV.BeginDate, 112) + CONVERT(char(8), ISNULL(PV.DispenseID, 1)), ' ', '_'))
							WHEN @QtyComparerF THEN dbo.CountDates(ISNULL(PV.EndDate, PV.BeginDate), 14)
							WHEN @QtyComparerG THEN COUNT(DISTINCT ISNULL(PV.EndDate, PV.BeginDate))
							WHEN @QtyComparerK THEN COUNT(DISTINCT PV.EventCritID)
							WHEN @QtyComparerL THEN COUNT(DISTINCT PV.DSClaimLineID)
							WHEN @QtyComparerP THEN COUNT(DISTINCT REPLACE(CONVERT(char(16), PV.DSProviderID) + CONVERT(char(8), ISNULL(PV.EndDate, PV.BeginDate), 112), ' ', '_'))
							ELSE COUNT(DISTINCT PV.DSEventID)
							END) AS Qty,
						QL.QtyComparerID
				INTO	#NewQuantities
				FROM	#QtyLookupV1Of2 AS QL WITH(INDEX (IX_#QtyLookupV1Of2))
						INNER JOIN #Events AS PV WITH(INDEX (IX_#Events))
								ON QL.DSMemberID = PV.DSMemberID AND
									QL.DateComparerInfo = PV.EventID AND
									QL.DateCompTypeID = @DateCompTypeV AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PV.BeginDate >= QL.AfterDOBDate))) AND
						
									--Apply Supplemental Data Criteria-----------------------------------------------------------------
									((QL.AllowSupplemental = 1) OR
									((QL.AllowSupplemental = 0) AND (PV.IsSupplemental = 0))) AND

									--Apply Transfer Criteria-----------------------------------------------------------------
									((QL.AllowXfers = 1) OR
									((QL.AllowXfers = 0) AND (PV.IsXfer = 0))) AND
									((PV.XferID IS NULL) OR (PV.XferID = PV.EventBaseID)) AND 
						
									--Apply Date Criteria*--------------------------------------------------------------------
									(
										(
											(
												(QL.AllowBeginDate = 1) AND 
												(PV.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowEndDate = 1) AND 
												(PV.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowServDate = 1) AND 
												(
													(
														(PV.EndDate IS NULL) AND 
														(PV.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													) OR
													(
														(PV.EndDate IS NOT NULL) AND 
														(PV.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													)
												) 
											) 
										) OR
										
										/*Pharmacy Active Script Date Criteria*/
										(	
											(QL.AllowActiveScript = 1) AND 
											(PV.EndOrigDate IS NOT NULL) AND
											(QL.EntityBeginDate > PV.BeginDate) AND
											(QL.EntityBeginDate BETWEEN PV.BeginDate AND PV.EndOrigDate)
										)
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									
									--Apply Paid Criteria---------------------------------------------------------------------
									((QL.RequirePaid = 0) OR
									((QL.RequirePaid = 1) AND (PV.IsPaid = 1))) AND
									
									--Apply Value Criteria--------------------------------------------------------------------
									((QL.ValueMax IS NULL) OR 
									((QL.ValueMax IS NOT NULL) AND (QL.ValueMax >= PV.Value))) AND
									((QL.ValueMin IS NULL) OR 
									((QL.ValueMin IS NOT NULL) AND (QL.ValueMin <= PV.Value))) 
				--WHERE	QL.QtyComparerID IN (@QtyComparerC, @QtyComparerD, @QtyComparerF, @QtyComparerG, @QtyComparerK, @QtyComparerL, @QtyComparerP, @QtyComparerE)
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.RowID;
					
				--	3b) Events (Part 2 of 2, see WHERE clause)...

				--PREREQ: Build a smaller version of the calendar table, based on the absolute worst case date range...
				DECLARE @Calendar TABLE (D smalldatetime NOT NULL, PRIMARY KEY (D));

				SELECT	MIN(QL.EntityBeginDate) AS EntityBeginDate,
						MAX(QL.EntityEndDate) AS EntityEndDate,
						QL.DateComparerInfo AS EventID
				INTO	#EventList
				FROM	#QtyLookupV2Of2 AS QL
				WHERE	QL.DateCompTypeID = @DateCompTypeV AND
						QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerU, @QtyComparerV, @QtyComparerW)
				GROUP BY QL.DateComparerInfo;

				CREATE UNIQUE CLUSTERED INDEX IX_#EventList ON #EventList (EventID);

				SELECT	MIN(V.BeginDate) AS BeginDate, 
						MAX(COALESCE(V.EndDate, V.EndOrigDate, V.BeginDate)) AS EndDate,
						MIN(VL.EntityBeginDate) AS EntityBeginDate, 
						MAX(VL.EntityEndDate) AS EntityEndDate
				INTO	#DateRangeBase
				FROM	#EventList AS VL
						INNER JOIN #Events AS V
								ON V.EventID = VL.EventID;

				WITH EvalDates AS
				(
					SELECT EvalDate
					FROM	(
								SELECT	BeginDate,
										EndDate,
										EntityBeginDate,
										EntityEndDate
								FROM	#DateRangeBase
							) p
							UNPIVOT		(
											EvalDate FOR DateType IN (BeginDate, EndDate, EntityBeginDate, EntityEndDate)
										) AS u
				), 
				DateRange AS
				(
					SELECT MIN(EvalDate) AS BeginDate, MAX(EvalDate) AS EndDate FROM EvalDates
				)
				INSERT INTO @Calendar
				        (D)
				SELECT	CONVERT(smalldatetime, D)
				FROM	dbo.Calendar AS C
						INNER JOIN DateRange AS DR
								ON C.D BETWEEN DR.BeginDate AND DR.EndDate AND
									C.D BETWEEN 0 AND '12/31/2070';

				DROP TABLE #EventList;
				DROP TABLE #DateRangeBase;
				DROP INDEX IX_#Events2 ON #Events;

				INSERT INTO #NewQuantities
				        (CountRecords,
						DataSourceID,
						EntityQtyInfo,
						RowID,
				         Qty,
						 QtyComparerID)
				SELECT	COUNT(*) AS CountRecords,
						MIN(PV.DataSourceID) AS DataSourceID,
						CONVERT(xml, null) AS EntityQtyInfo,
						QL.RowID,
						CONVERT(decimal(12, 6), CASE QL.QtyComparerID 
							WHEN @QtyComparerS THEN COUNT(C.D)
							WHEN @QtyComparerT THEN COUNT(DISTINCT C.D)
							WHEN @QtyComparerU THEN COUNT(C.D)
							WHEN @QtyComparerV THEN COUNT(DISTINCT C.D)
							WHEN @QtyComparerW THEN ROUND
													(
														(
														CONVERT(decimal(18,9), COUNT(DISTINCT C.D)) / 
														CONVERT(decimal(18,9), DATEDIFF(dd, MIN(QL.EntityBeginDate), MIN(CASE 
																															WHEN QL.EntityEndDate > @EndInitSeedDate 
																															THEN @EndInitSeedDate 
																															ELSE QL.EntityEndDate 
																															END)) + 1)
														) * 100,
														0
													)
							ELSE 0
							END) AS Qty,
						QL.QtyComparerID
				FROM	#QtyLookupV2Of2 AS QL WITH(INDEX (IX_#QtyLookupV2Of2))
						INNER JOIN #Events AS PV WITH(INDEX (IX_#Events))
								ON QL.DSMemberID = PV.DSMemberID AND
									QL.DateComparerInfo = PV.EventID AND
									QL.DateCompTypeID = @DateCompTypeV AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PV.BeginDate >= QL.AfterDOBDate))) AND

									--Apply Supplemental Data Criteria-----------------------------------------------------------------
									((QL.AllowSupplemental = 1) OR
									((QL.AllowSupplemental = 0) AND (PV.IsSupplemental = 0))) AND
						
									--Apply Transfer Criteria-----------------------------------------------------------------
									((QL.AllowXfers = 1) OR
									((QL.AllowXfers = 0) AND (PV.IsXfer = 0))) AND
									((PV.XferID IS NULL) OR (PV.XferID = PV.EventBaseID)) AND 
						
									--Apply Date Criteria*--------------------------------------------------------------------
									(
										(
											(
												(QL.AllowBeginDate = 1) AND 
												(PV.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowEndDate = 1) AND 
												(PV.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowServDate = 1) AND 
												(
													(
														(PV.EndDate IS NULL) AND 
														(PV.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													) OR
													(
														(PV.EndDate IS NOT NULL) AND 
														(PV.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													)
												) 
											) 
										) OR
										
										/*Pharmacy Active Script Date Criteria*/
										(	
											(QL.AllowActiveScript = 1) AND 
											(PV.EndOrigDate IS NOT NULL) AND
											(QL.EntityBeginDate > PV.BeginDate) AND
											(QL.EntityBeginDate BETWEEN PV.BeginDate AND PV.EndOrigDate)
										)
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									
									--Apply Paid Criteria---------------------------------------------------------------------
									((QL.RequirePaid = 0) OR
									((QL.RequirePaid = 1) AND (PV.IsPaid = 1))) AND

									--Apply Value Criteria--------------------------------------------------------------------
									((QL.ValueMax IS NULL) OR 
									((QL.ValueMax IS NOT NULL) AND (QL.ValueMax >= PV.Value))) AND
									((QL.ValueMin IS NULL) OR 
									((QL.ValueMin IS NOT NULL) AND (QL.ValueMin <= PV.Value))) 
						INNER JOIN @Calendar AS C
								ON	(
										(C.D BETWEEN PV.BeginDate AND COALESCE(PV.EndDate, PV.EndOrigDate, PV.BeginDate)) 
									)	AND
									(
										(QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerW) AND C.D BETWEEN QL.EntityBeginDate AND QL.EntityEndDate) OR
										(QL.QtyComparerID IN (@QtyComparerU, @QtyComparerV))
									) AND
									(
										(QL.QtyComparerID IN (@QtyComparerW) AND C.D <= @EndInitSeedDate) OR
										(QL.QtyComparerID NOT IN (@QtyComparerW))
									)
				--WHERE	QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerU, @QtyComparerV, @QtyComparerW)
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.RowID
				OPTION (FORCE ORDER);
						
				DROP TABLE #Events;
					
				--	3c) Entities...	
				
				--PREREQ: Determine what event data is needed for the quantity calculations...
				SELECT	ISNULL(MIN(QL.AfterDOBDate), MIN(QL.EntityBeginDate)) AS AfterDOBDate,
						QL.DSMemberID,
						MIN(QL.EntityBeginDate) AS EntityBeginDate,
						MAX(QL.EntityEndDate) AS EntityEndDate,
						QL.DateComparerInfo AS EntityID
				INTO	#EntityLookup
				FROM	#QtyLookupE1Of1 AS QL
				WHERE	DateCompTypeID IN (@DateCompTypeE)
				GROUP BY QL.DSMemberID, 
						QL.DateComparerInfo;
						
				CREATE UNIQUE CLUSTERED INDEX IX_#EntityLookup ON #EntityLookup (DSMemberID, EntityID);
				
				--PREREQ: Pull the related entity data...
				SELECT	PE.BeginDate,
				        PE.BeginOrigDate,
						PE.DataSourceID,
				        PE.DSEntityID,
				        PE.DSMemberID,
				        PE.DSProviderID,
				        PE.EndDate,
				        PE.EndOrigDate,
				        PE.EntityBaseID,
				        PE.EntityCritID,
				        PE.EntityID,
						CONVERT(xml, null) AS EntityQtyInfo,
						PE.IsSupplemental,
				        PE.SourceID,
				        PE.SourceLinkID
				INTO	#Entities
				FROM	Proxy.Entities AS PE
						INNER JOIN #EntityLookup AS VE
								ON PE.DSMemberID = VE.DSMemberID AND
									PE.EntityID = VE.EntityID
				WHERE	(
							(PE.BeginDate BETWEEN VE.EntityBeginDate AND VE.EntityEndDate) OR
							(
								(PE.EndDate IS NOT NULL) AND
								(PE.EndDate BETWEEN VE.EntityBeginDate AND VE.EntityEndDate)
							)
						) AND
						(PE.BeginDate >= VE.AfterDOBDate);
				
				DROP TABLE #EntityLookup;
				
				CREATE UNIQUE CLUSTERED INDEX IX_#Entities ON #Entities (DSMemberID, EntityID, DSEntityID);
				
				INSERT INTO #NewQuantities
				        (CountRecords,
						DataSourceID,
						EntityQtyInfo,
						RowID,
				        Qty,
						QtyComparerID)
				SELECT	COUNT(*) AS CountRecords,
						MIN(PE.DataSourceID) AS DataSourceID,
						CONVERT(xml, null) AS EntityQtyInfo,
						QL.RowID,
						CASE QL.QtyComparerID 
							WHEN @QtyComparerF THEN dbo.CountDates(ISNULL(PE.EndDate, PE.BeginDate), 14)
							WHEN @QtyComparerG THEN COUNT(DISTINCT ISNULL(PE.EndDate, PE.BeginDate))
							WHEN @QtyComparerP THEN COUNT(DISTINCT REPLACE(CONVERT(char(48), PE.DSProviderID) + CONVERT(char(48), ISNULL(PE.EndDate, PE.BeginDate), 109), ' ', '_'))
							ELSE COUNT(DISTINCT PE.DSEntityID)
							END AS Qty,
						QL.QtyComparerID
				FROM	#QtyLookupE1Of1 AS QL WITH(INDEX (IX_#QtyLookupE1Of1))
						INNER JOIN #Entities AS PE WITH(INDEX (IX_#Entities))
								ON QL.DSMemberID = PE.DSMemberID AND
									QL.DateComparerInfo = PE.EntityID AND
									QL.DateCompTypeID = @DateCompTypeE AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PE.BeginDate >= QL.AfterDOBDate))) AND

									--Apply Supplemental Data Criteria-----------------------------------------------------------------
									((QL.AllowSupplemental = 1) OR
									((QL.AllowSupplemental = 0) AND (PE.IsSupplemental = 0))) AND
						
									--Apply Date Criteria*--------------------------------------------------------------------
									(
										(
											(
												(QL.AllowBeginDate = 1) AND 
												(PE.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowEndDate = 1) AND 
												(PE.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
											) OR
											(
												(QL.AllowServDate = 1) AND 
												(
													(
														(PE.EndDate IS NULL) AND 
														(PE.BeginDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													) OR
													(
														(PE.EndDate IS NOT NULL) AND 
														(PE.EndDate BETWEEN QL.EntityBeginDate AND QL.EntityEndDate)
													)
												) 
											) 
										) 
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PE.BeginDate, PE.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PE.BeginDate, PE.EndDate) + 1))) --AND
				--WHERE	QL.QtyComparerID IS NOT NULL
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.RowID;
						
				CREATE UNIQUE CLUSTERED INDEX IX_#NewQuantities ON #NewQuantities (RowID);
					
				--4) Update quantities in associated event base records...
				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS ON;
				ELSE
					SET ANSI_WARNINGS OFF;
				

				
				UPDATE	PEB
				SET		DataSourceID = ISNULL(t.DataSourceID, PEB.DataSourceID),
						EntityQtyInfo = t.EntityQtyInfo,
						Qty = t.Qty
				FROM	Proxy.EntityBase AS PEB
						INNER JOIN #NewQuantities AS t
								ON PEB.RowID = t.RowID AND
									PEB.Qty <> t.Qty;
								
				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
										
			END;
		
		RETURN 0;
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
											--@PerformRollback = 0, --Not sure why this is here, 7/29/2016, MLK
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
