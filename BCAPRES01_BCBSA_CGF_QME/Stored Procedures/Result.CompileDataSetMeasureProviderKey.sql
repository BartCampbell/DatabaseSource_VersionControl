SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 12/18/2015
-- Description:	Compiles the member/measure/provider reference key values for the specified Data Run.
-- =============================================
CREATE PROCEDURE [Result].[CompileDataSetMeasureProviderKey]
(
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;

	DECLARE @BatchID int;
	DECLARE @BeginSeedDate datetime;
	DECLARE @DataSetID int;
	DECLARE @EndSeedDate datetime;
	DECLARE @MaxProviderRanks smallint;
	DECLARE @MeasureSetID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileDataSetMeasureProviderKey'; 
		SET @LogObjectSchema = 'Result'; 
		
		BEGIN TRY;				
			DECLARE @CountRecords int;

			SELECT	@BeginSeedDate = BDR.BeginInitSeedDate, 
					@DataSetID = BDR.DataSetID,
					@EndSeedDate = BDR.EndInitSeedDate, 
					@MaxProviderRanks = BDO.MaxProviderRanks,
					@MeasureSetID = BDR.MeasureSetID, 
					@SeedDate = BDR.SeedDate 
			FROM	Batch.DataRuns AS BDR
					INNER JOIN Batch.DataSets AS BDS
							ON BDS.DataSetID = BDR.DataSetID
					INNER JOIN Batch.DataOwners AS BDO
							ON BDO.OwnerID = BDS.OwnerID
			WHERE	(BDR.DataRunID = @DataRunID);

			DECLARE @MapTypeNumerator tinyint;
			SELECT @MapTypeNumerator = MapTypeID FROM Measure.MappingTypes WHERE MapTypeGuid = '376C404D-C8EF-4716-9296-909A0BE6ADD4';

			DECLARE @BitSpecialtiesGeneric bigint;
			SELECT @BitSpecialtiesGeneric = SUM(BitValue) FROM Provider.Specialties WHERE Abbrev IN ('PCP', 'OBGYN' ,' NPR', 'PAS');

			DECLARE @Specialties TABLE (BitValue bigint NOT NULL, [Priority] tinyint NOT NULL, PRIMARY KEY (BitValue));
			INSERT INTO @Specialties
					(BitValue, [Priority])
			SELECT BitValue, [Priority] FROM Provider.Specialties WHERE (BitValue IS NOT NULL);

			IF OBJECT_ID('tempdb..#Step1_MemberMeasures') IS NOT NULL
				DROP TABLE #Step1_MemberMeasures;

			IF OBJECT_ID('tempdb..#Step2_EntityEnrollment') IS NOT NULL
				DROP TABLE #Step2_EntityEnrollment;

			IF OBJECT_ID('tempdb..#Step3_EntityCriteria') IS NOT NULL
				DROP TABLE #Step3_EntityCriteria;

			IF OBJECT_ID('tempdb..#MemberList') IS NOT NULL
				DROP TABLE #MemberList;

			IF OBJECT_ID('tempdb..#ProviderList') IS NOT NULL
				DROP TABLE #ProviderList;

			--Determines the current state of ANSI_WARNINGS and sets it to "OFF" if necessary (Prevents NULL aggregate messages during the INSERT statement)...
			DECLARE @Ansi_Warnings bit;
			SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS OFF;

			--1) Gather all member/measure/key-date combinations from the measure results...
			WITH Step1_MemberMeasures AS
			(
				SELECT	MIN(MM.Abbrev) AS Abbrev,
						RMD.DSMemberID,
						RMD.EntityID,
						MM.IsHybrid,
						RMD.KeyDate,
						MX.MeasureID,
						MM.MeasureSetID,
						MIN(RMD.BeginDate) AS Step1BeginDate,
						MAX(RMD.EndDate) AS Step1EndDate
				FROM	Result.MeasureDetail AS RMD
						INNER JOIN Measure.Measures AS MM
								ON MM.MeasureID = RMD.MeasureID
						INNER JOIN Measure.Metrics AS MX
								ON MX.MeasureID = MM.MeasureID AND
									MX.MetricID = RMD.MetricID
				WHERE	RMD.DataRunID = @DataRunID AND
						RMD.ResultTypeID NOT IN (2, 3) AND
						MM.IsEnabled = 1 AND
						MX.IsEnabled = 1
				GROUP BY RMD.DSMemberID,
						RMD.EntityID,
						MM.IsHybrid,
						RMD.KeyDate,
						MX.MeasureID,
						MM.MeasureSetID
			)
			SELECT * INTO #Step1_MemberMeasures FROM Step1_MemberMeasures;

			CREATE UNIQUE CLUSTERED INDEX IX_#Step1_MemberMeasures ON #Step1_MemberMeasures (EntityID, DSMemberID, KeyDate, MeasureID);

			--2) Identify the enrollment period for the member/measure/key-date combinations...
			WITH DateComparers AS
			(
				SELECT	MDC.* 
				FROM	Measure.DateComparers  AS MDC
						INNER JOIN Measure.DateComparerTypes AS MDCT
								ON MDCT.DateCompTypeID = MDC.DateCompTypeID
				WHERE	MDCT.Abbrev IN ('N')
			
			),
			MeasureEntityEnrollment AS
			(
				SELECT DISTINCT
						MEN.EntityID,
						MN.*,
						DC.IsSeed
				FROM	Measure.EntityEnrollment AS MEN
						INNER JOIN Measure.Enrollment AS MN
								ON MN.MeasEnrollID = MEN.MeasEnrollID
						INNER JOIN DateComparers AS DC
								ON DC.DateComparerID = MN.DateComparerID
			),
			Step2_EntityEnrollment AS
			(
				SELECT	MIN(t.Abbrev) AS Abbrev,
						t.DSMemberID,
						t.EntityID,
						t.IsHybrid,
						t.KeyDate,
						t.MeasureID,
						t.MeasureSetID,
						MIN(t.Step1BeginDate) AS Step1BeginDate,
						MAX(t.Step1EndDate) AS Step1EndDate,
						MIN(DATEADD(dd, MEN.BeginDays, DATEADD(mm, MEN.BeginMonths, CASE WHEN MEN.IsSeed = 1 THEN @BeginSeedDate ELSE t.Step1BeginDate END))) AS Step2BeginDate,
						MAX(DATEADD(dd, MEN.EndDays, DATEADD(mm, MEN.EndMonths, CASE WHEN MEN.IsSeed = 1 THEN @EndSeedDate ELSE t.Step1EndDate END))) AS Step2EndDate
				FROM	#Step1_MemberMeasures AS t
						LEFT OUTER JOIN MeasureEntityEnrollment AS MEN
								ON MEN.EntityID = t.EntityID
				GROUP BY t.DSMemberID, 
						t.EntityID,
						t.IsHybrid,
						t.KeyDate,
						t.MeasureID,
						t.MeasureSetID
			)
			SELECT * INTO #Step2_EntityEnrollment FROM Step2_EntityEnrollment;

			CREATE UNIQUE CLUSTERED INDEX IX_#Step2_EntityEnrollment ON #Step2_EntityEnrollment (MeasureID, DSMemberID, EntityID, KeyDate);

			--3) Identify the time period for numerator compliance associated with each member/measure/key-date combination...
			WITH DateComparers AS
			(
				SELECT	MDC.* 
				FROM	Measure.DateComparers  AS MDC
						INNER JOIN Measure.DateComparerTypes AS MDCT
								ON MDCT.DateCompTypeID = MDC.DateCompTypeID
				WHERE	MDCT.Abbrev IN ('V')
			
			),
			MeasureNumerators AS 
			(
				SELECT	MX.MeasureID,
						MEC.*,
						DC.IsSeed
				FROM	Measure.Metrics AS MX
						INNER JOIN Measure.EntityToMetricMapping AS METMM
								ON METMM.MetricID = MX.MetricID AND
									METMM.MapTypeID = @MapTypeNumerator
						INNER JOIN Measure.EntityCriteria AS MEC
								ON MEC.EntityID = METMM.EntityID
						INNER JOIN DateComparers AS DC
								ON DC.DateComparerID = MEC.DateComparerID
				WHERE	MEC.Allow = 1
			),
			Step3_EntityCriteria AS
			(
				SELECT	MIN(t.Abbrev) AS Abbrev,
						t.DSMemberID,
						t.IsHybrid,
						t.KeyDate,
						t.MeasureID,
						t.MeasureSetID,
						MIN(t.Step1BeginDate) AS Step1BeginDate,
						MAX(t.Step1EndDate) AS Step1EndDate,
						MIN(t.Step2BeginDate) AS Step2BeginDate,
						MAX(t.Step2EndDate) AS Step2EndDate,
						MIN(DATEADD(dd, MN.BeginDays, DATEADD(mm, MN.BeginMonths, CASE WHEN MN.IsSeed = 1 THEN @BeginSeedDate ELSE t.Step1BeginDate END))) AS Step3BeginDate,
						MAX(DATEADD(dd, MN.EndDays, DATEADD(mm, MN.EndMonths, CASE WHEN MN.IsSeed = 1 THEN @EndSeedDate ELSE t.Step1EndDate END))) AS Step3EndDate
				FROM	#Step2_EntityEnrollment AS t
						LEFT OUTER JOIN MeasureNumerators AS MN
								ON MN.MeasureID = t.MeasureID
				GROUP BY t.DSMemberID, 
						t.IsHybrid,
						t.KeyDate,
						t.MeasureID,
						t.MeasureSetID
			)
			SELECT * INTO #Step3_EntityCriteria FROM Step3_EntityCriteria;

			CREATE UNIQUE CLUSTERED INDEX IX_#Step3_EntityCriteria ON #Step3_EntityCriteria (DSMemberID, KeyDate, MeasureID);

			--4) Unpivot the dates, taking the earliest and latest dates to set the search window for providers...
			WITH Step4_EvalDates AS
			(
				SELECT	*
				FROM	(
							SELECT	*
							FROM	#Step3_EntityCriteria
						) p
						UNPIVOT		(
										EvalDate FOR DateType IN (
																	Step1BeginDate, 
																	Step1EndDate, 
																	Step2BeginDate, 
																	Step2EndDate,
																	Step3BeginDate,
																	Step3EndDate
																)
									) AS u
			), 
			Step5_DateRanges AS
			(
				SELECT	MIN(Abbrev) AS Abbrev, 
						MIN(EvalDate) AS BeginDate, 
						DSMemberID, 
						MAX(EvalDate) AS EndDate, 
						IsHybrid, 
						KeyDate, 
						MeasureID, 
						MeasureSetID
				FROM	Step4_EvalDates 
				WHERE	EvalDate BETWEEN DATEADD(mm, -18, @BeginSeedDate) AND @EndSeedDate 
				GROUP BY DSMemberID, KeyDate, IsHybrid, MeasureID, MeasureSetID
			)
			SELECT	t.Abbrev,
					t.BeginDate,
					CONVERT(bigint, 0) AS BitSpecialtiesAllowed,
					CONVERT(bigint, 0) AS BitSpecialtiesDenied,
					t.DSMemberID,
					t.EndDate,
					IDENTITY(bigint, 1, 1) AS ID,
					t.IsHybrid,
					t.KeyDate,
					t.MeasureID,
					t.MeasureSetID
			INTO	#MemberList
			FROM	Step5_DateRanges AS t
			ORDER BY Abbrev, DSMemberID, KeyDate;

			CREATE UNIQUE CLUSTERED INDEX IX_#MemberList ON #MemberList (DSMemberID, KeyDate, MeasureID);

			--5) Determine if the events associated with each measure have specialty requirements to use with identifying providers...
			SELECT	SUM(DISTINCT CASE WHEN MVCS.IsValid = 1 THEN PS.BitValue END) AS BitSpecialtiesAllowed,
					SUM(DISTINCT CASE WHEN MVCS.IsValid = 0 THEN PS.BitValue END) AS BitSpecialtiesDenied,
					ML.ID
			INTO	#SpecialtyValues
			FROM	#MemberList AS ML
					INNER JOIN Measure.GetMeasureEvents(DEFAULT, DEFAULT, @MeasureSetID) AS MMV
							ON MMV.MeasureID = ML.MeasureID
					INNER JOIN Measure.EventOptions AS MVO
							ON MVO.EventID = MMV.EventID
					INNER JOIN Measure.EventCriteriaSpecialties AS MVCS
							ON MVCS.EventCritID = MVO.EventCritID
					INNER JOIN Provider.Specialties AS PS
							ON PS.SpecialtyID = MVCS.SpecialtyID
			GROUP BY ML.ID;

			UPDATE	ML
			SET		ML.BitSpecialtiesAllowed = ISNULL(SV.BitSpecialtiesAllowed, 0),
					ML.BitSpecialtiesDenied = ISNULL(SV.BitSpecialtiesDenied, 0)
			FROM	#MemberList AS ML
					INNER JOIN #SpecialtyValues AS SV
							ON SV.ID = ML.ID;

			DROP TABLE #SpecialtyValues;
			DROP INDEX IX_#MemberList ON #MemberList;
			CREATE UNIQUE CLUSTERED INDEX IX_#MemberList ON #MemberList (DSMemberID, KeyDate, MeasureID);

			--6) Identify all providers meeting the criteria determined in earlier steps...
			SELECT	MIN(ML.Abbrev) AS Abbrev,
					PP.BitSpecialties,
					ML.BitSpecialtiesAllowed,
					ML.BitSpecialtiesDenied,
					COUNT(DISTINCT CCL.DSClaimLineID) AS CountClaims,
					COUNT(DISTINCT ISNULL(CCL.EndDate, CCL.BeginDate)) AS CountDates,
					ML.DSMemberID,
					CCL.DSProviderID,
					IDENTITY(bigint, 1, 1) AS ID,
					ML.KeyDate,
					ML.MeasureID,
					CONVERT(tinyint, 255) AS [Priority],
					CONVERT(int, NULL) AS RankOrder,
					MAX(ISNULL(CCL.EndDate, CCL.BeginDate)) AS RecentDate
			INTO	#ProviderList
			FROM	#MemberList AS ML WITH(INDEX(1))
					INNER JOIN Claim.ClaimLines AS CCL WITH(NOLOCK, INDEX(IX_ClaimLines_DSMemberID))
							ON CCL.DSMemberID = ML.DSMemberID AND
								(
									CCL.BeginDate BETWEEN ML.BeginDate AND ML.EndDate OR
									CCL.EndDate BETWEEN ML.BeginDate AND ML.EndDate OR
									CCL.ServDate BETWEEN ML.BeginDate AND ML.EndDate
								) AND
								CCL.DataSetID = @DataSetID AND
								CCL.IsSupplemental = 0
					INNER JOIN Provider.Providers AS PP WITH(NOLOCK, INDEX(1))
							ON PP.DSProviderID = CCL.DSProviderID AND
								PP.DataSetID = CCL.DataSetID
			GROUP BY PP.BitSpecialties,
					ML.BitSpecialtiesAllowed,
					ML.BitSpecialtiesDenied,
					ML.DSMemberID,
					CCL.DSProviderID,
					ML.ID,
					ML.KeyDate,
					ML.MeasureID
			ORDER BY ML.ID
			OPTION (FORCE ORDER);

			CREATE UNIQUE CLUSTERED INDEX IX_#ProviderList ON #ProviderList (ID);

			--7) Calculate the priority of each provider for a given member/measure/key-date combination...
			UPDATE	PL
			SET		[Priority] = COALESCE(NULLIF(PS1.[Priority], 255), PS2.[Priority], 255)
			FROM	#ProviderList AS PL
					OUTER APPLY (
									SELECT TOP 1
											*
									FROM	@Specialties AS tPS1
									WHERE	(tPS1.BitValue & PL.BitSpecialties & PL.BitSpecialtiesAllowed > 0) AND
											(tPS1.BitValue & PL.BitSpecialties & PL.BitSpecialtiesDenied = 0)
									ORDER BY CASE WHEN tPS1.BitValue & PL.BitSpecialtiesAllowed > 0 THEN 1 ELSE 2 END,
											tPS1.[Priority],
											tPS1.BitValue
								) AS PS1
					OUTER APPLY (
									SELECT TOP 1
											*
									FROM	@Specialties AS tPS2
									WHERE	(tPS2.BitValue & PL.BitSpecialties & @BitSpecialtiesGeneric > 0) AND
											(tPS2.BitValue & PL.BitSpecialties & PL.BitSpecialtiesDenied = 0)
									ORDER BY tPS2.[Priority],
											tPS2.BitValue
								) AS PS2;

			--8) Apply rankings to the providers...
			WITH Rankings AS
			(
			SELECT	PL.ID,
					ROW_NUMBER() OVER	
								(
									PARTITION BY DSMemberID, 
											KeyDate, 
											MeasureID 
									ORDER BY CONVERT(float, CountDates) * (0.750000000 / [Priority]) DESC, 
											[Priority], 
											CountDates, 
											RecentDate DESC, 
											DSProviderID
								) AS RankOrder
			FROM	#ProviderList AS PL
			)
			UPDATE	PL
			SET		RankOrder = t.RankOrder
			FROM	#ProviderList AS PL
					INNER JOIN Rankings AS t
							ON t.ID = PL.ID;

			--9) Populate the results table...
			DELETE FROM Result.DataSetMeasureProviderKey WHERE DataRunID = @DataRunID;

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetMeasureProviderKey)
				TRUNCATE TABLE Result.DataSetMeasureProviderKey;

			INSERT INTO Result.DataSetMeasureProviderKey
					(BitSpecialties,
					CountClaims,
					CountDates,
					CountMonths,
					DataRunID,
					DataSetID,
					DSMemberID,
					DSProviderID,
					KeyDate,
					MeasureID,
					RankOrder,
					RecentDate)
			SELECT	PL.BitSpecialties & PL.BitSpecialtiesAllowed AS BitSpecialties,
					PL.CountClaims,
					PL.CountDates,
					0 AS CountMonths,
					@DataRunID AS DataRunID,
					@DataSetID AS DataSetID,
					PL.DSMemberID,
					PL.DSProviderID,
					PL.KeyDate,
					PL.MeasureID,
					PL.RankOrder,
					PL.RecentDate
			FROM	#ProviderList AS PL
			WHERE	(PL.RankOrder <= @MaxProviderRanks);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			--Returns ANSI_WARNINGS back to "ON", if it was originally "ON"...
			IF @Ansi_Warnings = 1
				SET ANSI_WARNINGS ON;

			SET @LogDescr = 'Compiling of member measure provider key values completed successfully.'; 
			SET @LogEndTime = GETDATE();
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
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
			SET @LogDescr = 'Compiling of member key values failed!';
			
			EXEC @Result = [Log].RecordEntry	@BatchID = @BatchID,
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
GRANT EXECUTE ON  [Result].[CompileDataSetMeasureProviderKey] TO [Processor]
GO
