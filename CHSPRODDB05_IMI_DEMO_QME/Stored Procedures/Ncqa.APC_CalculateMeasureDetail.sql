SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/22/2016
-- Description:	Calculates the detailed results of the APC measure. (v2)
--				(Updated to address different events for the denominator and the numerator, due to supplemental data requirements.)
-- =============================================
CREATE PROCEDURE [Ncqa].[APC_CalculateMeasureDetail]
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
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;

	BEGIN TRY;
			
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
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'APC_CalculateMeasureDetail'; 
		SET @LogObjectSchema = 'Ncqa'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;

			--i) FOR DEBUGGING, the member to test...
			DECLARE @CustomerMemberID varchar(50);
			SET @CustomerMemberID = NULL; --Set for debugging

			DECLARE @DSMemberID int;
			IF @CustomerMemberID IS NOT NULL AND
				EXISTS (
							SELECT TOP 1 
									1 
							FROM	Engine.Settings AS ES 
									INNER JOIN Engine.Types AS ET 
											ON ET.EngineTypeID = ES.EngineTypeID 
							WHERE	(ES.EngineID = 1) AND 
									(ET.Descr = 'Certification')
						)
				SELECT @DSMemberID = DSMemberID FROM Member.Members WITH(NOLOCK) WHERE CustomerMemberID = @CustomerMemberID AND DataSetID = @DataSetID;

			--ii) The gap allowed for the two or more concurrent events numerator...
			DECLARE @AllowableGapDaysTwoOrMore int;
			SET @AllowableGapDaysTwoOrMore = 15;

			--1a) Identify the key EventID for the antipsychotic medication dispensing events...
			DECLARE @MapTypeDenominator tinyint;
			DECLARE @MapTypeNumerator tinyint;

			SELECT @MapTypeDenominator = MapTypeID FROM Measure.MappingTypes WHERE MapTypeGuid = '1615D299-5BA1-4455-AE77-BE49646F54A4';
			SELECT @MapTypeNumerator = MapTypeID FROM Measure.MappingTypes WHERE MapTypeGuid = '376C404D-C8EF-4716-9296-909A0BE6ADD4';

			DECLARE @DenominatorEventID int;
			DECLARE @NumeratorEventID int;
			DECLARE @KeyMetricID int;

			SELECT	@DenominatorEventID = CASE WHEN METMM.MapTypeID = @MapTypeDenominator THEN MV.EventID ELSE @DenominatorEventID END,
					@KeyMetricID = MX.MetricID,
					@NumeratorEventID = CASE WHEN METMM.MapTypeID = @MapTypeNumerator THEN MV.EventID ELSE @NumeratorEventID END
			FROM	Measure.EntityCriteria AS MEC
					INNER JOIN Measure.DateComparers AS MDC
							ON MDC.DateComparerID = MEC.DateComparerID
					INNER JOIN Measure.DateComparerTypes AS MDCT
							ON MDCT.DateCompTypeID = MDC.DateCompTypeID
					INNER JOIN Measure.Entities AS ME
							ON ME.EntityID = MEC.EntityID
					INNER JOIN Measure.EntityToMetricMapping AS METMM
							ON METMM.EntityID = MEC.EntityID
					INNER JOIN Measure.Metrics AS MX
							ON MX.MetricID = METMM.MetricID
					INNER JOIN Measure.Measures AS MM
							ON MM.MeasureID = MX.MeasureID 
					INNER JOIN Measure.[Events] AS MV
							ON MV.EventID = MEC.DateComparerInfo
			WHERE	MDCT.Abbrev = 'V' AND
					ME.IsEnabled = 1 AND
					ME.MeasureSetID = @MeasureSetID AND
					MEC.IsEnabled = 1 AND
					MEC.RankOrder = 1 AND
					MEC.IsInit = 1 AND
					MEC.IsForIndex = 1 AND
					MM.IsEnabled = 1 AND
					MM.MeasureSetID = @MeasureSetID AND
					MX.Abbrev = 'APC' AND
					MX.IsEnabled = 1 AND
					MV.MeasureSetID = @MeasureSetID;

			--1b) Identify the members in the APC eligible population...
			IF OBJECT_ID('tempdb..#MemberList') IS NOT NULL
				DROP TABLE #MemberList;

			SELECT	RMD.DSMemberID, RMD.ResultRowID
			INTO	#MemberList
			FROM	Result.MeasureDetail AS RMD
			WHERE	RMD.BatchID = @BatchID AND
					RMD.DataRunID = @DataRunID AND
					RMD.DataSetID = @DataSetID AND
					RMD.IsDenominator = 1 AND
					RMD.MetricID = @KeyMetricID AND
					RMD.ResultTypeID = 1;

			CREATE UNIQUE CLUSTERED INDEX IX_#MemberList ON #MemberList (DSMemberID, ResultRowID);

			--1c) Identify all antipsychotic medication dispensing events for the members in the APC eligible population...
			IF OBJECT_ID('tempdb..#EventList') IS NOT NULL
				DROP TABLE #EventList;

			SELECT	PV.*, ML.ResultRowID
			INTO	#EventList
			FROM	Proxy.[Events] AS PV
					INNER JOIN #MemberList AS ML
							ON ML.DSMemberID = PV.DSMemberID
			WHERE	PV.BatchID = @BatchID AND
					PV.DataRunID = @DataRunID AND
					PV.DataSetID = @DataSetID AND
					PV.EventID IN (@DenominatorEventID, @NumeratorEventID) AND
					PV.BeginDate BETWEEN @BeginInitSeedDate AND @EndInitSeedDate;

			CREATE UNIQUE CLUSTERED INDEX IX_#EventList ON #EventList (DSEventID, ResultRowID);

			--2a) Generate a list of each denominator entry and the dates covered by one or more events...
			IF OBJECT_ID('tempdb..#CalendarDaysCovered') IS NOT NULL
				DROP TABLE #CalendarDaysCovered;

			SELECT	CONVERT(bigint, 1) AS CountConsecutive, 
					CONVERT(bigint, 1) AS CountConsecutiveTwoOrMore, 
					COUNT(DISTINCT VL.EventCritID) AS CountDrugIDs, 
					VL.DSMemberID,
					C.D AS EvalDate, 
					CASE WHEN VL.EventID = @DenominatorEventID AND 1 = 2 THEN VL.EventCritID ELSE -1 END AS EventCritID,
					VL.EventID,
					Max(VL.DSEventID) AS MaxDSEventID,
					MIN(VL.DSEventID) AS MinDSEventID,
					VL.ResultRowID
			INTO	#CalendarDaysCovered
			FROM	#EventList AS VL
					INNER JOIN dbo.Calendar AS C
							ON C.D BETWEEN VL.BeginDate AND VL.EndOrigDate AND
								C.D BETWEEN @BeginInitSeedDate AND @EndInitSeedDate
			GROUP BY C.D,
					VL.DSMemberID,
					CASE WHEN VL.EventID = @DenominatorEventID AND 1 = 2 THEN VL.EventCritID ELSE -1 END,
					VL.EventID,
					VL.ResultRowID;

			CREATE UNIQUE CLUSTERED INDEX IX_#CalendarDaysCovered ON #CalendarDaysCovered (ResultRowID, EventID, EventCritID, EvalDate);

			--2b) Iterate through the list of denominator entries to calculate the number of consecutive days...
			DECLARE @CountConsecutive bigint;
			DECLARE @CountConsecutiveTwoOrMore bigint;
			DECLARE @LastCountDrugIDs int;
			DECLARE @LastEvalDate datetime;
			DECLARE @LastEvalDateTwoOrMore datetime;
			DECLARE @LastEventCritID int;
			DECLARE @LastEventID int;
			DECLARE @LastResultRowID bigint;

			UPDATE	t
			SET		@CountConsecutive = CountConsecutive = CASE WHEN @LastResultRowID = ResultRowID AND
																	 @LastEventCritID = EventCritID AND
																	 @LastEventID = EventID AND
																	 DATEDIFF(dd, @LastEvalDate, EvalDate) = 1
																THEN @CountConsecutive + 1
																ELSE 1 
																END,
					@CountConsecutiveTwoOrMore = CountConsecutiveTwoOrMore = CASE WHEN @LastResultRowID = ResultRowID AND
																					   @LastEventCritID = EventCritID AND
																					   @LastEventID = EventID AND
																					   CountDrugIDs >= 2 AND
																					   DATEDIFF(dd, @LastEvalDateTwoOrMore, EvalDate) <= @AllowableGapDaysTwoOrMore + 1
																				  THEN @CountConsecutiveTwoOrMore + 
																					   DATEDIFF(dd, @LastEvalDateTwoOrMore, EvalDate)
																				  WHEN @LastResultRowID = ResultRowID AND
																					   @LastEventCritID = EventCritID AND
																					   @LastEventID = EventID AND
																					   DATEDIFF(dd, @LastEvalDateTwoOrMore, EvalDate) <= @AllowableGapDaysTwoOrMore + 1
																				  THEN @CountConsecutiveTwoOrMore
																				  WHEN CountDrugIDs >= 2 
																				  THEN 1
																				  ELSE 0
																				  END,
					@LastCountDrugIDs = CountDrugIDs,
					@LastEvalDate = EvalDate,
					@LastEvalDateTwoOrMore = CASE WHEN CountDrugIDs >= 2
												  THEN EvalDate
												  WHEN @LastResultRowID = ResultRowID AND
													   @LastEventCritID = EventCritID AND
													   @LastEventID = EventID AND
													   DATEDIFF(dd, @LastEvalDateTwoOrMore, EvalDate) <= @AllowableGapDaysTwoOrMore + 1
												  THEN @LastEvalDateTwoOrMore
												  END,
					@LastEventCritID = EventCritID,
					@LastEventID = EventID,
					@LastResultRowID = ResultRowID
			FROM	#CalendarDaysCovered AS t
			OPTION (MAXDOP 1);

			--2c) Summarize the consecutive days calculations by denominator entry...
			IF OBJECT_ID('tempdb..#TotalCalendarDaysCovered') IS NOT NULL
				DROP TABLE #TotalCalendarDaysCovered;

			SELECT	MAX(CASE WHEN EventID = @DenominatorEventID THEN CountConsecutive ELSE 0 END) AS CountDays,
					MAX(CASE WHEN EventID = @DenominatorEventID  THEN CountConsecutiveTwoOrMore ELSE 0 END) AS CountDaysTwoOrMore,
					ResultRowID
			INTO	#TotalCalendarDaysCovered
			FROM	#CalendarDaysCovered
			GROUP BY ResultRowID;

			CREATE UNIQUE CLUSTERED INDEX IX_#TotalCalendarDaysCovered ON #TotalCalendarDaysCovered (ResultRowID);

			IF @DSMemberID IS NOT NULL
				SELECT	@DenominatorEventID AS DenominatorEventID,
						@NumeratorEventID AS NumeratorEventID,
						CASE WHEN t1.EventID = @DenominatorEventID 
							 THEN 'Denominator' 
							 WHEN t1.EventID = @NumeratorEventID 
							 THEN 'Numerator' 
							 END AS MapType,
						t2.CountDays, 
						t2.CountDaysTwoOrMore,
						t1.* 
				FROM	#CalendarDaysCovered AS t1 
						INNER JOIN #TotalCalendarDaysCovered AS t2 
								ON t2.ResultRowID = t1.ResultRowID 
				WHERE	(DSMemberID = @DSMemberID) 
				ORDER BY t1.ResultRowID, t1.EventID, t1.EventCritID, t1.EvalDate;

			--3) Update the denominator and numerator based on the consecutive days calculations...
			UPDATE	RMD
			SET		[Days] = t.CountDays,
					IsDenominator = CASE WHEN t.CountDays < 90 THEN 0 ELSE 1 END,
					IsIndicator = CASE WHEN t.CountDays < 90 THEN 1 ELSE 0 END,
					IsNumerator = CASE WHEN t.CountDaysTwoOrMore >= 90 THEN 1 ELSE 0 END,
					Qty = t.CountDaysTwoOrMore
			FROM	Result.MeasureDetail AS RMD
					LEFT OUTER JOIN #TotalCalendarDaysCovered AS t
							ON t.ResultRowID = RMD.ResultRowID
			WHERE	RMD.BatchID = @BatchID AND
					RMD.DataRunID = @DataRunID AND
					RMD.DataSetID = @DataSetID AND
					RMD.MetricID = @KeyMetricID AND
					RMD.ResultTypeID = 1;
					
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			IF @DSMemberID IS NOT NULL AND
				@CountRecords > 0
				BEGIN;
					IF OBJECT_ID('Temp.APC_DaysCounted') IS NOT NULL
						DROP TABLE Temp.APC_DaysCounted;

					SELECT	@DenominatorEventID AS DenominatorEventID,
							@NumeratorEventID AS NumeratorEventID,
							CASE WHEN t1.EventID = @DenominatorEventID 
								 THEN 'Denominator' 
								 WHEN t1.EventID = @NumeratorEventID 
								 THEN 'Numerator' 
								 END AS MapType,
							t2.CountDays, 
							t2.CountDaysTwoOrMore,
							t1.* 
					INTO	Temp.APC_DaysCounted
					FROM	#CalendarDaysCovered AS t1 
							INNER JOIN #TotalCalendarDaysCovered AS t2 
									ON t2.ResultRowID = t1.ResultRowID 
					ORDER BY t1.ResultRowID, t1.EventID, t1.EventCritID, t1.EvalDate;

					CREATE UNIQUE CLUSTERED INDEX IX_Temp_APC_DaysCounted ON Temp.APC_DaysCounted (DSMemberID, ResultRowID, EventID, EventCritID, EvalDate);
				END;
			
			SET @LogDescr = ' - Calculating APC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.'; 
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
			SET @LogDescr = ' - Calculating APC measure results for BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!'; 
			
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
GRANT EXECUTE ON  [Ncqa].[APC_CalculateMeasureDetail] TO [Processor]
GO
