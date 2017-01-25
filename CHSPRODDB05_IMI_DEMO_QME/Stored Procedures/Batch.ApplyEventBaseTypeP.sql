SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/28/2011
-- Description:	Applies additional event base criteria by member, provider and date matching. (v2)
-- =============================================
CREATE PROCEDURE [Batch].[ApplyEventBaseTypeP]
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
		SET @LogObjectName = 'ApplyEventBaseTypeP'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Applying additional member, provider and date event-based details failed!  No batch was specified.', 16, 1);
				
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
			
			---------------------------------------------------------------------------
			DECLARE @ClaimTypeE tinyint;
			--DECLARE @ClaimTypeL tinyint;
			DECLARE @ClaimTypeP tinyint;

			SELECT @ClaimTypeE = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'E';
			--SELECT @ClaimTypeL = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'L';
			SELECT @ClaimTypeP = ClaimTypeID FROM Claim.ClaimTypes WHERE Abbrev = 'P';

			--DECLARE @EventTypeC tinyint;
			--DECLARE @EventTypeL tinyint;
			--DECLARE @EventTypeD tinyint;
			DECLARE @EventTypeP tinyint;

			--SELECT @EventTypeC = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'C';
			--SELECT @EventTypeL = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'L';
			--SELECT @EventTypeD = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'D';
			SELECT @EventTypeP = EventTypeID FROM Measure.EventTypes WHERE Abbrev = 'P';

			DECLARE @BitClaimSrcTypeHighPriority bigint;

			SELECT	@BitClaimSrcTypeHighPriority = SUM(BitValue)
			FROM	Claim.SourceTypes 
			WHERE	Abbrev IN ('P', 'X');

			DECLARE @BitSpecialtiesHighPriority bigint;
			DECLARE @BitSpecialtiesLowPriority bigint;

			SELECT	@BitSpecialtiesHighPriority = SUM(BitValue)
			FROM	Provider.Specialties 
			WHERE	Abbrev IN ('PCP', 'OBGYN', 'MH', 'Neph', 'NPR', 'PAS', 'Prescribe') OR
					Descr IN ('PCP', 'OB/GYN', 'Mental Health', 'Nephrology', 'Nurse Practitioner', 'Physician Assistant', 'Prescribing Privileges');

			SELECT	@BitSpecialtiesLowPriority = SUM(BitValue)
			FROM	Provider.Specialties 
			WHERE	Abbrev IN ('Anesth', 'Hosp', 'SNF', 'DME', 'AMB') OR
					Descr IN ('Anesthesiology', 'Hospital', 'Skilled Nursing Facility', 'Durable Medical Equipment', 'Ambulance');
			----------------------------------------------------------------------------
						
			--1) Retrieve the filtered event key...
			SELECT	*
			INTO	#EventKey
			FROM	Proxy.EventKey 
			WHERE	(EventTypeID = @EventTypeP) AND
					(EventID IN (SELECT DISTINCT EventID FROM Proxy.EventBase)) AND
					(RankOrder > 1);				
					
			CREATE UNIQUE CLUSTERED INDEX IX_#EventKey ON #EventKey (CodeID, BitSpecialtiesAllowed, BitSpecialtiesDenied, EventCritCodeID, EventID, OptionNbr);

			--2) Identify additional event criteria...	
			--EVENT TYPE P: Matched on DSMemberID, DSProviderID and BeginDate/EndDate
			IF EXISTS(SELECT TOP (1) 1 AS N FROM Proxy.EventKey WHERE EventTypeID = @EventTypeP)
				BEGIN;
					--2a) Import the portion of EventBase related this event type and having multiple criteria...
					SELECT	--Unique per event type			
							BeginDate, 
							DSMemberID,
							DSProviderID,
							EndDate,

							--Same for all event types
							EventBaseID,
							EventID,  
							OptionNbr
					INTO	#InitEventBase
					FROM	Proxy.EventBase
					WHERE	(CountCriteria > 1) AND
							(RankOrder = 1) AND
					
							--Event type specific WHERE clause
							(EventTypeID = @EventTypeP);
							
					CREATE CLUSTERED INDEX IX_#InitEventBase ON #InitEventBase (DSMemberID, DSProviderID, BeginDate, EndDate, EventID, OptionNbr);
					
					--2b) Create intermediary temp table...
					CREATE TABLE #EventBase
					(
						Allow bit NOT NULL,
						BatchID int NOT NULL,
						BeginDate datetime NOT NULL,
						BitClaimAttribs bigint NOT NULL DEFAULT(0),
						BitClaimSrcTypes bigint NOT NULL DEFAULT(0),
						BitSpecialties bigint NOT NULL DEFAULT(0),
						ClaimTypeID tinyint NULL,
						Code varchar(16) NULL,
						CodeID int NULL,
						CodeTypeID tinyint NULL,
						CountAllowed int NULL,
						CountCriteria int NULL,
						CountDenied int NULL,
						DataRunID int NOT NULL,
						DataSetID int NOT NULL,
						DataSourceID int NULL,
						[Days] smallint NULL,
						DSClaimCodeID bigint NOT NULL,
						DSClaimID bigint NULL,
						DSClaimLineiD bigint NULL,
						DSMemberID bigint NOT NULL,
						DSProviderID bigint NULL,
						EndDate datetime NULL,
						EventBaseID bigint NOT NULL,
						EventCritID int NOT NULL,
						EventID int NOT NULL,
						EventTypeID tinyint NOT NULL,
						IsPaid bit NOT NULL,
						IsSupplemental bit NOT NULL,
						OptionNbr tinyint NOT NULL,
						RankOrder smallint NOT NULL,
						Value decimal(18, 6) NULL
					);
					
					--2c) Identify secondary base event records...
					INSERT INTO #EventBase
							(Allow,
							BatchID,
							BeginDate,
							CountAllowed,
							CountCriteria,
							CountDenied,
							DataRunID,
							DataSetID,
							[Days],
							DSClaimCodeID,
							DSMemberID,
							DSProviderID,
							EndDate,
							EventBaseID,
							EventCritID,
							EventID,
							EventTypeID,
							IsPaid,
							IsSupplemental,
							OptionNbr,
							RankOrder,
							Value)
					SELECT	CONVERT(bit, MIN(CONVERT(int, TEK.Allow))) AS Allow,
							@BatchID AS BatchID,
							--MIN(ISNULL(CS.ClaimBeginDate, CS.BeginDate)) AS BeginDate,
							MIN(CS.BeginDate) AS BeginDate, --Changed 2/20/2014 as part of claim combining update
							MIN(TEK.CountAllowed) AS CountAllowed,
							MIN(TEK.CountCriteria) AS CountCriteria,
							MIN(TEK.CountDenied) AS CountDenied,
							@DataRunID AS DataRunID,
							@DataSetID AS DataSetID,
							MAX(CONVERT(smallint, ISNULL(TEK.DefaultDays, CASE WHEN TEK.ClaimTypeID IN (@ClaimTypeE, @ClaimTypeP) THEN CASE WHEN CS.[Days] BETWEEN 0 AND (365 * 5) + 1 THEN CS.[Days] ELSE 0 END END))) AS [Days],
							COALESCE( 
								--IMPORTANT:  Becareful about changing.  Determines best possible code to choose for most robust reporting, considers supplemental data flag, provider specialties and claim source type (professsional/unknown vs. institutional)...
								--1) Before other considerations, pull code from claim with provider specialty, if provider specialty requirements are set
								MIN(CASE WHEN CS.IsSupplemental = 0 AND TEK.BitSpecialtiesAllowed > 0 AND CS.BitSpecialties & TEK.BitSpecialtiesAllowed > 0 THEN CS.DSClaimCodeID END), 
								--2) Without Supplemental Data, With Preferred Claim Source Types, With Preferred Provider Specialties...
								MIN(CASE WHEN CS.IsSupplemental = 0 AND CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 AND CS.BitSpecialties & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--3) Without Supplemental Data, With Preferred Claim Source Types, Without Non-Preferred Provider Specialties...
								MIN(CASE WHEN CS.IsSupplemental = 0 AND CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 AND CS.BitSpecialties & @BitSpecialtiesLowPriority = 0 THEN CS.DSClaimCodeID END), 
								--4) Without Supplemental Data, With Preferred Provider Specialties...
								MIN(CASE WHEN CS.IsSupplemental = 0 AND CS.BitSpecialties & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--5) Without Supplemental Data, With Preferred Claim Source Types...
								MIN(CASE WHEN CS.IsSupplemental = 0 AND CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--6) Without Supplemental Data, Without Non-Preferred Provider Specialties...
								MIN(CASE WHEN CS.IsSupplemental = 0 AND CS.BitSpecialties & @BitSpecialtiesLowPriority = 0 THEN CS.DSClaimCodeID END), 
								--7) Without Supplemental Data, Without Non-Preferred Provider Specialties...
								MIN(CASE WHEN CS.IsSupplemental = 0 THEN CS.DSClaimCodeID END), 
								--8) Before other considerations, pull code from claim with provider specialty, if provider specialty requirements are set
								MIN(CASE WHEN TEK.BitSpecialtiesAllowed > 0 AND CS.BitSpecialties & TEK.BitSpecialtiesAllowed > 0 THEN CS.DSClaimCodeID END), 
								--9) With Supplemental Data, With Preferred Claim Source Types, With Preferred Provider Specialties...
								MIN(CASE WHEN CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 AND CS.BitSpecialties & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--10) With Supplemental Data, With Preferred Claim Source Types, Without Non-Preferred Provider Specialties...
								MIN(CASE WHEN CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 AND CS.BitSpecialties & @BitSpecialtiesLowPriority = 0 THEN CS.DSClaimCodeID END), 
								--11) With Supplemental Data, With Preferred Provider Specialties...
								MIN(CASE WHEN CS.BitSpecialties & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--12) With Supplemental Data, With Preferred Claim Source Types...
								MIN(CASE WHEN CS.BitClaimSrcTypes & @BitSpecialtiesHighPriority > 0 THEN CS.DSClaimCodeID END), 
								--13) With Supplemental Data, Without Non-Preferred Provider Specialties...
								MIN(CASE WHEN CS.BitSpecialties & @BitSpecialtiesLowPriority = 0 THEN CS.DSClaimCodeID END), 
								--Last) Default, Take whatever...
								MIN(CS.DSClaimCodeID)
							) AS DSClaimCodeID,
							MIN(CS.DSMemberID) AS DSMemberID,
							CASE WHEN COUNT(DISTINCT CS.DSProviderID) = 1 OR MIN(TEK.BitSpecialtiesAllowed) > 0 THEN MIN(CS.DSProviderID) END AS DSProviderID,
							--MAX(COALESCE(DATEADD(dd, TEK.DefaultDays - 1, ISNULL(CS.ClaimBeginDate, CS.BeginDate)), CS.ClaimEndDate, CS.EndDate)) AS EndDate, 
							MAX(COALESCE(DATEADD(dd, TEK.DefaultDays - 1, CS.BeginDate), CS.EndDate)) AS EndDate, --Changed 2/20/2014 as part of claim combining update
							VB.EventBaseID,
							TEK.EventCritID,
							TEK.EventID,
							TEK.EventTypeID,
							CONVERT(bit, MIN(CONVERT(tinyint, CS.IsPaid))) AS IsPaid,
							CONVERT(bit, MIN(CONVERT(tinyint, CS.IsSupplemental))) AS IsSupplemental,
							TEK.OptionNbr,
							TEK.RankOrder,
							--Nested ISNULLs instead of COALESCE to preserve data type 
							MIN(CAST(CASE TEK.ValueTypeID 
									WHEN 1 THEN ISNULL(TEK.Value, ISNULL(CS.LabValue, TEK.DefaultValue))
									WHEN 2 THEN ISNULL(TEK.Value, ISNULL(CAST(CS.IsPositive AS decimal(18,6)), TEK.DefaultValue))
									WHEN 3 THEN ISNULL(TEK.Value * CS.QtyDispensed / NULLIF(CS.[Days], 0), TEK.DefaultValue)
									WHEN 4 THEN ISNULL(CONVERT(decimal(18,6), FLOOR(CS.QtyDispensed / NULLIF(TEK.Value, 0))), TEK.DefaultValue)
									END AS decimal(18,6))) AS Value
					FROM	Internal.ClaimSource AS CS WITH(INDEX (IX_Internal_ClaimSource_CodeID))
							INNER JOIN #EventKey AS TEK WITH (INDEX (IX_#EventKey))
									ON	((TEK.CodeID = -2147483648) OR (CS.CodeID = TEK.CodeID)) AND
									
										--Filter Encounter-based Lab *Requests*, if applicable
										((TEK.AllowLab = 1) OR ((TEK.AllowLab = 0) AND (CS.IsLab = 0))) AND
										
										--Filter Encounter-based Supplemental Data, if applicable
										((TEK.AllowSupplemental = 1) OR ((TEK.AllowSupplemental = 0) AND (CS.IsSupplemental = 0))) AND

										--Filter Paid Claims, if applicable
										((TEK.RequirePaid = 0) OR ((TEK.RequirePaid = 1) AND (CS.IsPaid = 1))) AND
										
										--Filter Enrolled claims, if applicable
										((TEK.RequireEnrolled = 0) OR ((TEK.RequireEnrolled = 1) AND (CS.IsEnrolled = 1))) AND
										
										--Filter Primary diagnoses/procedures, if applicable
										((TEK.RequirePrimary = 0) OR ((TEK.RequirePrimary = 1) AND (CS.IsPrimary = 1))) AND
										
										--Filter "Only" code claims, if applicable
										((TEK.RequireOnly = 0) OR ((TEK.RequireOnly = 1) AND (CS.IsOnly = 1))) AND
										
										--Filter expired criteria, if applicable
										((TEK.[ExpireDate] IS NULL) OR (TEK.[ExpireDate] >= CS.BeginDate) OR (TEK.[ExpireDate] >= CS.EndDate)) AND
																				
										--Filter Claim Attribute requirements, if applicable...
										((TEK.BitClaimAttribsAllowed = 0) OR (TEK.BitClaimAttribsAllowed & CS.BitClaimAttribs > 0)) AND
										((TEK.BitClaimAttribsDenied = 0) OR (TEK.BitClaimAttribsDenied & CS.BitClaimAttribs = 0)) AND
										
										--Filter Claim Source Type requirements, if applicable...
										((TEK.BitClaimSrcTypesAllowed = 0) OR (TEK.BitClaimSrcTypesAllowed & CS.BitClaimSrcTypes > 0)) AND
										((TEK.BitClaimSrcTypesDenied = 0) OR (TEK.BitClaimSrcTypesDenied & CS.BitClaimSrcTypes = 0)) AND
										
										--Filter Provider Specialty requirements, if applicable...
										((TEK.BitSpecialtiesAllowed = 0) OR (TEK.BitSpecialtiesAllowed & CS.BitSpecialties > 0)) AND
										((TEK.BitSpecialtiesDenied = 0) OR (TEK.BitSpecialtiesDenied & CS.BitSpecialties = 0)) AND
										
										--Filter Member Demographic requirements, if applicable...
										(
											(TEK.HasMemberReqs = 0) OR
											(
												--Gender restrictions...
												((TEK.Gender IS NULL) OR (TEK.Gender = CS.Gender)) AND
												
												--Date of Birth restrictions...
												(	
													(TEK.AfterDOBDays IS NULL) OR 
													(TEK.AfterDOBMonths IS NULL) OR
													(
														(DATEADD(day, TEK.AfterDOBDays, DATEADD(month, TEK.AfterDOBMonths, CS.DOB)) <= CS.BeginDate) AND
														(
															(CS.EndDate IS NULL) OR 
															(DATEADD(day, TEK.AfterDOBDays, DATEADD(month, TEK.AfterDOBMonths, CS.DOB)) <= CS.EndDate)
														)
													)
												)
											)
										)
							INNER JOIN #InitEventBase AS VB
									ON TEK.EventID = VB.EventID AND
										TEK.OptionNbr = VB.OptionNbr AND
										
										--Unique JOIN criteria per event type 
										CS.DSMemberID = VB.DSMemberID AND
										(
											(CS.DSProviderID = VB.DSProviderID) OR
											(CS.DSProviderID IS NULL) OR
											(VB.DSProviderID IS NULL)
										) AND
										(
											--Option removed 2/20/2014 as part of claim combining update
											/*(
												--(CS.DSClaimID IS NOT NULL) AND 
												--(
													(CS.ClaimBeginDate BETWEEN DATEADD(day, 1, VB.BeginDate) AND DATEADD(day, -1, VB.EndDate) AND VB.EndDate IS NOT NULL) OR
													(CS.ClaimEndDate BETWEEN DATEADD(day, 1, VB.BeginDate) AND DATEADD(day, -1, VB.EndDate) AND VB.EndDate IS NOT NULL) OR
													(CS.ClaimEndDate = VB.EndDate) OR
													(CS.ClaimBeginDate = VB.BeginDate) OR
													(VB.BeginDate BETWEEN DATEADD(day, 1, CS.ClaimBeginDate) AND DATEADD(day, -1, CS.ClaimEndDate) AND CS.ClaimEndDate IS NOT NULL) OR
													(VB.EndDate BETWEEN DATEADD(day, 1, CS.ClaimBeginDate) AND DATEADD(day, -1, CS.ClaimEndDate) AND CS.ClaimEndDate IS NOT NULL)
												--)
											) OR */
											(
												--(CS.DSClaimID IS NULL) AND		
												--(
													(CS.BeginDate BETWEEN DATEADD(day, 1, VB.BeginDate) AND DATEADD(day, -1, VB.EndDate) AND VB.EndDate IS NOT NULL) OR
													(CS.EndDate BETWEEN DATEADD(day, 1, VB.BeginDate) AND DATEADD(day, -1, VB.EndDate) AND VB.EndDate IS NOT NULL) OR
													(CS.EndDate = VB.EndDate) OR
													(CS.BeginDate = VB.BeginDate AND CS.EndDate IS NULL AND VB.EndDate IS NULL) OR
													(VB.BeginDate BETWEEN DATEADD(day, 1, CS.BeginDate) AND DATEADD(day, -1, CS.EndDate) AND CS.EndDate IS NOT NULL) OR
													(VB.EndDate BETWEEN DATEADD(day, 1, CS.BeginDate) AND DATEADD(day, -1, CS.EndDate) AND CS.EndDate IS NOT NULL)
												--)
											)
										)
					WHERE	(CS.SpId = @@SPID) AND
							(CS.BatchID = @BatchID)
					GROUP BY VB.EventBaseID, 
							TEK.EventCritID,
							TEK.EventID,
							TEK.EventTypeID,
							TEK.OptionNbr,
							TEK.RankOrder
					OPTION (FORCE ORDER);
							
					DROP TABLE #EventKey;
					DROP TABLE #InitEventBase;
																		
					--2d) Update Claim/Code fields...
					CREATE UNIQUE CLUSTERED INDEX IX_#EventBase ON #EventBase (DSClaimCodeID, EventBaseID, RankOrder);
					
					UPDATE	VB
					SET		BitClaimAttribs = CS.BitClaimAttribs,
							BitClaimSrcTypes = CS.BitClaimSrcTypes,							
							BitSpecialties = CS.BitSpecialties,
							ClaimTypeID = CS.ClaimTypeID,
							Code = CS.Code,
							CodeID = CS.CodeID, 
							CodeTypeID = CS.CodeTypeID,
							DataSourceID = CS.DataSourceID,
							DSClaimID = CS.DSClaimID,
							DSClaimLineID = CS.DSClaimLineID,
							DSProviderID = CS.DSProviderID,
							IsSupplemental = CS.IsSupplemental
					FROM	#EventBase AS VB WITH(INDEX(IX_#EventBase))
							INNER JOIN Internal.ClaimSource AS CS WITH(INDEX(1))
									ON VB.DSClaimCodeID = CS.DSClaimCodeID
					WHERE	(CS.SpId = @@SPID) AND
							(CS.BatchID = @BatchID);
								
					DROP INDEX IX_#EventBase ON #EventBase;
					
					--2e) Insert the records into the real table...
					CREATE UNIQUE CLUSTERED INDEX IX_#EventBase ON #EventBase (EventBaseID, RankOrder);
					
					INSERT INTO Proxy.EventBase
							(Allow,
							BatchID,
							BeginDate,
							BitClaimAttribs,
							BitClaimSrcTypes,
							BitSpecialties,
							ClaimTypeID,
							Code,
							CodeID,
							CodeTypeID,
							CountAllowed,
							CountCriteria,
							CountDenied,
							DataRunID,
							DataSetID,
							DataSourceID,
							[Days],
							DSClaimCodeID,
							DSClaimID,
							DSClaimLineID,
							DSMemberID,
							DSProviderID,
							EndDate,
							EventBaseID,
							EventCritID,
							EventID,
							EventTypeID,
							IsPaid,
							IsSupplemental,
							OptionNbr,
							RankOrder,
							Value)
					SELECT	Allow,
							BatchID,
							BeginDate,
							BitClaimAttribs,
							BitClaimSrcTypes,
							BitSpecialties,
							ClaimTypeID,
							Code,
							CodeID,
							CodeTypeID,
							CountAllowed,
							CountCriteria,
							CountDenied,
							DataRunID,
							DataSetID,
							DataSourceID,
							[Days],
							DSClaimCodeID,
							DSClaimID,
							DSClaimLineID,
							DSMemberID,
							DSProviderID,
							EndDate,
							EventBaseID,
							EventCritID,
							EventID,
							EventTypeID,
							IsPaid,
							IsSupplemental,
							OptionNbr,
							RankOrder,
							Value
					FROM	#EventBase
					ORDER BY EventBaseID, RankOrder;												
				END;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = ' - Applying additional member, provider and date event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Applying additional member, provider and date event-based details for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' refresh failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Batch].[ApplyEventBaseTypeP] TO [Processor]
GO
