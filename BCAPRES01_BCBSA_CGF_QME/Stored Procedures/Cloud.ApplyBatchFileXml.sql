SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/30/2011
-- Description:	Inserts (or only Selects, if specified) the contents of an XML string in the specified file format, as part of the specified batch.
-- =============================================
CREATE PROCEDURE [Cloud].[ApplyBatchFileXml]
(
	@BatchID int,
	@Data xml,
	@FileFormatID int,
	@InsertRecords bit = 1,
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
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Info xml;
	DECLARE @Params nvarchar(max);
	DECLARE @Sql nvarchar(max);
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'ApplyBatchFileXML'; 
		SET @LogObjectSchema = 'Cloud'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			IF @BatchID IS NULL
				RAISERROR('Applying XML for BATCH failed.  No batch was specified.', 16, 1);
				
			IF @Data IS NULL	
				RAISERROR('Applying XML for BATCH failed.  The @Data parameter is NULL.', 16, 1);
			
				
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
			
			DECLARE @FileFormatTypeID int;
			SELECT @FileFormatTypeID = FileFormatTypeID FROM Cloud.FileFormatTypes WHERE FileFormatTypeGuid = '11A61BE1-FF41-4CD4-8757-1ED603786C5F';
			
			IF EXISTS(SELECT TOP 1 1 FROM Cloud.FileFormats WHERE FileFormatID = @FileFormatID AND FileFormatTypeID = @FileFormatTypeID)
				BEGIN
				
					--SET @LogDescr = 'Applying XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' started.'; 
					--EXEC @Result = [Log].RecordProgress	@BatchID = @BatchID,
					--									@BeginTime = @LogBeginTime,
					--									@CountRecords = @CountRecords,
					--									@DataRunID = @DataRunID,
					--									@DataSetID = @DataSetID,
					--									@Descr = @LogDescr,
					--									@EndTime = NULL, 
					--									@IsSuccess = 1,
					--									@SrcObjectName = @LogObjectName,
					--									@SrcObjectSchema = @LogObjectSchema;
				
					--Purge any existing data in the "Internal" cache tables related to the current process...
					EXEC Batch.PurgeInternalTables @BatchID = @BatchID;
					
					--Import the batch file...
					DECLARE @CrLf nvarchar(2);

					SET @CrLf = CHAR(13) + CHAR(10);

					SELECT	@Params = ISNULL(@Params + ', ', '') + NUP.ParamName + ' ' + NUP.SourceColumnDataType
					FROM	Cloud.UniversalParameters AS NUP;

					SET @Params = @Params + ', @Xml xml'
					SET @Sql = Cloud.GetSqlForBatchInXml(@FileFormatID, @InsertRecords, 'file');
					
					IF @PrintSql = 1
						PRINT CONVERT(ntext, @Sql);

					DECLARE @AllowRetry bit;
					DECLARE @Retry bit;
					DECLARE @RetryAttempts tinyint;
					
					SET @AllowRetry = 1;
					SET @RetryAttempts = 0;

					WHILE ISNULL(@Retry, 1) = 1 
						BEGIN;
							SET @Retry = 0;

							BEGIN TRY
								EXEC sp_executesql @Sql, @Params, 
													@BatchID = @BatchID, 
													@DataRunID = @DataRunID, 
													@DataSetID = @DataSetID, 
													@FileFormatID = @FileFormatID, 
													@MeasureSetID = @MeasureSetID, 
													@OwnerID = @OwnerID,
													@Xml = @Data;
							END TRY
							BEGIN CATCH
								DECLARE @EM nvarchar(max);                          
								DECLARE @EN int;
								SELECT @EM = ERROR_MESSAGE();
								SELECT @EN = ERROR_NUMBER();

								SET @Retry = CASE WHEN @EN = 1205 AND ISNULL(@RetryAttempts , 0) < 5 AND @AllowRetry = 1 THEN 1 ELSE 0 END; --Retry on Deadlock

								IF @Retry = 1
									BEGIN;
										SET @RetryAttempts = ISNULL(@RetryAttempts, 0) + 1;

										IF @RetryAttempts > 3
											WAITFOR DELAY '00:00:7';
										ELSE IF @RetryAttempts > 1
											WAITFOR DELAY '00:00:10';
										ELSE
											WAITFOR DELAY '00:00:05';
									END;
								ELSE
									RAISERROR(@EM, 16, 1);
							END CATCH  
						END;                
				END;
			ELSE
				RAISERROR('Applying XML for BATCH failed.  The specified file format is not XML-based.', 16, 1);
			
			--------------------------------------------------------------------------

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
			SET @LogDescr = 'Applying XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
					
			SET @Info = 
					(	
						SELECT 
								(SELECT	'Parameters' AS [type], 
										(
											SELECT	* 
											FROM	(
														SELECT	'@BatchID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@BatchID, -1)) AS [value] 
														UNION
														SELECT	'@FileFormatID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@FileFormatID, -1)) AS [value]
														UNION
														SELECT	'@InsertRecords' AS id, 
																CONVERT(nvarchar(max), ISNULL(CONVERT(tinyint, @InsertRecords), -1)) AS [value]
														UNION
														SELECT	'@PrintSql' AS id, 
																CONVERT(nvarchar(max), ISNULL(CONVERT(tinyint, @PrintSql), -1)) AS [value]
													) AS t
											FOR XML RAW ('item'), TYPE
										) 
								FOR XML RAW ('category'), TYPE),
								(SELECT	'Local Variables' AS [type], 
										(
											SELECT	* 
											FROM	(
														SELECT	'@DataRunID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@DataRunID, -1)) AS [value] 
														UNION
														SELECT	'@DataSetID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@DataSetID, -1)) AS [value] 
														UNION
														SELECT	'@FileFormatID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@FileFormatID, -1)) AS [value] 
														UNION
														SELECT	'@MeasureSetID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@MeasureSetID, -1)) AS [value] 
														UNION
														SELECT	'@OwnerID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@OwnerID, -1)) AS [value] 
														UNION
														SELECT	'@Params' AS id, 
																ISNULL(@Params, '') AS [value] 
														UNION
														SELECT	'@Sql' AS id, 
																ISNULL(@Sql, '') AS [value]
													) AS t
											FOR XML RAW ('item'), TYPE
										) 
								FOR XML RAW ('category'), TYPE)
						FOR XML PATH ('info'), TYPE
					);
					
			EXEC @ErrorResult = [Log].RecordError	@LineNumber = @ErrorLine,
													@Message = @ErrorMessage,
													@ErrorNumber = @ErrorNumber,
													@ErrorType = 'Q',
													@ErrLogID = @ErrorLogID OUTPUT,
													@Info = @Info,
													@Severity = @ErrorSeverity,
													@Source = @ErrorSource,
													@State = @ErrorState,
													@PerformRollback = 0;
			
			
			SET @LogEndTime = GETDATE();
			SET @LogDescr = 'Applying XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!';
			
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
				
		--Info variable populated for recording issues with processing...
		
		SET @Info = 
					(	
						SELECT 
								(SELECT	'Parameters' AS [type], 
										(
											SELECT	* 
											FROM	(
														SELECT	'@BatchID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@BatchID, -1)) AS [value] 
														UNION
														SELECT	'@FileFormatID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@FileFormatID, -1)) AS [value]
														UNION
														SELECT	'@InsertRecords' AS id, 
																CONVERT(nvarchar(max), ISNULL(CONVERT(tinyint, @InsertRecords), -1)) AS [value]
														UNION
														SELECT	'@PrintSql' AS id, 
																CONVERT(nvarchar(max), ISNULL(CONVERT(tinyint, @PrintSql), -1)) AS [value]
													) AS t
											FOR XML RAW ('item'), TYPE
										) 
								FOR XML RAW ('category'), TYPE),
								(SELECT	'Local Variables' AS [type], 
										(
											SELECT	* 
											FROM	(
														SELECT	'@DataRunID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@DataRunID, -1)) AS [value] 
														UNION
														SELECT	'@DataSetID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@DataSetID, -1)) AS [value] 
														UNION
														SELECT	'@FileFormatID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@FileFormatID, -1)) AS [value] 
														UNION
														SELECT	'@MeasureSetID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@MeasureSetID, -1)) AS [value] 
														UNION
														SELECT	'@OwnerID' AS id, 
																CONVERT(nvarchar(max), ISNULL(@OwnerID, -1)) AS [value] 
														UNION
														SELECT	'@Params' AS id, 
																ISNULL(@Params, '') AS [value] 
														UNION
														SELECT	'@Sql' AS id, 
																ISNULL(@Sql, '') AS [value]
													) AS t
											FOR XML RAW ('item'), TYPE
										) 
								FOR XML RAW ('category'), TYPE)
						FOR XML PATH ('info'), TYPE
					);
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@Info = @Info,
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
GRANT EXECUTE ON  [Cloud].[ApplyBatchFileXml] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ApplyBatchFileXml] TO [Submitter]
GO
