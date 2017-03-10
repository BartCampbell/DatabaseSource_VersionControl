SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/21/2011
-- Description:	Performs final log entries for the batch.
-- =============================================
CREATE PROCEDURE [Batch].[LogActiveBatch]
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
		SET @LogObjectName = 'LogActiveBatch'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value--------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR(' - Logging of processing data for batch failed!  No batch was specified.', 16, 1);
				
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
			
			--Log Entities
			INSERT INTO [Log].Entities 
					(BatchID,
					BeginDate,
					BeginOrigDate,
					BitProductLines,
					DataRunID,
					DataSetID,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EndOrigDate,
					EnrollGroupID,
					EntityBaseID,
					EntityCritID,
					EntityID,
					EntityInfo,
					IsSupplemental,
					Iteration,
					LastSegBeginDate,
					LastSegEndDate,
					OwnerID,
					Qty,
					SourceID,
					SourceLinkID)
			SELECT	@BatchID,
					BeginDate,
					BeginOrigDate,
					BitProductLines,
					@DataRunID,
					@DataSetID,
					DataSourceID,
					[Days],
					DSEntityID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EndOrigDate,
					EnrollGroupID,
					EntityBaseID,
					EntityCritID,
					EntityID,
					EntityInfo,
					IsSupplemental,
					Iteration,
					LastSegBeginDate,
					LastSegEndDate,
					@OwnerID,
					Qty,
					SourceID,
					SourceLinkID
			FROM	Proxy.Entities;
			
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			--Log EventBase
			INSERT INTO [Log].EventBase
					(Allow,
					BatchID,
					BeginDate,
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
					HasDateReqs,
					HasEnrollReqs,
					HasMemberReqs,
					HasProviderReqs,
					IsPaid,
					IsSupplemental,
					OptionNbr,
					OwnerID,
			        RankOrder,
			        RowID,
			        Value)
			SELECT	Allow,
					@BatchID,
					BeginDate,
					ClaimTypeID,
					Code,
					CodeID,
					CodeTypeID,
					CountAllowed,
					CountCriteria,
					CountDenied,
					@DataRunID,
					@DataSetID,
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
					HasDateReqs,
					HasEnrollReqs,
					HasMemberReqs,
					HasProviderReqs,
					IsPaid,
					IsSupplemental,
					OptionNbr,
					@OwnerID,
			        RankOrder,
			        RowID,
			        Value
			FROM	Proxy.EventBase;

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--Log Events
			INSERT INTO [Log].[Events]
					(BatchID,
					BeginDate,
					BeginOrigDate,
					ClaimTypeID,
					CodeID,
					CountClaims,
					CountCodes,
					CountLines,
					CountProviders,
					DataRunID,
					DataSetID,
					DataSourceID,
					[Days],
					DispenseID,
					DSClaimID,
					DSClaimLineID,
					DSEventID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EndOrigDate,
					EventBaseID,
					EventCritID,
					EventID,
					EventInfo,
					IsPaid,
					IsSupplemental,
					IsXfer,
					OwnerID,
					Value,
					XferID)
			SELECT	@BatchID,
					BeginDate,
					BeginOrigDate,
					ClaimTypeID,
					CodeID,
					CountClaims,
					CountCodes,
					CountLines,
					CountProviders,
					@DataRunID,
					@DataSetID,
					DataSourceID,
					[Days],
					DispenseID,
					DSClaimID,
					DSClaimLineID,
					DSEventID,
					DSMemberID,
					DSProviderID,
					EndDate,
					EndOrigDate,
					EventBaseID,
					EventCritID,
					EventID,
					EventInfo,
					IsPaid,
					IsSupplemental,
					IsXfer,
					@OwnerID,
					Value,
					XferID
			FROM	Proxy.[Events];

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			SET @LogDescr = ' - Logging of processing data for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
			SET @LogDescr = ' - Logging of processing data for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
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
GRANT VIEW DEFINITION ON  [Batch].[LogActiveBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[LogActiveBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[LogActiveBatch] TO [Processor]
GO
