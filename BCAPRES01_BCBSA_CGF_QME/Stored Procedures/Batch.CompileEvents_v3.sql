SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/30/2011
-- Description:	Compiles "EventBase" records to form the actual "Event" records. (v3)
-- =============================================
CREATE PROCEDURE [Batch].[CompileEvents_v3]
(
	@BatchID int
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
	
	DECLARE @Result int;
	
		BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileEvents'; 
		SET @LogObjectSchema = 'Batch'; 
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Compiling and finalizing events failed!  No batch was specified.', 16, 1);
				
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
			
			DECLARE @ClaimTypeE tinyint;
			DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			DECLARE @EventTypeC tinyint;
			DECLARE @EventTypeL tinyint;
			DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C';
			SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L';
			SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D';
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P';

			-------------------------------------------------------------------

			SET ANSI_WARNINGS OFF;

			--Create a "master" EventBaseID (EventMasterID) for use in combining each of the different successful options for a given event
			IF OBJECT_ID('tempdb..#EventMasters') IS NOT NULL
				DROP TABLE #EventMasters;
			
			--1) Identify the successful options
			SELECT DISTINCT
					EventBaseID, 
					CONVERT(bigint, NULL) AS EventMasterID
			INTO	#EventMasters
			FROM	Proxy.EventBase 
			GROUP BY EventBaseID,
					EventID,
					OptionNbr 
			HAVING	(COUNT(DISTINCT CASE WHEN Allow = 1 THEN EventCritID END) >= MAX(CountAllowed)) AND
					(COUNT(DISTINCT CASE WHEN Allow = 0 THEN EventCritID END) = 0)
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventMasters ON #EventMasters (EventBaseID);
			CREATE STATISTICS ST_#EventMasters ON #EventMasters (EventBaseID);

			--2) Match multiple successful options for the same event (uses event type to identity the "multiples" as one)
			--2a. EVENT TYPE OF C - Claims-----------------------------------------------------------------------------------------
			IF OBJECT_ID('tempdb..#EventMastersBaseC') IS NOT NULL
				DROP TABLE #EventMastersBaseC;
			
			SELECT	DSClaimID, 
					EventID, 
					MIN(EventBaseID) AS EventMasterID
			INTO	#EventMastersBaseC
			FROM	Proxy.EventBase AS VB
			WHERE	(VB.EventTypeID = @EventTypeC) AND
					(VB.RankOrder = 1)
			GROUP BY DSClaimID, EventID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventMastersBaseC ON #EventMastersBaseC (DSClaimID, EventID);
			CREATE STATISTICS ST_#EventMastersBaseC ON #EventMastersBaseC (DSClaimID, EventID);
			
			UPDATE	t
			SET		t.EventMasterID = VK.EventMasterID
			FROM	#EventMastersBaseC AS VK
					INNER JOIN Proxy.EventBase AS VB
							ON VK.DSClaimID = VB.DSClaimID AND
								VK.EventID = VB.EventID AND
								VB.EventTypeID = @EventTypeC
					INNER JOIN #EventMasters AS t
							ON t.EventBaseID = VB.EventBaseID  AND
								t.EventMasterID IS NULL
			WHERE	(VB.RankOrder = 1);
								
			DROP TABLE #EventMastersBaseC;

			--2b. EVENT TYPE OF L - Claim Lines-------------------------------------------------------------------------------------
			IF OBJECT_ID('tempdb..#EventMastersBaseL') IS NOT NULL
				DROP TABLE #EventMastersBaseL;
				
			SELECT	DSClaimLineID, 
					EventID, 
					MIN(EventBaseID) AS EventMasterID
			INTO	#EventMastersBaseL
			FROM	Proxy.EventBase AS VB
			WHERE	(VB.EventTypeID = @EventTypeL) AND
					(VB.RankOrder = 1)
			GROUP BY DSClaimLineID, EventID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventMastersBaseL ON #EventMastersBaseL (DSClaimLineID, EventID);
			CREATE STATISTICS ST_#EventMastersBaseL ON #EventMastersBaseL (DSClaimLineID, EventID);
			
			UPDATE	t
			SET		t.EventMasterID = VK.EventMasterID
			FROM	#EventMastersBaseL AS VK
					INNER JOIN Proxy.EventBase AS VB
							ON VK.DSClaimLineID = VB.DSClaimLineID AND
								VK.EventID = VB.EventID AND
								VB.EventTypeID = @EventTypeL
					INNER JOIN #EventMasters AS t
							ON t.EventBaseID = VB.EventBaseID  AND
								t.EventMasterID IS NULL
			WHERE	(VB.RankOrder = 1);
								
			DROP TABLE #EventMastersBaseL;
								
			--2c. EVENT TYPE OF D - Members and Dates-------------------------------------------------------------------------------
			IF OBJECT_ID('tempdb..#EventMastersBaseD') IS NOT NULL
				DROP TABLE #EventMastersBaseD;
				
			SELECT	MIN(BeginDate) AS BeginDate, 
					DSMemberID,
					MAX(EndDate) AS EndDate,
					EventID, 
					MIN(EventBaseID) AS EventMasterID,
					ISNULL(EndDate, BeginDate) AS KeyDate
			INTO	#EventMastersBaseD
			FROM	Proxy.EventBase AS VB
			WHERE	(VB.EventTypeID = @EventTypeD) AND
					(VB.RankOrder = 1)
			GROUP BY ISNULL(EndDate, BeginDate), DSMemberID,
					 EventID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventMastersBaseD ON #EventMastersBaseD (DSMemberID, KeyDate, BeginDate, EndDate, EventID);
			CREATE STATISTICS ST_#EventMastersBaseD ON #EventMastersBaseD (DSMemberID, KeyDate, BeginDate, EndDate, EventID);
			
			UPDATE	t
			SET		t.EventMasterID = VK.EventMasterID
			FROM	#EventMastersBaseD AS VK
					INNER JOIN Proxy.EventBase AS VB
							ON VK.DSMemberID = VB.DSMemberID AND
								(
									(VK.KeyDate = VB.BeginDate) OR
									(VK.KeyDate = VB.EndDate) OR
									(VK.EndDate IS NOT NULL AND VB.EndDate IS NOT NULL AND VK.EndDate > VB.EndDate AND VK.BeginDate < VB.EndDate) OR
									(VK.EndDate IS NOT NULL AND VB.EndDate IS NOT NULL AND VK.EndDate > VB.BeginDate AND VK.BeginDate < VB.BeginDate)
								) AND
								VK.EventID = VB.EventID AND
								VB.EventTypeID = @EventTypeD
					INNER JOIN #EventMasters AS t
							ON t.EventBaseID = VB.EventBaseID  AND
								t.EventMasterID IS NULL
			WHERE	(VB.RankOrder = 1);
								
			DROP TABLE #EventMastersBaseD;
								
			--2d. EVENT TYPE OF P - Members, Providers and Dates--------------------------------------------------------------------
			IF OBJECT_ID('tempdb..#EventMastersBaseP') IS NOT NULL
				DROP TABLE #EventMastersBaseP;
				
			SELECT	MIN(BeginDate) AS BeginDate, 
					DSMemberID, 
					DSProviderID,
					MAX(EndDate) AS EndDate,
					EventID, 
					MIN(EventBaseID) AS EventMasterID,
					ISNULL(EndDate, BeginDate) AS KeyDate
			INTO	#EventMastersBaseP
			FROM	Proxy.EventBase AS VB
			WHERE	(VB.EventTypeID = @EventTypeP) AND
					(VB.RankOrder = 1)
			GROUP BY ISNULL(EndDate, BeginDate), DSMemberID, DSProviderID,
					EventID;
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventMastersBaseP ON #EventMastersBaseP (DSMemberID, DSProviderID, KeyDate, BeginDate, EndDate, EventID);
			CREATE STATISTICS ST_#EventMastersBaseP ON #EventMastersBaseP (DSMemberID, DSProviderID, KeyDate, BeginDate, EndDate, EventID);
			
			UPDATE	t
			SET		t.EventMasterID = VK.EventMasterID
			FROM	#EventMastersBaseP AS VK
					INNER JOIN Proxy.EventBase AS VB
							ON VK.DSMemberID = VB.DSMemberID AND
								(	
									VK.DSProviderID = VB.DSProviderID OR
									VK.DSProviderID IS NULL OR
									VB.DSProviderID IS NULL
								) AND
								(
									(VK.KeyDate = VB.BeginDate) OR
									(VK.KeyDate = VB.EndDate) OR
									(VK.EndDate IS NOT NULL AND VB.EndDate IS NOT NULL AND VK.EndDate > VB.EndDate AND VK.BeginDate < VB.EndDate) OR
									(VK.EndDate IS NOT NULL AND VB.EndDate IS NOT NULL AND VK.EndDate > VB.BeginDate AND VK.BeginDate < VB.BeginDate)
								) AND
								VK.EventID = VB.EventID AND
								VB.EventTypeID = @EventTypeP
					INNER JOIN #EventMasters AS t
							ON t.EventBaseID = VB.EventBaseID  AND
								t.EventMasterID IS NULL
			WHERE	(VB.RankOrder = 1);

			DROP TABLE #EventMastersBaseP;

			--3) Combine Event Base records in to Event records using the EventMasterIDs-------------------------------------------				
			SELECT	@BatchID AS BatchID,
					MIN(VB.BeginDate) AS BeginDate,
					MIN(VB.BeginDate) AS BeginOrigDate,
					MIN(VB.ClaimTypeID) AS ClaimTypeID,
					MIN(VB.CodeID) AS CodeID,
					COUNT(DISTINCT VB.DSClaimID) AS CountClaims,
					COUNT(DISTINCT VB.CodeID) AS CountCodes,
					COUNT(DISTINCT VB.DSClaimLineID) AS CountLines,
					CONVERT(int, NULL) AS CountMasterRecords,
					COUNT(DISTINCT VB.DSProviderID) AS CountProviders,
					CASE WHEN COUNT(*) = COUNT(DISTINCT VB.DSClaimLineID) THEN SUM(VB.[Days]) ELSE MAX(VB.[Days]) END AS [Days],
					MIN(VB.DSClaimID) AS DSClaimID,
					MIN(VB.DSClaimLineID) AS DSClaimLineID,
					MIN(VB.DSMemberID) AS DSMemberID,
					CASE WHEN COUNT(DISTINCT VB.DSProviderID) = 1 THEN MIN(VB.DSProviderID) END AS DSProviderID,
					CASE WHEN MIN(VB.ClaimTypeID) = @ClaimTypeP THEN NULL ELSE MAX(VB.EndDate) END AS EndDate,
					MAX(VB.EndDate) AS EndOrigDate,
					CASE WHEN COUNT(DISTINCT VB.EventCritID) = 1 THEN MIN(VB.EventCritID) END AS EventCritID,
					VB.EventID,
					VK.EventMasterID,
					CAST(MIN(CAST(VB.IsPaid AS smallint)) AS bit) AS IsPaid,
					CONVERT(int, NULL) AS MaxRows,
					COALESCE(MIN(CASE WHEN RankOrder = 1 THEN Value END), MIN(Value)) AS Value
			INTO	#Events
			FROM	Proxy.EventBase AS VB
					INNER JOIN #EventMasters AS VK
							ON VB.EventBaseID = VK.EventBaseID 
			GROUP BY VK.EventMasterID, VB.EventID; 
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Events ON #Events (EventMasterID, EventID);
			CREATE STATISTICS ST_#Events ON #Events (EventMasterID, EventID);
			
			--4) Identify "key" event master records to further summarize events and reduce redundant event entries
			SELECT	COUNT(DISTINCT t.EventMasterID) AS CountMasterRecords, 
					CASE 
						WHEN MAX(t.ClaimTypeID) = MIN(t.ClaimTypeID) 
						THEN MIN(t.ClaimTypeID)
						END AS ClaimTypeID,
					CASE 
						--If the "key" event grouping is 100% Pharmacy Claims, then sum the days:
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP 
						THEN SUM(t.[Days]) 
						--If the "key" event grouping is 100% Encounter Claims, then calculate the new length of stay:
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeE AND
							 MIN(t.ClaimTypeID) = @ClaimTypeE AND
							 t.EndDate IS NOT NULL
						THEN MAX(ISNULL(NULLIF(DATEDIFF(dd, t.BeginDate, t.EndDate), 0), 1))
						--Otherwise, just default to the maximum number of days:
						ELSE MAX(t.[Days]) 
						END AS [Days],
					CASE 
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP 
						THEN DATEADD(dd, SUM(t.[Days]) - 1, t.BeginDate) 
						END AS EndOrigDate,
					t.EventID, 
					MIN(t.EventMasterID) AS EventMasterID,
					CONVERT(bit, CASE 
									WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
										 MIN(t.ClaimTypeID) = @ClaimTypeP 
									THEN 1
									ELSE 0
									END) AS IsPharmacy,
					ISNULL(NULLIF(FLOOR(CONVERT(decimal(18,6), SUM(t.[Days])) / CONVERT(decimal(18,6), MAX(MV.DispenseQty))), 0), 1) AS MaxRows
			INTO	#KeyEvents
			FROM	#Events AS t
					INNER JOIN Measure.[Events] AS MV
							ON t.EventID = MV.EventID
			GROUP BY t.BeginDate, t.DSMemberID, t.EndDate, t.EventID, 
					CASE 
						WHEN MV.IsSummarized = 0 
						THEN 
								CASE 
									WHEN MV.AllowDaySum = 1 AND
										 (
											MV.DispenseQty IS NOT NULL OR
											t.ClaimTypeID = @ClaimTypeP
										 ) 
									THEN t.EventCritID						
									ELSE t.EventMasterID
									END
						END;
							
			CREATE UNIQUE CLUSTERED INDEX IX_#KeyEvents ON #KeyEvents (EventMasterID, EventID);
			CREATE STATISTICS ST_#KeyEvents ON #KeyEvents (EventMasterID, EventID);
						
			--5) Use KeyEvents to Update Events
			DELETE	V
			FROM	#Events AS V
					LEFT OUTER JOIN #KeyEvents AS KV
							ON V.EventID = KV.EventID AND
								V.EventMasterID = KV.EventMasterID
			WHERE	KV.EventMasterID IS NULL;
			
			UPDATE	V
			SET		ClaimTypeID = KV.ClaimTypeID,
					CountMasterRecords = KV.CountMasterRecords,
					[Days] = ISNULL(KV.[Days], V.[Days]),
					EndOrigDate = ISNULL(KV.EndOrigDate, V.EndOrigDate),
					MaxRows = KV.MaxRows
			FROM	#Events AS V
					INNER JOIN #KeyEvents AS KV
							ON V.EventID = KV.EventID AND
								V.EventMasterID = KV.EventMasterID;
								
			DROP TABLE #KeyEvents;
			

			--6) Apply any additional date-based requirements for the events and copy them to Proxy.Events
			SELECT DISTINCT
					AllowEndDate,
					BeginDate,
					EndDate,
					EventID,
					RequireEndDate
			INTO	#DateEventReqs
			FROM	Proxy.EventKey; 
			
			CREATE UNIQUE CLUSTERED INDEX PK_#DateEventReqs ON #DateEventReqs (EventID);

			SET ANSI_WARNINGS ON;

			INSERT INTO Proxy.[Events]
					(BatchID, BeginDate, BeginOrigDate, ClaimTypeID,
					CodeID, CountClaims, CountCodes, 
					CountLines, CountProviders, 
					DataRunID, DataSetID, 
					[Days], [DispenseID],
					DSClaimID, DSClaimLineID, DSMemberID, DSProviderID,
					EndDate, EndOrigDate, EventCritID, EventID, EventBaseID, IsPaid, Value)
			SELECT	V.BatchID, V.BeginDate, V.BeginOrigDate, V.ClaimTypeID,
					V.CodeID, V.CountClaims, V.CountCodes, 
					V.CountLines, V.CountProviders, 
					@DataRunID, @DataSetID, V.[Days], 
					CASE WHEN V.[Days] IS NOT NULL THEN CONVERT(smallint, T.N) END AS DispenseID,
					V.DSClaimID, V.DSClaimLineID, V.DSMemberID, V.DSProviderID,
					CASE V.ClaimTypeID WHEN @ClaimTypeP THEN NULL ELSE V.EndDate END AS EndDate, 
					V.EndOrigDate, V.EventCritID, V.EventID, V.EventMasterID AS EventBaseID, V.IsPaid, V.Value
			FROM	#DateEventReqs AS DV
					INNER JOIN #Events AS V
							ON DV.EventID = V.EventID AND
								(
									(
										V.ClaimTypeID <> @ClaimTypeE AND
										(
											(DV.BeginDate IS NULL) OR
											(
												DV.BeginDate IS NOT NULL AND 
												DV.BeginDate <= V.BeginDate
											)
										) AND
										(
											(DV.EndDate IS NULL) OR
											(
												DV.EndDate IS NOT NULL AND 
												DV.EndDate >= V.BeginDate
											)
										)
									) OR
									(	
										V.ClaimTypeID = @ClaimTypeE AND
										(	
											(DV.AllowEndDate = 1) OR
											(
												DV.AllowEndDate = 0 AND 
												V.EndDate IS NULL
											)
										) AND
										(
											(DV.RequireEndDate = 0) OR
											(
												DV.RequireEndDate = 1 AND 
												V.EndDate IS NOT NULL
											)
										) AND
										(
											(DV.BeginDate IS NULL) OR
											(
												DV.BeginDate IS NOT NULL AND 
												DV.BeginDate <= COALESCE(V.EndDate, V.BeginDate)
											)
										) AND
										(
											(DV.EndDate IS NULL) OR
											(
												DV.EndDate IS NOT NULL AND 
												DV.EndDate >= COALESCE(V.EndDate, V.BeginDate)
											)
										)
									)
								)
					INNER JOIN dbo.Tally AS T
							ON T.N BETWEEN 1 AND V.MaxRows AND
								T.N BETWEEN 1 AND 32767
			ORDER BY DSMemberID, BeginDate, DSClaimLineID, EventID, CodeID;				

			SELECT @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = ' - Compiling and finalizing events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
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
			SET @LogDescr = ' - Compiling and finalizing events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; 
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID, 
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
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
GRANT EXECUTE ON  [Batch].[CompileEvents_v3] TO [Processor]
GO
