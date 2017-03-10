SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/24/2012
-- Description:	Compiles base event records to form events. (v4)
-- =============================================
CREATE PROCEDURE [Batch].[CompileEvents_v4]
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
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
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
			DECLARE @ClaimTypeS tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';
			SELECT @ClaimTypeS = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'S';

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

			IF OBJECT_ID('tempdb..#EventMasters') IS NOT NULL
				DROP TABLE #EventMasters;
			
			--1) Identify the successful options...
			SELECT DISTINCT
					PVB.EventBaseID, 
					MIN(PVB.EventTypeID) AS EventTypeID,
					MV.IsSummarized
			INTO	#ValidEventBase
			FROM	Proxy.EventBase AS PVB
					INNER JOIN Measure.[Events] AS MV
							ON MV.EventID = PVB.EventID
			GROUP BY PVB.EventBaseID,
					PVB.EventID,
					MV.IsSummarized,
					PVB.OptionNbr 
			HAVING	(COUNT(DISTINCT CASE WHEN PVB.Allow = 1 THEN PVB.EventCritID END) >= MAX(CountAllowed)) AND
					(COUNT(DISTINCT CASE WHEN PVB.Allow = 0 THEN PVB.EventCritID END) = 0);
			
			CREATE UNIQUE CLUSTERED INDEX IX_#ValidEventBase ON #ValidEventBase (EventTypeID, EventBaseID);

			--2) Identify the key event base records by event type...
			CREATE TABLE #KeyEventBase
			(
				EventBaseID bigint NOT NULL
			);
		
			--2a) Event Type C: Psuedo-Claim Level
			INSERT INTO #KeyEventBase
			        (EventBaseID)
			SELECT DISTINCT
					MIN(VVB.EventBaseID) AS EventBaseID
			FROM	#ValidEventBase AS VVB
					INNER JOIN Proxy.EventBase AS PVB
							ON VVB.EventBaseID = PVB.EventBaseID AND
								PVB.RankOrder = 1
			WHERE	(VVB.EventTypeID = @EventTypeC)
			GROUP BY PVB.DSClaimID, PVB.EventID, CASE WHEN VVB.IsSummarized = 0 THEN PVB.EventCritID END;
			
			--2b) Event Type D: Member/Date Level
			INSERT INTO #KeyEventBase
			        (EventBaseID)
			SELECT DISTINCT
					MIN(VVB.EventBaseID) AS EventBaseID
			FROM	#ValidEventBase AS VVB
					INNER JOIN Proxy.EventBase AS PVB
							ON VVB.EventBaseID = PVB.EventBaseID AND
								PVB.RankOrder = 1
			WHERE	(VVB.EventTypeID = @EventTypeD)
			GROUP BY PVB.DSMemberID, ISNULL(PVB.EndDate, PVB.BeginDate), PVB.EventID, CASE WHEN VVB.IsSummarized = 0 THEN PVB.EventCritID END;
			
			--2c) Event Type L: Claim Line Level
			INSERT INTO #KeyEventBase
			        (EventBaseID)
			SELECT DISTINCT
					MIN(VVB.EventBaseID) AS EventBaseID
			FROM	#ValidEventBase AS VVB
					INNER JOIN Proxy.EventBase AS PVB
							ON VVB.EventBaseID = PVB.EventBaseID AND
								PVB.RankOrder = 1
			WHERE	(VVB.EventTypeID = @EventTypeL)
			GROUP BY PVB.DSClaimLineID, PVB.EventID, CASE WHEN VVB.IsSummarized = 0 THEN PVB.EventCritID END;

			--2d) Event Type P: Member/Provider/Date Level
			INSERT INTO #KeyEventBase
			        (EventBaseID)
			SELECT DISTINCT
					MIN(VVB.EventBaseID) AS EventBaseID
			FROM	#ValidEventBase AS VVB
					INNER JOIN Proxy.EventBase AS PVB
							ON VVB.EventBaseID = PVB.EventBaseID AND
								PVB.RankOrder = 1
			WHERE	(VVB.EventTypeID = @EventTypeP)
			GROUP BY PVB.DSMemberID, DSProviderID, ISNULL(PVB.EndDate, PVB.BeginDate), PVB.EventID, CASE WHEN VVB.IsSummarized = 0 THEN PVB.EventCritID END;

			CREATE UNIQUE CLUSTERED INDEX IX_#KeyEventBase ON #KeyEventBase (EventBaseID);

			DROP TABLE #ValidEventBase;
			

			--3) Combine Event Base records into Event records...
			SELECT	MIN(VB.BeginDate) AS BeginDate,
					MIN(VB.BeginDate) AS BeginOrigDate,
					MAX(VB.ClaimTypeID) AS ClaimTypeID,
					ISNULL(MIN(CASE WHEN VB.RankOrder = 1 THEN VB.CodeID END), MIN(VB.CodeID)) AS CodeID,
					ISNULL(CASE WHEN MIN(VB.ClaimTypeID) = @ClaimTypeP THEN NULL ELSE MAX(VB.EndDate) END, MIN(VB.BeginDate)) AS CompareDate,
					COUNT(DISTINCT VB.DSClaimID) AS CountClaims,
					COUNT(DISTINCT VB.CodeID) AS CountCodes,
					COUNT(DISTINCT VB.DSClaimLineID) AS CountLines,
					CONVERT(int, NULL) AS CountMasterRecords,
					COUNT(DISTINCT VB.DSProviderID) AS CountProviders,
					CASE WHEN COUNT(*) = COUNT(DISTINCT VB.DSClaimLineID) THEN SUM(VB.[Days]) ELSE MAX(VB.[Days]) END AS [Days],
					MIN(DataSourceID) AS DataSourceID,
					MIN(VB.DSClaimID) AS DSClaimID,
					MIN(VB.DSClaimLineID) AS DSClaimLineID,
					MIN(VB.DSMemberID) AS DSMemberID,
					CASE WHEN COUNT(DISTINCT VB.DSProviderID) = 1 THEN MIN(VB.DSProviderID) END AS DSProviderID,
					CASE WHEN MIN(VB.ClaimTypeID) = @ClaimTypeP THEN NULL ELSE MAX(VB.EndDate) END AS EndDate,
					MAX(VB.EndDate) AS EndOrigDate,
					VK.EventBaseID,
					CASE WHEN COUNT(DISTINCT VB.EventCritID) = 1 THEN MIN(VB.EventCritID) END AS EventCritID,
					MIN(VB.EventID) AS EventID,
					CAST(MIN(CAST(VB.IsPaid AS smallint)) AS bit) AS IsPaid,
					CONVERT(int, NULL) AS MaxRows,
					COALESCE(MIN(CASE WHEN RankOrder = 1 THEN Value END), MIN(Value)) AS Value
			INTO	#Events
			FROM	Proxy.EventBase AS VB
					INNER JOIN #KeyEventBase AS VK
							ON VB.EventBaseID = VK.EventBaseID 
			GROUP BY VK.EventBaseID; 
			
			CREATE UNIQUE CLUSTERED INDEX IX_#Events ON #Events (EventID, EventBaseID);
			
			--4) Identify "key" event records to further summarize events and reduce redundant entries
			SELECT DISTINCT AllowSum, EventCritID, ValueTypeID INTO #EventCriteriaConfig FROM Measure.EventCriteria WHERE (AllowSum = 0 OR ValueTypeID IS NOT NULL) AND MeasureSetID = @MeasureSetID;
			CREATE UNIQUE CLUSTERED INDEX IX#EventCriteriaConfig ON #EventCriteriaConfig (EventCritID);

			SELECT	COUNT(DISTINCT t.EventBaseID) AS CountBaseRecords, 
					CASE 
						WHEN MAX(CASE WHEN t.ClaimTypeID = @ClaimTypeS THEN 1 ELSE 0 END) = 1
						THEN @ClaimTypeS --Make sure the "Supplemental Data" is tracked appropriately
						WHEN MAX(t.ClaimTypeID) = MIN(t.ClaimTypeID) 
						THEN MIN(t.ClaimTypeID)
						END AS ClaimTypeID,
					MIN(t.DataSourceID) AS DataSourceID,
					CASE 
						--If the "key" event grouping is 100% Pharmacy Claims, then...:
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP AND 
							 MAX(CONVERT(smallint, MV.AllowDaySum)) = 1
						THEN SUM(t.[Days]) 
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP AND 
							 MAX(CONVERT(smallint, MV.AllowDaySum)) = 0
						THEN MAX(t.[Days]) 
						--If the "key" event grouping is 100% Encounter Claims, then calculate the new length of stay:
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeE AND
							 MIN(t.ClaimTypeID) = @ClaimTypeE AND
							 --1 = 2 AND --Added for IPU 2014, incorrectly counting paid days
							 t.EndDate IS NOT NULL
						THEN MAX(ISNULL(NULLIF(DATEDIFF(dd, t.BeginDate, t.EndDate), 0), 1))
						--Otherwise, just default to the maximum number of days:
						ELSE MAX(t.[Days]) 
						END AS [Days],
					CASE 
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP AND 
							 MAX(CONVERT(smallint, MV.AllowDaySum)) = 1
						THEN DATEADD(dd, SUM(t.[Days]) - 1, t.BeginDate) 
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP AND 
							 MAX(CONVERT(smallint, MV.AllowDaySum)) = 0
						THEN DATEADD(dd, MAX(t.[Days]) - 1, t.BeginDate) 
						END AS EndOrigDate,
					t.EventID, 
					MIN(t.EventBaseID) AS EventBaseID,
					CONVERT(bit, CASE 
									WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
										 MIN(t.ClaimTypeID) = @ClaimTypeP 
									THEN 1
									ELSE 0
									END) AS IsPharmacy,
					COALESCE(NULLIF(FLOOR(CONVERT(decimal(18,6), SUM(t.[Days])) / CONVERT(decimal(18,6), MAX(MV.DispenseQty))), 0), 
						SUM(CASE VCC.ValueTypeID 
							WHEN 4 THEN t.Value
							END),
						1) AS MaxRows,
					CASE 
						WHEN MAX(t.ClaimTypeID) = @ClaimTypeP AND 
							 MIN(t.ClaimTypeID) = @ClaimTypeP  
						THEN SUM(Value)
						END AS Value
			INTO	#KeyEvents
			FROM	#Events AS t
					INNER JOIN Measure.[Events] AS MV
							ON t.EventID = MV.EventID
					LEFT OUTER JOIN #EventCriteriaConfig AS VCC
							ON t.EventCritID = VCC.EventCritID                        
			GROUP BY t.BeginDate, t.DSMemberID, t.EndDate, t.EventID, 
					CASE 
						WHEN MV.IsSummarized = 0 
						THEN 
								CASE 
									WHEN MV.AllowDaySum = 1 AND
										 (
											VCC.EventCritID IS NULL OR
											VCC.AllowSum = 1 
										 ) AND
										 (
											MV.DispenseQty IS NOT NULL OR
											t.ClaimTypeID = @ClaimTypeP
										 ) 
									THEN t.EventCritID						
									ELSE t.EventBaseID
									END
						END;
						
			DROP INDEX IX_#Events ON #Events;
					
			CREATE UNIQUE CLUSTERED INDEX IX_#Events ON #Events (EventBaseID);
			CREATE UNIQUE CLUSTERED INDEX IX_#KeyEvents ON #KeyEvents (EventBaseID);	
						
			--5) Use KeyEvents to update Events
			DELETE	V
			FROM	#Events AS V
					LEFT OUTER JOIN #KeyEvents AS KV
							ON V.EventBaseID = KV.EventBaseID
			WHERE	(KV.EventBaseID IS NULL);
			
			UPDATE	V
			SET		ClaimTypeID = KV.ClaimTypeID,
					DataSourceID = KV.DataSourceID,
					[Days] = CASE WHEN ISNULL(KV.[Days], V.[Days]) > 32767 THEN 32767 ELSE ISNULL(KV.[Days], V.[Days]) END,
					EndOrigDate = ISNULL(KV.EndOrigDate, V.EndOrigDate),
					MaxRows = KV.MaxRows,
					Value = ISNULL(KV.Value, V.Value)
			FROM	#Events AS V
					INNER JOIN #KeyEvents AS KV
							ON V.EventBaseID = KV.EventBaseID;
								
			DROP TABLE #KeyEvents;
			
			DROP INDEX IX_#Events ON #Events;

			CREATE UNIQUE CLUSTERED INDEX IX_#Events ON #Events (EventID, CompareDate, EventBaseID);
			
			--6) Apply any additional date-based requirements for the events and copy them to Proxy.Events
			SELECT DISTINCT
					BeginDate,
					EndDate,
					EventID
			INTO	#EventKey
			FROM	Proxy.EventKey; 
			
			CREATE UNIQUE CLUSTERED INDEX IX_#EventKey ON #EventKey (EventID, BeginDate, EndDate);

			SET ANSI_WARNINGS ON;

			INSERT INTO Proxy.[Events]
					(BatchID, BeginDate, BeginOrigDate, ClaimTypeID,
					CodeID, CountClaims, CountCodes, 
					CountLines, CountProviders, 
					DataRunID, DataSetID, DataSourceID,
					[Days], [DispenseID],
					DSClaimID, DSClaimLineID, DSMemberID, DSProviderID,
					EndDate, EndOrigDate, EventBaseID, EventCritID, EventID, IsPaid, Value)
			SELECT	@BatchID, V.BeginDate, V.BeginOrigDate, V.ClaimTypeID,
					V.CodeID, V.CountClaims, V.CountCodes, 
					V.CountLines, V.CountProviders, 
					@DataRunID, @DataSetID, DataSourceID, V.[Days], 
					CASE WHEN V.[Days] IS NOT NULL THEN CONVERT(smallint, T.N) END AS DispenseID,
					V.DSClaimID, V.DSClaimLineID, V.DSMemberID, V.DSProviderID,
					CASE V.ClaimTypeID WHEN @ClaimTypeP THEN NULL ELSE V.EndDate END AS EndDate, 
					V.EndOrigDate, V.EventBaseID, V.EventCritID, V.EventID, V.IsPaid, V.Value
			FROM	#EventKey AS VK
					INNER JOIN #Events AS V
							ON VK.EventID = V.EventID AND	
								(
									(VK.BeginDate IS NULL) OR
									(
										VK.BeginDate IS NOT NULL AND 
										VK.BeginDate <= V.CompareDate
									)
								) AND
								(
									(VK.EndDate IS NULL) OR
									(
										VK.EndDate IS NOT NULL AND 
										VK.EndDate >= V.CompareDate
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
			SET @LogDescr = ' - Compiling and finalizing events for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Batch].[CompileEvents_v4] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CompileEvents_v4] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CompileEvents_v4] TO [Processor]
GO
