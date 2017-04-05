SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/30/2011
-- Description:	Retrieves XML in the specified file format, containing data from the specified batch.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchFileXml_v1]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@Data xml = NULL OUTPUT,
	@FileFormatGuid uniqueidentifier = NULL,
	@FileFormatID int = NULL,
	@IncludeBatchInXmlHeader bit = 1,
	@PrintSql bit = 0,
	@ReturnFileFormatGuid uniqueidentifier = NULL,
	@ReturnFileFormatID int = NULL
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
		SET @LogObjectName = 'GetBatchFileXML'; 
		SET @LogObjectSchema = 'Cloud'; 
		
		BEGIN TRY;
			
			--Determines the BatchID if only BatchGuid sent...	
			IF @BatchGuid IS NOT NULL AND  @BatchID IS NULL
				SELECT	@BatchID = BatchID FROM Batch.[Batches] WHERE (BatchGuid = @BatchGuid);
				
			IF @BatchID IS NULL
				RAISERROR('Retrieving XML for BATCH failed.  No batch was specified.', 16, 1);
			
			IF @BatchID IS NOT NULL
				BEGIN;	
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
					
					--Determines the FileFormatID if only FileFormatGuid sent...	
					IF @FileFormatID IS NULL AND @FileFormatGuid IS NOT NULL
						BEGIN;
							SELECT @FileFormatID = FileFormatID FROM Cloud.FileFormats WHERE (FileFormatGuid = @FileFormatGuid);
						END;
						
					--Determines the ReturnFileFormatID if only ReturnFileFormatGuid sent...
					IF @ReturnFileFormatID IS NULL AND @ReturnFileFormatGuid IS NOT NULL
						BEGIN;
							SELECT @ReturnFileFormatID = FileFormatID FROM Cloud.FileFormats WHERE (FileFormatGuid = @ReturnFileFormatGuid);
						END;
					
					DECLARE @FileFormatTypeID int;
					SELECT @FileFormatTypeID = FileFormatTypeID FROM Cloud.FileFormatTypes WHERE FileFormatTypeGuid = '11A61BE1-FF41-4CD4-8757-1ED603786C5F';
					
					IF EXISTS(SELECT TOP 1 1 FROM Cloud.FileFormats WHERE FileFormatID = @FileFormatID AND FileFormatTypeID = @FileFormatTypeID)
						BEGIN
							DECLARE @CrLf nvarchar(2);
							DECLARE @Params nvarchar(max);
							DECLARE @Sql nvarchar(max);

							SET @CrLf = CHAR(13) + CHAR(10);

							SELECT @Sql =	'WITH FileAttributes AS ' + @CrLf +
											'(' + @CrLf +
											'	SELECT TOP 1' + @CrLf +
											'			' + CASE WHEN @IncludeBatchInXmlHeader = 1 THEN 'ISNULL(BB.SourceGuid, BB.BatchGuid) AS batch, ' ELSE '' END + @CrLf +
											'			NFF.FileFormatGuid AS format, ' + @CrLf +
											'			MMS.MeasureSetGuid AS measureset, BDO.OwnerGuid AS owner,' + @CrLf +	
											'			NULLIF(RTN.FileFormatGuid, NFF.FileFormatGuid) AS returnformat' + @CrLf +		
											'	FROM	Cloud.[FileFormats] AS NFF WITH(NOLOCK) ' + @CrLf +
											'			CROSS JOIN [Batch].[DataOwners] AS BDO WITH(NOLOCK) ' + @CrLf +
											'			CROSS JOIN [Batch].[Batches] AS BB WITH(NOLOCK) ' + @CrLf +
											'			CROSS JOIN [Measure].[MeasureSets] AS MMS WITH(NOLOCK) ' + @CrLf +
											'			CROSS JOIN Cloud.[FileFormats] AS RTN WITH(NOLOCK) ' + @CrLf +
											'	WHERE	(NFF.FileFormatID = @FileFormatID) AND ' + @CrLf +
											'			(BDO.OwnerID = @OwnerID) AND ' + @CrLf +
											'			(BB.BatchID = @BatchID) AND ' + @CrLf +
											'			(MMS.MeasureSetID = @MeasureSetID) AND' + @CrLf +
											'			(RTN.FileFormatID = ISNULL(@ReturnFileFormatID, @FileFormatID)) ' + @CrLf +
											')' + @CrLf +
											'SELECT * INTO #FileAttributes FROM FileAttributes;' + @CrLf + 
											@CrLf +
											'SELECT	' + @CrLf +
											'		' + CASE WHEN @IncludeBatchInXmlHeader = 1 THEN '[file].[batch] AS [batch], ' ELSE '' END + @CrLf + 
											'		[file].[format] AS [format], ' + @CrLf + 
											'		[file].[measureset] AS [measureset], ' + @CrLf + 
											'		[file].[owner] AS [owner], ' + @CrLf +
											'		[file].[returnformat] AS [returnformat], ' + @CrLf + 
											'		' + Cloud.GetSqlForBatchOutXml(@FileFormatID, DEFAULT, DEFAULT) + @CrLf +
											'FROM	#FileAttributes AS [file] ' + @CrLf +
											'FOR XML AUTO, TYPE;';

							IF @PrintSql = 1
								PRINT CONVERT(ntext, @Sql);

							DECLARE @Xml TABLE 
							(	
								data XML NOT NULL
							);

							SELECT	@Params = ISNULL(@Params + ', ', '') + NUP.ParamName + ' ' + NUP.SourceColumnDataType
							FROM	Cloud.UniversalParameters AS NUP;

							SET @Params = ISNULL(@Params + ', ', '') + '@ReturnFileFormatID int';

							INSERT INTO @Xml
							EXEC sp_executesql @Sql, @Params, 
												@BatchID = @BatchID, 
												@DataRunID = @DataRunID, 
												@DataSetID = @DataSetID, 
												@FileFormatID = @FileFormatID, 
												@MeasureSetID = @MeasureSetID, 
												@OwnerID = @OwnerID, 
												@ReturnFileFormatID = @ReturnFileFormatID;
												
							SELECT TOP 1 @Data = data FROM @Xml;
						END;
					ELSE
						RAISERROR('Retrieving XML for BATCH failed.  The specified file format is not XML-based.', 16, 1);
					
					--------------------------------------------------------------------------

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
						
					IF @Data IS NULL	
						RAISERROR('Retrieving XML for BATCH failed.  The data could not be compiled into XML.', 16, 1);
					
					--i) Store the batch data, if setting is enabled...
					IF EXISTS (SELECT 1 FROM Engine.Settings WHERE SaveBatchData = 1)
						INSERT INTO Batch.BatchData
								(BatchID,
								 CreatedBy,
								 CreatedDate,
								 Data,
								 FileFormatID)
						VALUES  (@BatchID,
								SUSER_SNAME(),
								GETDATE(),
								@Data,
								@FileFormatID);
					
					SET @LogDescr = 'Retrieving XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
					SET @LogEndTime = GETDATE();
					
					EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
														@BeginTime = @LogBeginTime,
														@CountRecords = @CountRecords,
														@DataRunID = @DataRunID,
														@DataSetID = @DataSetID,
														@Descr = @LogDescr,
														@EndTime = @LogEndTime, 
														@IsSuccess = 1,
														@SrcObjectName = @LogObjectName,
														@SrcObjectSchema = @LogObjectSchema;
				END;

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
			SET @LogDescr = 'Retrieving XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; --{FAILURE LOG DESCRIPTION HERE}
			
			EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
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
GRANT EXECUTE ON  [Cloud].[GetBatchFileXml_v1] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchFileXml_v1] TO [Submitter]
GO
