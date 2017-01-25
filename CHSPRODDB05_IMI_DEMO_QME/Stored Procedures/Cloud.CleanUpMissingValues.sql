SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/1/2011
-- Description:	Populates missing data from a file import that can be infered from other data in the same import.
-- =============================================
CREATE PROCEDURE [Cloud].[CleanUpMissingValues]
(
	@BatchID int,
	@CleanUpType varchar(16) = 'Processor'
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
		SET @LogObjectName = 'CleanUpMissingValues'; 
		SET @LogObjectSchema = 'Cloud'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR('Applying assumptions for BATCH failed.  No batch was specified.', 16, 1);
				
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
			
			--------------------------------------------------------------------------
			
			--1) Runs "Processor" clean-up operations...
			IF @CleanUpType = 'Processor'
				BEGIN
					--1a) Update missing claim types in ClaimCodes
					UPDATE	CC
					SET		ClaimTypeID = CL.ClaimTypeID,
							CodeID = C.CodeID,
							DSMemberID = CL.DSMemberID 
					FROM	Proxy.ClaimCodes AS CC
							INNER JOIN Proxy.ClaimLines AS CL
									ON CC.DSClaimLineID = CL.DSClaimLineID AND
										CC.BatchID = CL.BatchID AND
										CC.DataRunID = CL.DataRunID AND
										CC.DataSetID = CL.DataSetID 
							LEFT OUTER JOIN Claim.Codes AS C
									ON CC.Code = C.Code AND
										CC.CodeTypeID = C.CodeTypeID
					WHERE	(CC.BatchID = @BatchID) AND
							(CC.DataRunID = @DataRunID) AND
							(CC.DataSetID = @DataSetID) AND
							(
								(CC.ClaimTypeID IS NULL) OR
								(CC.ClaimTypeID <> CL.ClaimTypeID) OR
								(CC.DSMemberID IS NULL) OR
								(CC.DSMemberID <> CL.DSMemberID)
							);	
							
					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END;
			
			--2) Runs "Controller" clean-up operations...
			IF @CleanUpType = 'Controller'
				BEGIN;
					
					SELECT	RMD.ResultRowGuid, MIN(RMD.ResultRowID) AS ResultRowID
					INTO	#Result_MeasureDetail_RowLookup                  
					FROM    Result.MeasureDetail AS RMD WITH(SERIALIZABLE) --Formerly NOLOCK, changed due to consistent errors from CGF automation    
					WHERE	(RMD.BatchID = @BatchID) AND
							(RMD.DataRunID = @DataRunID) AND
							(RMD.DataSetID = @DataSetID)
					GROUP BY RMD.ResultRowGuid;

					CREATE UNIQUE CLUSTERED INDEX IX_#Result_MeasureDetail_RowLookup ON #Result_MeasureDetail_RowLookup (ResultRowGuid);

					--2a) Update missing source row identifier for AMR...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_AMR AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;
				
					--2b) Update missing source row identifier for FPC...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_FPC AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					--2c) Update missing source row identifier for PCR...				
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_PCR AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;
					
					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
					
					--2d) Update missing source row identifier for RRU...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_RRU AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					--2e) Update missing source row identifier for EDU...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_EDU AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					--2f) Update missing source row identifier for HPC...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_HPC AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					--2g) Update missing source row identifier for IHU...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Result.MeasureDetail_IHU AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					--2h) Update missing source row identifier for Clinical Conditions...
					UPDATE	t
					SET		SourceRowID = RMD.ResultRowID
					FROM	Log.PCR_ClinicalConditions AS t WITH(ROWLOCK)
							INNER JOIN #Result_MeasureDetail_RowLookup AS RMD
									ON t.SourceRowGuid = RMD.ResultRowGuid;

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				END;
			--------------------------------------------------------------------------
				
			SET @LogDescr = 'Applying assumptions for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = 'Applying assumptions for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT EXECUTE ON  [Cloud].[CleanUpMissingValues] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[CleanUpMissingValues] TO [Submitter]
GO
