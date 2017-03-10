SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/21/2015
-- Description: Applies the denominator "lock" from the an initial run to a refresh run.
--				(NOTE: The matching for the denominator lock relies on the population of 
--				       the Result.DataSetMemberKey for both data runs.  Result.SummarizeAll
--				       must be run for both populations prior to locking.)
-- =============================================
CREATE PROCEDURE [Measure].[LockAdminDenominators]
(
	@FromDataRunID int,
	@ToDataRunID int
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
		SET @LogObjectName = 'LockAdminDenominators'; 
		SET @LogObjectSchema = 'Measure'; 

		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
	
		DECLARE @DataRunID int;
		SET @DataRunID = @ToDataRunID;

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
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.DataRuns WHERE DataRunID = @FromDataRunID) 
				RAISERROR('The initial data run (@FromDataRunID) does not exist.', 16, 1);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.DataRuns WHERE DataRunID = @ToDataRunID) 
				RAISERROR('The refresh data run (@ToDataRunID) does not exist.', 16, 1);

			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetRunKey WHERE DataRunID = @FromDataRunID) OR
				NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetMemberKey WHERE DataRunID = @FromDataRunID)			
				RAISERROR('The initial data run (@FromDataRunID) has not been summarized.  Please run Result.SummarizeAll for the initial run prior to locking populations.', 16, 1);
			
			IF NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetRunKey WHERE DataRunID = @ToDataRunID) OR
				NOT EXISTS (SELECT TOP 1 1 FROM Result.DataSetMemberKey WHERE DataRunID = @FromDataRunID)
				BEGIN;
					PRINT 'The results of @ToDataRunID have not been summarized.  Summarizing all now...';
					PRINT '';
					EXEC Result.SummarizeAll @DataRunID = @ToDataRunID;
				END;

			DECLARE @IsSuccessful bit;
			SET @IsSuccessful = 0;

			SET NOCOUNT ON;

			IF EXISTS (SELECT TOP 1 1 FROM Batch.DataRuns AS D1 INNER JOIN Batch.DataRuns AS D2 ON D1.BeginInitSeedDate = D2.BeginInitSeedDate AND D1.EndInitSeedDate = D2.EndInitSeedDate AND D1.MbrMonthID = D2.MbrMonthID AND D1.MeasureSetID = D2.MeasureSetID AND D1.SeedDate = D2.SeedDate WHERE D1.DataRunID = @FromDataRunID AND D2.DataRunID = @ToDataRunID)
				BEGIN;
					IF OBJECT_ID('tempdb..#MeasureDetail') IS NOT NULL
						DROP TABLE #MeasureDetail;      

					SELECT DISTINCT
							RDSMK.CustomerMemberID, RDSMK.IhdsMemberID, RDSMK.DOB, RDSMK.NameFirst, RDSMK.NameLast, RMD.*
					INTO	#MeasureDetail
					FROM	Result.MeasureDetail AS RMD WITH(NOLOCK)
							INNER JOIN Batch.SystematicSamples AS BSS WITH(NOLOCK)
									ON RMD.BitProductLines & BSS.BitProductLines > 0 AND
										RMD.MeasureID = BSS.MeasureID AND
										(BSS.PayerID IS NULL OR RMD.PayerID = BSS.PayerID) AND
										RMD.MeasureID = BSS.MeasureID AND                  
										BSS.DataRunID = @FromDataRunID              
							INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
									ON RMD.DataRunID = RDSMK.DataRunID AND
										RMD.DataSetID = RDSMK.DataSetID AND
										RMD.DSMemberID = RDSMK.DSMemberID              
					WHERE	RMD.DataRunID IN (@FromDataRunID, @ToDataRunID) AND
							RMD.ResultTypeID = 1 AND
							(
								RMD.IsDenominator = 1 OR 
								RMD.IsExclusion = 1 OR
								RMD.IsIndicator = 1 OR
								RMD.IsNumerator = 1    
							)

					CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDetail ON #MeasureDetail (DataRunID, CustomerMemberID, IhdsMemberID, MetricID, BitProductLines, ResultRowID);      

					IF OBJECT_ID('tempdb..#ToAdd') IS NOT NULL
						DROP TABLE #ToAdd;      

					SELECT	RMD1.ResultRowID
					INTO	#ToAdd
					FROM	#MeasureDetail AS RMD1
							INNER JOIN Measure.Measures AS MM
									ON RMD1.MeasureID = MM.MeasureID
							LEFT OUTER JOIN #MeasureDetail AS RMD2
									ON RMD1.CustomerMemberID = RMD2.CustomerMemberID AND
										RMD1.IhdsMemberID = RMD2.IhdsMemberID AND
										(MM.Abbrev NOT IN ('MRP','FPC','PPC') OR RMD1.KeyDate BETWEEN DATEADD(dd, -30, RMD2.KeyDate) AND DATEADD(dd, 30, RMD2.KeyDate)) AND
										RMD1.MetricID = RMD2.MetricID AND
										RMD1.BitProductLines & RMD2.BitProductLines > 0 AND
										RMD1.DataRunID = @FromDataRunID AND
										RMD2.DataRunID = @ToDataRunID
					WHERE	(RMD1.DataRunID = @FromDataRunID) AND
							(RMD2.ResultRowID IS NULL);      

					CREATE UNIQUE CLUSTERED INDEX IX_#ToAdd ON #ToAdd (ResultRowID);

					IF OBJECT_ID('tempdb..#ToRemove') IS NOT NULL
						DROP TABLE #ToRemove;      

					SELECT	RMD1.ResultRowID
					INTO	#ToRemove
					FROM	#MeasureDetail AS RMD1
							INNER JOIN Measure.Measures AS MM
									ON RMD1.MeasureID = MM.MeasureID
							LEFT OUTER JOIN #MeasureDetail AS RMD2
									ON RMD1.CustomerMemberID = RMD2.CustomerMemberID AND
										RMD1.IhdsMemberID = RMD2.IhdsMemberID AND
										(MM.Abbrev NOT IN ('MRP','FPC','PPC') OR RMD1.KeyDate BETWEEN DATEADD(dd, -30, RMD2.KeyDate) AND DATEADD(dd, 30, RMD2.KeyDate)) AND
										RMD1.MetricID = RMD2.MetricID AND
										RMD1.BitProductLines & RMD2.BitProductLines > 0 AND
										RMD1.DataRunID = @ToDataRunID AND
										RMD2.DataRunID = @FromDataRunID
					WHERE	(RMD1.DataRunID = @ToDataRunID) AND
							(RMD2.ResultRowID IS NULL);
				
					CREATE UNIQUE CLUSTERED INDEX IX_#ToRemove ON #ToRemove (ResultRowID);
		
					--Per NCQA PCS question
					IF OBJECT_ID('tempdb..#ToExclude') IS NOT NULL
						DROP TABLE #ToExclude;      

					SELECT	RMD1.ResultRowID AS FromResultRowID,
							RMD2.ResultRowID AS ToResultRowID
					INTO	#ToExclude
					FROM	#MeasureDetail AS RMD1
							INNER JOIN Measure.Measures AS MM
									ON RMD1.MeasureID = MM.MeasureID
							INNER JOIN #MeasureDetail AS RMD2
									ON RMD1.CustomerMemberID = RMD2.CustomerMemberID AND
										RMD1.IhdsMemberID = RMD2.IhdsMemberID AND
										(MM.Abbrev NOT IN ('MRP','FPC','PPC') OR RMD1.KeyDate BETWEEN DATEADD(dd, -30, RMD2.KeyDate) AND DATEADD(dd, 30, RMD2.KeyDate)) AND
										RMD1.MetricID = RMD2.MetricID AND
										RMD1.BitProductLines & RMD2.BitProductLines > 0 AND
										RMD1.DataRunID = @FromDataRunID AND
										RMD2.DataRunID = @ToDataRunID
					WHERE	(RMD1.IsExclusion = 1) AND
							(RMD1.IsDenominator = 0) AND
							(RMD2.IsExclusion = 0);
				
					CREATE UNIQUE CLUSTERED INDEX IX_#ToExclude ON #ToExclude (FromResultRowID, ToResultRowID);

					SELECT 'To Add' AS CountType, MM.Abbrev AS Measure, COUNT(*) AS Cnt FROM #ToAdd AS t INNER JOIN #MeasureDetail AS RMD ON t.ResultRowID = RMD.ResultRowID INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID GROUP BY MM.Abbrev, MM.MeasureID ORDER BY 2;
					SELECT 'To Remove' AS CountType, MM.Abbrev AS Measure, COUNT(*) AS Cnt FROM #ToRemove AS t INNER JOIN #MeasureDetail AS RMD ON t.ResultRowID = RMD.ResultRowID INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID GROUP BY MM.Abbrev, MM.MeasureID ORDER BY 2;
					SELECT 'To Exclude' AS CountType, MM.Abbrev AS Measure, COUNT(*) AS Cnt FROM #ToExclude AS t INNER JOIN #MeasureDetail AS RMD ON t.FromResultRowID = RMD.ResultRowID INNER JOIN Measure.Measures AS MM ON RMD.MeasureID = MM.MeasureID GROUP BY MM.Abbrev, MM.MeasureID ORDER BY 2;

					BEGIN TRANSACTION TSetPopulationLocks;

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
							DataSourceID,
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
							KeyDate,
							MeasureID,
							MeasureXrefID,
							MetricID,
							MetricXrefID,
							PayerID,
							PopulationID,
							ProductLineID,
							Qty,
							ResultRowGuid,
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
							RMD.BatchID * -1 AS BatchID,
							RMD.BeginDate,
							RMD.BitProductLines,
							RMD.ClinCondID,
							BDR.DataRunID,
							BDR.DataSetID,
							RMD.DataSourceID,
							RMD.[Days],
							RMD.DSEntityID,
							RDSMK.DSMemberID,
							RMD.DSProviderID,
							RMD.EndDate,
							RMD.EnrollGroupID,
							RMD.EntityID,
							RMD.ExclusionTypeID,
							RMD.Gender,
							RMD.IsDenominator,
							RMD.IsExclusion,
							RMD.IsIndicator,
							RMD.IsNumerator,
							RMD.IsNumeratorAdmin,
							RMD.IsNumeratorMedRcd,
							RMD.KeyDate,
							RMD.MeasureID,
							RMD.MeasureXrefID,
							RMD.MetricID,
							RMD.MetricXrefID,
							RMD.PayerID,
							RMD.PopulationID,
							RMD.ProductLineID,
							RMD.Qty,
							NEWID() AS ResultRowGuid,
							RMD.ResultTypeID,
							RMD.SourceDenominator,
							RMD.SourceDenominatorSrc,
							RMD.SourceExclusion,
							RMD.SourceExclusionSrc,
							RMD.SourceIndicator,
							RMD.SourceIndicatorSrc,
							RMD.SourceNumerator,
							RMD.SourceNumeratorSrc,
							RMD.SysSampleRefID,
							RMD.[Weight]
					FROM    #MeasureDetail AS RMD
							INNER JOIN Result.DataSetMemberKey AS RDSMK
									ON RDSMK.DataRunID = @ToDataRunID AND
										RMD.CustomerMemberID = RDSMK.CustomerMemberID AND
										RMD.IhdsMemberID = RDSMK.IhdsMemberID                      
							INNER JOIN #ToAdd AS t
									ON RMD.ResultRowID = t.ResultRowID
							INNER JOIN Batch.DataRuns AS BDR
									ON BDR.DataRunID = @ToDataRunID
					WHERE	(RMD.DataRunID = @FromDataRunID);

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					UPDATE	RMD
					SET		IsDenominator = 0,
							IsExclusion = 0,
							IsIndicator = 0,
							IsNumerator = 0,
							IsNumeratorAdmin = 0,
							IsNumeratorMedRcd = 0
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #ToRemove AS t
									ON RMD.ResultRowID = t.ResultRowID
					WHERE	(RMD.DataRunID = @ToDataRunID);

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					UPDATE	RMD
					SET		IsExclusion = 1,
							ExclusionTypeID = Excl.ExclusionTypeID,
							IsDenominator = 0,
							IsNumerator = 0, 
							IsNumeratorAdmin = 0,
							SourceExclusion = Excl.SourceExclusion,
							SourceExclusionSrc = Excl.SourceExclusionSrc
					FROM	Result.MeasureDetail AS RMD
							INNER JOIN #ToExclude AS t
									ON RMD.ResultRowID = t.ToResultRowID
							INNER JOIN Result.MeasureDetail AS Excl
									ON Excl.ResultRowID = t.FromResultRowID
					WHERE	(RMD.DataRunID = @ToDataRunID) AND
							(Excl.DataRunID = @FromDataRunID);

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					SELECT 'Original Counts' AS CountType, DataRunID, MM.Abbrev AS Measure, COUNT(*) AS Cnt FROM #MeasureDetail INNER JOIN Measure.Measures AS MM ON #MeasureDetail.MeasureID = MM.MeasureID GROUP BY DataRunID, MM.Abbrev ORDER BY 3, 2;   

					SELECT	'New Counts' AS CountType, 
							RMD.DataRunID, MM.Abbrev AS Measure, COUNT(*) AS Cnt
					INTO	#NewCounts
					FROM	Result.MeasureDetail AS RMD WITH(NOLOCK)
							INNER JOIN Measure.Measures AS MM
									ON RMD.MeasureID = MM.MeasureID
							INNER JOIN Batch.SystematicSamples AS BSS WITH(NOLOCK)
									ON RMD.BitProductLines & BSS.BitProductLines > 0 AND
										RMD.MeasureID = BSS.MeasureID AND
										(BSS.PayerID IS NULL OR RMD.PayerID = BSS.PayerID) AND
										RMD.MeasureID = BSS.MeasureID AND                  
										BSS.DataRunID = @FromDataRunID              
							INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
									ON RMD.DataRunID = RDSMK.DataRunID AND
										RMD.DataSetID = RDSMK.DataSetID AND
										RMD.DSMemberID = RDSMK.DSMemberID              
					WHERE	RMD.DataRunID IN (@FromDataRunID, @ToDataRunID) AND
							RMD.ResultTypeID = 1 AND
							(
								RMD.IsDenominator = 1 OR 
								RMD.IsExclusion = 1 OR
								RMD.IsIndicator = 1 OR
								RMD.IsNumerator = 1    
							)
					GROUP BY RMD.DataRunID, MM.Abbrev
					ORDER BY 3, 2;
		
					CREATE UNIQUE CLUSTERED INDEX IX_#NewCounts ON #NewCounts (Measure, DataRunID);

					SELECT * FROM #NewCounts ORDER BY 3, 2;

					IF NOT EXISTS	(
										SELECT	TOP 1 
												1
										FROM    (SELECT * FROM #NewCounts WHERE DataRunID = @FromDataRunID) AS NC1
												INNER JOIN (SELECT * FROM #NewCounts WHERE DataRunID = @ToDataRunID) AS NC2
														ON NC1.Measure = NC2.Measure
										WHERE	(NC1.Cnt <> NC2.Cnt) OR
												(NC1.Cnt IS NULL) OR
												(NC2.Cnt IS NULL)
									)           
						BEGIN;
							COMMIT TRANSACTION TSetPopulationLocks;
							PRINT 'Population locks applied successfully.';

							SET @IsSuccessful = 1;
						END;
					ELSE
						BEGIN;
							ROLLBACK TRANSACTION TSetPopulationLocks;
							PRINT 'Population locks apply failed.  One or more measures did not match after completion.  Transaction rolled back.';
							RAISERROR('Unable to apply population locks.', 16, 1);
						END;        
				END;
			ELSE      
				RAISERROR('The two specified data runs are not compatible.', 16, 1);

			IF @IsSuccessful = 1
				BEGIN;
					PRINT REPLICATE(CHAR(13) + CHAR(10), 3);

					EXEC dbo.RebuildIndexes @TableName = N'MeasureDetail', @TableSchema = N'Result';
					EXEC dbo.RefreshStatistics @TableName = N'MeasureDetail', @TableSchema = N'Result';

					EXEC Result.SummarizeMeasureDetail @DataRunID = @ToDataRunID;
					EXEC Result.SummarizeMeasureByAgeBand @DataRunID = @ToDataRunID;

					EXEC dbo.RebuildIndexes @TableName = N'MeasureSummary', @TableSchema = N'Result';
					EXEC dbo.RefreshStatistics @TableName = N'MeasureSummary', @TableSchema = N'Result';

					EXEC Result.SummarizeMetricMonths @DataRunID = @ToDataRunID;
				END;



			SET @LogDescr = 'Applying denominator locks completed succcessfully.'; 
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
			SET @LogDescr = 'Applying denominator locks failed!'; 
			
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
GRANT VIEW DEFINITION ON  [Measure].[LockAdminDenominators] TO [db_executer]
GO
GRANT EXECUTE ON  [Measure].[LockAdminDenominators] TO [db_executer]
GO
GRANT EXECUTE ON  [Measure].[LockAdminDenominators] TO [Processor]
GO
