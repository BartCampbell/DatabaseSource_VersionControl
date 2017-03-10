SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/22/2011
-- Description:	Determines the actual quantities for entity criteria. (v1)
-- =============================================
CREATE PROCEDURE [Batch].[QuantifyEntityCriteria_v1]
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
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
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
		SET @LogObjectName = 'QuantifyEntityCriteria'; 
		SET @LogObjectSchema = 'Batch'; 
	
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
				GROUP BY MEC.EntityID, MEC.OptionNbr
				
				CREATE UNIQUE CLUSTERED INDEX IX_EntityOptions ON #EntityOptions (EntityID, OptionNbr) WITH (FILLFACTOR = 100);
				CREATE STATISTICS ST_EntityOptions ON #EntityOptions (EntityID, OptionNbr);
				
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
				HAVING	(COUNT(DISTINCT CASE WHEN Allow = 0 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = 0) AND
						(COUNT(DISTINCT CASE WHEN Allow = 1 AND TEB.IsForIndex = 1 THEN TEB.EntityCritID END) = EO.CountAllowedForIndex);
						
				--Added once QuantifyEntityCriteria was moved to post-CalulateEntityEnrollment (see ProcessEntities)
				DELETE FROM #PossibleEntities WHERE EntityBaseID NOT IN (SELECT DISTINCT EntityBaseID FROM Proxy.EntityEligible);
						
				CREATE CLUSTERED INDEX IX_#PossibleEntities ON #PossibleEntities (EntityBaseID ASC) WITH (FILLFACTOR = 100);
				CREATE STATISTICS ST_#PossibleEntities ON #PossibleEntities (EntityBaseID);

				--2) Identify entity base records requiring quantity comparison...
				SELECT	DATEADD(mm, MEC.AfterDOBMonths, DATEADD(dd, MEC.AfterDOBDays, M.DOB)) AS AfterDOBDate,
						PEB.Allow,
						MEC.AllowActiveScript,
						MEC.AllowBeginDate,
						MEC.AllowEndDate,
						MEC.AllowServDate,
						MEC.AllowXfers,
						PEB.BatchID,
						PEB.DateComparerID,
						PEB.DateComparerInfo,
						MDC.DateCompTypeID,
						PEB.DataRunID,
						PEB.DataSetID,
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
						PEB.QtyMax,
						PEB.QtyMin,
						PEB.RowID,
						MEC.RequirePaid
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

				CREATE UNIQUE CLUSTERED INDEX PX_#QtyLookup ON #QtyLookup (RowID);
				CREATE NONCLUSTERED INDEX IX_#QtyLookup ON #QtyLookup (DSMemberID, DateComparerInfo, EntityEndDate, EntityBeginDate, DateCompTypeID) INCLUDE (QtyComparerID);
				CREATE STATISTICS ST_#QtyLookup ON #QtyLookup (DSMemberID, DateComparerInfo, EntityEndDate, EntityBeginDate, DateCompTypeID);

				--3) Calculate quantities...
				DECLARE @CreateIndexSql nvarchar(MAX);
				DECLARE @CreateStatisticSql nvarchar(MAX);
				DECLARE @DropIndexSql nvarchar(MAX);
				DECLARE @DropStatisticSql nvarchar(MAX);
				
				--Create temporary index for Events similar to the nonclustered index on #QtyLookup...
				SET @CreateIndexSql =		'CREATE NONCLUSTERED INDEX IX_temporary_Event_fromQuantifyEntityCriteria_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
											'ON Internal.Events (DSMemberID, EventID, EndDate, BeginDate, EndOrigDate) ' + 
											'INCLUDE (IsXfer, XferID) ' + 
											'WHERE (BatchID = ' + CONVERT(nvarchar(MAX), @BatchID) + ') AND (SpId = ' + CONVERT(nvarchar(MAX), @@SPID) + ') ' + 
											'WITH (ONLINE = ON);';
										
				SET @CreateStatisticSql =	'CREATE STATISTICS ST_temporary_Event_fromQuantifyEntityCriteria_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
											'ON Internal.Events (DSMemberID, EventID, EndDate, BeginDate, EndOrigDate) ' + 
											'WHERE (BatchID = ' + CONVERT(nvarchar(MAX), @BatchID) + ') AND (SpId = ' + CONVERT(nvarchar(MAX), @@SPID) +') ;'
										
				SET @DropIndexSql =			'DROP INDEX IX_temporary_Event_fromQuantifyEntityCriteria_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ' ' +
											'ON Internal.Events;';

				SET @DropStatisticSql =		'DROP STATISTICS Internal.Events.ST_temporary_Event_fromQuantifyEntityCriteria_forBatch' + CONVERT(nvarchar(MAX), @BatchID) + ';';
				
				SET ANSI_WARNINGS ON;

				EXEC (@CreateIndexSql);
				EXEC (@CreateStatisticSql);
				
				SET ANSI_WARNINGS OFF;
				
				--	3a) Events (Part 1 of 2, see WHERE Clause)...
				SELECT	QL.RowID,
						CASE QL.QtyComparerID 
							WHEN @QtyComparerC THEN COUNT(DISTINCT PV.DSClaimID)
							WHEN @QtyComparerD THEN COUNT(DISTINCT REPLACE(CONVERT(char(16), PV.EventCritID) + CONVERT(char(8), PV.BeginDate, 112) + CONVERT(char(8), PV.DispenseID), ' ', '_'))
							WHEN @QtyComparerK THEN COUNT(DISTINCT PV.EventCritID)
							WHEN @QtyComparerL THEN COUNT(DISTINCT PV.DSClaimLineID)
							WHEN @QtyComparerP THEN COUNT(DISTINCT REPLACE(CONVERT(char(16), PV.DSProviderID) + CONVERT(char(8), ISNULL(PV.EndDate, PV.BeginDate), 112), ' ', '_'))
							ELSE COUNT(DISTINCT PV.DSEventID)
							END AS Qty
				INTO	#NewQuantities
				FROM	#QtyLookup AS QL
						INNER JOIN Proxy.[Events] AS PV
								ON QL.DSMemberID = PV.DSMemberID AND
									QL.DateComparerInfo = PV.EventID AND
									QL.DateCompTypeID = @DateCompTypeV AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PV.BeginDate >= QL.AfterDOBDate))) AND
						
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
											(QL.EntityDate > PV.BeginDate) AND
											(QL.EntityDate BETWEEN PV.BeginDate AND PV.EndOrigDate)
										)
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									
									--Apply Paid Criteria---------------------------------------------------------------------
									((QL.RequirePaid = 0) OR
									((QL.RequirePaid = 1) AND (PV.IsPaid = 1)))
				WHERE	QL.QtyComparerID IN (@QtyComparerC, @QtyComparerD, @QtyComparerK, @QtyComparerL, @QtyComparerP, @QtyComparerE) AND
						PV.BatchID = @BatchID
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.QtyMax,
						QL.QtyMin,
						QL.RowID;
					
				--	3b) Events (Part 2 of 2, see WHERE clause)...
				INSERT INTO #NewQuantities
				        (RowID,
				         Qty)
				SELECT	QL.RowID,
						CASE QL.QtyComparerID 
							WHEN @QtyComparerS THEN COUNT(C.D)
							WHEN @QtyComparerT THEN COUNT(DISTINCT C.D)
							WHEN @QtyComparerU THEN COUNT(C.D)
							WHEN @QtyComparerV THEN COUNT(C.D)
							WHEN @QtyComparerW THEN FLOOR
													(
														(
														CONVERT(decimal(18,9), COUNT(DISTINCT C.D)) / 
														CONVERT(decimal(18,9), DATEDIFF(dd, MIN(QL.EntityBeginDate), MIN(CASE 
																															WHEN QL.EntityEndDate > @EndInitSeedDate 
																															THEN @EndInitSeedDate 
																															ELSE QL.EntityEndDate 
																															END)))
														) * 100
													)
							ELSE 0
							END AS Qty
				FROM	#QtyLookup AS QL
						INNER JOIN Proxy.[Events] AS PV
								ON QL.DSMemberID = PV.DSMemberID AND
									QL.DateComparerInfo = PV.EventID AND
									QL.DateCompTypeID = @DateCompTypeV AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PV.BeginDate >= QL.AfterDOBDate))) AND
						
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
											(QL.EntityDate > PV.BeginDate) AND
											(QL.EntityDate BETWEEN PV.BeginDate AND PV.EndOrigDate)
										)
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PV.BeginDate, PV.EndDate) + 1))) AND
									
									--Apply Paid Criteria---------------------------------------------------------------------
									((QL.RequirePaid = 0) OR
									((QL.RequirePaid = 1) AND (PV.IsPaid = 1)))
						INNER JOIN dbo.Calendar AS C
								ON	(
										(C.D BETWEEN PV.BeginDate AND COALESCE(PV.EndDate, PV.EndOrigDate, PV.BeginDate)) 
									)	AND
									(
										(QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerW) AND C.D BETWEEN QL.EntityBeginDate AND QL.EntityEndDate) OR
										(QL.QtyComparerID IN (@QtyComparerW) AND C.D <= @EndInitSeedDate) OR
										(QL.QtyComparerID IN (@QtyComparerU, @QtyComparerV))
									)
				WHERE	QL.QtyComparerID IN (@QtyComparerS, @QtyComparerT, @QtyComparerU, @QtyComparerV, @QtyComparerW) AND
						PV.BatchID = @BatchID
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.QtyMax,
						QL.QtyMin,
						QL.RowID;
						
				SET ANSI_WARNINGS ON;

				EXEC (@DropIndexSql);
				EXEC (@DropStatisticSql);		

				SET ANSI_WARNINGS OFF;
					
				--	3c) Entities...	
				INSERT INTO #NewQuantities
				        (RowID,
				         Qty)
				SELECT	QL.RowID,
						CASE QL.QtyComparerID 
							WHEN @QtyComparerP THEN COUNT(DISTINCT REPLACE(CONVERT(char(48), PE.DSProviderID) + CONVERT(char(48), ISNULL(PE.EndDate, PE.BeginDate), 109), ' ', '_'))
							ELSE COUNT(DISTINCT PE.DSEntityID)
							END AS Qty
				FROM	#QtyLookup AS QL
						INNER JOIN Proxy.Entities AS PE
								ON QL.DSMemberID = PE.DSMemberID AND
									QL.DateComparerInfo = PE.EntityID AND
									QL.DateCompTypeID = @DateCompTypeE AND
									
									--Apply After-Date-of-Birth Criteria---------------------------------------------------
									((QL.AfterDOBDate IS NULL) OR
									((QL.AfterDOBDate IS NOT NULL) AND (PE.BeginDate >= QL.AfterDOBDate))) AND
						
									--Apply Transfer Criteria-----------------------------------------------------------------
									--((QL.AllowXfers = 1) OR
									--((QL.AllowXfers = 0) AND (PE.IsXfer = 0))) AND
									--((PE.XferID IS NULL) OR (PE.XferID = PE.EventBaseID)) AND 
						
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
										) --OR
										
										/*Pharmacy Active Script Addition, Date Criteria (Part 5 of 5)*/
										--(	
										--	(QL.AllowActiveScript = 1) AND 
										--	(PE.EndOrigDate IS NOT NULL) AND
										--	(QL.EntityDate > PE.BeginDate) AND
										--	(QL.EntityDate BETWEEN PE.BeginDate AND PE.EndDate)
										--)
										
									) AND
									
									--Apply Length/Number of Days Criteria----------------------------------------------------
									((QL.DaysMax IS NULL) OR
									((QL.DaysMax IS NOT NULL) AND (QL.DaysMax >= DATEDIFF(dd, PE.BeginDate, PE.EndDate) + 1))) AND
									((QL.DaysMin IS NULL) OR
									((QL.DaysMin IS NOT NULL) AND (QL.DaysMin <= DATEDIFF(dd, PE.BeginDate, PE.EndDate) + 1))) --AND
									
									--Apply Paid Criteria---------------------------------------------------------------------
									--((QL.RequirePaid = 0) OR
									--((QL.RequirePaid = 1) AND (PE.IsPaid = 1)))
				WHERE	QL.QtyComparerID IS NOT NULL
				GROUP BY QL.DSMemberID,
						QL.QtyComparerID,
						QL.QtyMax,
						QL.QtyMin,
						QL.RowID;
						
				CREATE UNIQUE CLUSTERED INDEX IX_#NewQuantities ON #NewQuantities (RowID);
				CREATE STATISTICS ST_#NewQuantities ON #NewQuantities (RowID);
					
				--4) Update quantities in associated event base records...	
				UPDATE	PEB
				SET		Qty = t.Qty
				FROM	Proxy.EntityBase AS PEB
						INNER JOIN #NewQuantities AS t
								ON PEB.RowID = t.RowID;
								
				IF @Ansi_Warnings = 1
					SET ANSI_WARNINGS ON;
				ELSE
					SET ANSI_WARNINGS OFF;
											
				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			END;
		
		RETURN 0;
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
											@PerformRollback = 0,
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
GRANT VIEW DEFINITION ON  [Batch].[QuantifyEntityCriteria_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[QuantifyEntityCriteria_v1] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[QuantifyEntityCriteria_v1] TO [Processor]
GO
