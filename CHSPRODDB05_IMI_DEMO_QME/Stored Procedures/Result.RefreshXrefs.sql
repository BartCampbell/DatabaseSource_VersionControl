SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/19/2012
-- Description:	Refresh measure/metric cross-references on all results tables.
-- =============================================
CREATE PROCEDURE [Result].[RefreshXrefs]
(
	@BatchID int = NULL,
	@DataRunID int = NULL,
	@PrintSql bit = 0
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

	DECLARE @DataRun int;
	DECLARE @DataSetID int;
	DECLARE @MbrMonthID int;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RefreshXrefs'; 
		SET @LogObjectSchema = 'Result'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
		
		BEGIN TRY;				
			DECLARE @CountRecords int;
			
			SELECT TOP 1	
					@DataRun = B.DataRunID,
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
			WHERE	((@DataRunID IS NULL) OR (DR.DataRunID = @DataRunID)) AND
					((@BatchID IS NULL) OR (B.BatchID = @BatchID));
			
			---------------------------------------------------------------------------
			
			DECLARE @CrLf nvarchar(512);
			SET @CrLf = CHAR(13) + CHAR(10);
			
			WITH ResultXrefs AS
			(
				SELECT	MAX(CASE WHEN C.COLUMN_NAME = 'BatchID' THEN 1 ELSE 0 END) AS HasBatch,
						MAX(CASE WHEN C.COLUMN_NAME = 'DataRunID' THEN 1 ELSE 0 END) AS HasDataRun,
						MAX(CASE WHEN C.COLUMN_NAME = 'DataSetID' THEN 1 ELSE 0 END) AS HasDataSet,
						MAX(CASE WHEN C.COLUMN_NAME = 'MeasureID' THEN 1 ELSE 0 END) AS HasMeasure,
						MAX(CASE WHEN C.COLUMN_NAME = 'MeasureXrefID' THEN 1 ELSE 0 END) AS HasMeasureXref,
						MAX(CASE WHEN C.COLUMN_NAME = 'MetricID' THEN 1 ELSE 0 END) AS HasMetric,
						MAX(CASE WHEN C.COLUMN_NAME = 'MetricXrefID' THEN 1 ELSE 0 END) AS HasMetricXref,
						C.TABLE_NAME AS TableName,
						C.TABLE_SCHEMA AS TableSchema
				FROM	INFORMATION_SCHEMA.COLUMNS AS C
						INNER JOIN INFORMATION_SCHEMA.TABLES AS T
								ON C.TABLE_CATALOG = T.TABLE_CATALOG AND
									C.TABLE_NAME = T.TABLE_NAME AND
									C.TABLE_SCHEMA = T.TABLE_SCHEMA AND
									T.TABLE_TYPE = 'BASE TABLE'
				WHERE	(C.COLUMN_NAME IN ('BatchID', 'DataRunID', 'DataSetID', 'MeasureID', 'MeasureXrefID', 'MetricID', 'MetricXrefID')) AND
						(C.TABLE_SCHEMA IN ('Result'))
				GROUP BY C.TABLE_NAME,
						C.TABLE_SCHEMA
				HAVING	(
							(MAX(CASE WHEN C.COLUMN_NAME = 'MeasureID' THEN 1 ELSE 0 END) = 1) AND
							(MAX(CASE WHEN C.COLUMN_NAME = 'MeasureXrefID' THEN 1 ELSE 0 END) = 1)
						) OR
						(
							(MAX(CASE WHEN C.COLUMN_NAME = 'MetricID' THEN 1 ELSE 0 END) = 1) AND
							(MAX(CASE WHEN C.COLUMN_NAME = 'MetricXrefID' THEN 1 ELSE 0 END) = 1)
						)	
			)
			SELECT	'UPDATE	t ' + @CrLf +
					'SET	' + @CrLf +
					CASE WHEN HasMetric = 1 AND HasMetricXref = 1 
					THEN	'		MeasureXrefID = MM.MeasureXrefID, ' + @CrLf
					ELSE	''
					END +
					CASE WHEN HasMetric = 1 AND HasMetricXref = 1 
					THEN	'		MetricXrefID = MX.MetricXrefID ' + @CrLf 
					ELSE	''
					END +
					'FROM	' + QUOTENAME(TableSchema) + '.' + QUOTENAME(TableName) + ' AS t ' + @CrLf +
					CASE WHEN HasMetric = 1 AND HasMetricXref = 1 
					THEN	'		INNER JOIN [Measure].[Metrics] AS MX ' + @CrLf +
							'				ON t.MetricID = MX.MetricID ' + @CrLf
					ELSE	''
					END +
					CASE WHEN HasMeasure = 1 AND HasMeasureXref = 1
					THEN	'		INNER JOIN [Measure].[Measures] AS MM ' + @CrLf +
							'				ON t.MeasureID = MM.MeasureID '  + @CrLf
					ELSE	''
					END +
					'WHERE	(1 = 1) ' + @CrLf +
					CASE WHEN @BatchID IS NOT NULL AND HasBatch = 1
					THEN	'		AND (t.BatchID = ' + CONVERT(nvarchar(512), @BatchID) + ') ' + @CrLf
					ELSE	''
					END +
					CASE WHEN (@DataRunID IS NOT NULL OR @BatchID IS NOT NULL) AND HasDataRun = 1
					THEN	'		AND (t.DataRunID = ' + CONVERT(nvarchar(512), @DataRun) + ') ' + @CrLf
					ELSE	''
					END +
					CASE WHEN (@DataRunID IS NOT NULL OR @BatchID IS NOT NULL) AND @DataSetID IS NOT NULL AND HasDataSet = 1
					THEN	'		AND (t.DataSetID = ' + CONVERT(nvarchar(512), @DataSetID) + ') ' + @CrLf
					ELSE	''
					END 
					AS Cmd,
					IDENTITY(smallint, 1, 1) AS ID
			INTO	#Cmds
			FROM	ResultXrefs
			ORDER BY TableSchema, TableName;
			
			DECLARE @Cmd nvarchar(max);
			DECLARE @ID smallint;
			DECLARE @MaxID smallint;
			DECLARE @MinID smallint;
			
			SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #Cmds;
			
			WHILE @ID BETWEEN @MinID AND @MaxID
				BEGIN;
					SELECT @Cmd = Cmd FROM #Cmds WHERE ID = @ID;
					
					IF @PrintSql = 1
						PRINT '*** Execute Command *************************' + @CrLf + @Cmd + @CrLf + @CrLf;
					
					EXEC (@Cmd);
					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
					SET @ID = @ID + 1;
				END;		
						
			SET @LogDescr = 'Refreshing measure/metric cross-references in results completed successfully.'; 
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
			SET @LogDescr = 'Refreshing measure/metric cross-references in results failed!';
			
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
GRANT EXECUTE ON  [Result].[RefreshXrefs] TO [Processor]
GO
