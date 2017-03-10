SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/3/2011
-- Description:	Compiles the reference key values for the specified Data Run.
-- =============================================
CREATE PROCEDURE [Result].[CompileDataSetRunKey]
(
	@DataRunID int
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

	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileDataSetRunKey'; 
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
			
			DECLARE @AllowAutoRefresh bit;
			DECLARE @AuditRand decimal(18,6);
			DECLARE @DataRunDescr varchar(64);
			DECLARE @IsShown bit;
			DECLARE @MeasureSetDescr varchar(64);
			
			SELECT	@AllowAutoRefresh = AllowAutoRefresh, 
					@AuditRand = AuditRand,
					@DataRunDescr = DataRunDescr, 
					@IsShown = IsShown,
					@MeasureSetDescr = MeasureSetDescr
			FROM	Result.DataSetRunKey 
			WHERE	((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));
		
			DELETE FROM Result.DataSetRunKey WHERE ((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));

			IF NOT EXISTS(SELECT TOP 1 1 FROM Result.DataSetRunKey)
				TRUNCATE TABLE Result.DataSetRunKey;

			INSERT INTO Result.DataSetRunKey
					(AllowAutoRefresh, BeginInitSeedDate, CreatedDate, DataRunDescr, DataRunID, DataSetID, EndInitSeedDate, IsShown,
					MeasureSetDefaultSeedDate ,MeasureSetDescr, MeasureSetID, MeasureSetTypeID, OwnerID, OwnerDescr, SeedDate, SourceGuid)
			SELECT	ISNULL(@AllowAutoRefresh, 0) AS AllowAutoRefresh,
					DR.BeginInitSeedDate,
					DR.CreatedDate,
					ISNULL(@DataRunDescr,
						CAST(DS.DataSetID AS varchar(64)) + '.' + CAST(DR.DataRunID AS varchar(64)) + '.' + CAST(DR.MeasureSetID AS varchar(64)) + '.' +
						RIGHT(CAST(YEAR(DR.SeedDate) AS varchar(64)), 2) + '.' + CAST(MONTH(DR.SeedDate) AS varchar(64)) + '.' + CAST(DAY(DR.SeedDate) AS varchar(64))) AS DataRunDescr,
					DR.DataRunID,
					DR.DataSetID,
					DR.EndInitSeedDate,
					ISNULL(@IsShown, 0) AS IsShown,
					MMS.DefaultSeedDate,
					ISNULL(@MeasureSetDescr, MMS.Descr) AS MeasureSetDescr,
					DR.MeasureSetID,
					MMS.MeasureSetTypeID,
					DO.OwnerID,
					DO.Descr AS OwnerDescr,
					DR.SeedDate,
					DR.SourceGuid
			FROM	Batch.DataOwners AS DO
					INNER JOIN Batch.DataSets AS DS
							ON DO.OwnerID = DS.OwnerID
					INNER JOIN Batch.DataRuns AS DR
							ON DS.DataSetID = DR.DataSetID
					INNER JOIN Measure.MeasureSets AS MMS
							ON DR.MeasureSetID = MMS.MeasureSetID
			WHERE	(DR.DataRunID = @DataRunID);

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
			IF @AuditRand IS NOT NULL
				UPDATE Result.DataSetRunKey SET AuditRand = @AuditRand WHERE ((DataRunID = @DataRunID) AND (DataSetID = @DataSetID));
						
			SET @LogDescr = 'Compiling of dataset run key values completed successfully.'; 
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
			SET @LogDescr = 'Compiling of dataset run key values failed!';
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
												@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogBeginTime,
												@ErrLogID = @ErrorLogID,
												@EntryXrefGuid = @LogEntryXrefGuid, 
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
GRANT VIEW DEFINITION ON  [Result].[CompileDataSetRunKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetRunKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileDataSetRunKey] TO [Processor]
GO
