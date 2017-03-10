SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/3/2011
-- Description:	Summarizes all results by running each of the hard-coded "Summarize" procedures.
-- =============================================
CREATE PROCEDURE [Result].[SummarizeAll]
(
	@DataRunID int,
	@BatchID int = NULL
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

	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SummarizeAll'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					--@DataRunID = B.DataRunID,
					@DataSetID = DS.DataSetID,
					@MbrMonthID = DR.MbrMonthID,
					@MeasureSetID = DR.MeasureSetID,
					@OwnerID = DS.OwnerID,
					@SeedDate = DR.SeedDate
			FROM	Batch.[Batches] AS B 
					INNER JOIN Batch.DataSets AS DS 
							ON B.DataSetID = DS.DataSetID 
					INNER JOIN Batch.DataRuns AS DR
							ON B.DataRunID = DR.DataRunID
			WHERE	(DR.DataRunID = @DataRunID) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
						
			EXEC @Result = Result.CompileDataSetRunKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.ValidateRecordCounts @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			--*** Now runs in batch processing steps ***
			--EXEC @Result = Result.CompileParentPopulations @DataRunID = @DataRunID, @OutputRecordCountsList = 0;
			--SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.ApplyAgeBands @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.RefreshMeasureClasses @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.RefreshMeasureMetricXrefs @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.RefreshPayers @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.CompileDataSetMemberKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.CompileDataSetMeasureProviderKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.CompileDataSetProviderKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.CompileDataSetMetricKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.CompileDataSetPopulationKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.SummarizeClaims @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.SummarizeMeasureDetail @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.SummarizeMeasureProviderDetail @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

			EXEC @Result = Result.SummarizeMemberMonthDetail @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.SummarizeMetricMonths @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.CompileDataSetMetricAgeBandKey @DataRunID = @DataRunID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
			
			EXEC @Result = Result.SummarizeMeasureByAgeBand @DataRunID = @DataRunID, @BatchID = @BatchID;
			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			SET @LogDescr = 'Summarizing all results completed successfully.'; 
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
			SET @LogDescr = 'Summarizing all results failed!';
			
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
GRANT VIEW DEFINITION ON  [Result].[SummarizeAll] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeAll] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[SummarizeAll] TO [Processor]
GO
