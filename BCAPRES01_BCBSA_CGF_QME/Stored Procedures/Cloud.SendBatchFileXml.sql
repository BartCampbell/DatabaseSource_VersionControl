SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/1/2011
-- Description:	Sends XML in the specified file format to local "apply" process for testing purposes.  
--				(This process was constructed for SQL-based testing only.  It is not references by extneral code.)
-- =============================================
CREATE PROCEDURE [Cloud].[SendBatchFileXml]
(
	@BatchID int = NULL,
	@DataRunID int = NULL,
	@FileFormatID int,
	@PrintSql bit = 0,
	@ReturnFileFormatID int = NULL
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
	--DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'SendBatchFileXML'; 
		SET @LogObjectSchema = 'Cloud'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
				
			DECLARE @CountRecords int;
			
			SELECT TOP 1
					@BeginInitSeedDate = DR.BeginInitSeedDate,
					@DataRunID = ISNULL(@DataRunID, DR.DataRunID),
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
			WHERE	((@BatchID IS NULL) OR (B.BatchID = @BatchID)) AND
					((@DataRunID IS NULL) OR (B.DataRunID = @DataRunID));
			
			--------------------------------------------------------------------------
			
			DECLARE @FileFormatTypeID int;
			SELECT @FileFormatTypeID = FileFormatTypeID FROM Cloud.FileFormatTypes WHERE FileFormatTypeGuid = '11A61BE1-FF41-4CD4-8757-1ED603786C5F';
			
			IF EXISTS(SELECT TOP 1 1 FROM Cloud.FileFormats WHERE FileFormatID = @FileFormatID AND FileFormatTypeID = @FileFormatTypeID)
				BEGIN
					--Referenced from the "get" process-------------------------------------------------------------------
					
					DECLARE @BGuid uniqueidentifier;
					DECLARE @BID int;
					
					DECLARE @FileFormatGuid uniqueidentifier;
					DECLARE @MeasureSetGuid uniqueidentifier;
					DECLARE @OwnerGuid uniqueidentifier;
					DECLARE @ReturnFileFormatGuid uniqueidentifier;
					
					SELECT TOP 1
							@FileFormatGuid = NFF.FileFormatGuid, 
							@MeasureSetGuid = MMS.MeasureSetGuid, 
							@OwnerGuid = BDO.OwnerGuid,	
							@ReturnFileFormatGuid = NULLIF(RTN.FileFormatGuid, NFF.FileFormatGuid)		
					FROM	[Cloud].[FileFormats] AS NFF
							CROSS JOIN [Batch].[DataOwners] AS BDO 
							CROSS JOIN [Measure].[MeasureSets] AS MMS 
							CROSS JOIN [Cloud].[FileFormats] AS RTN
					WHERE	(NFF.FileFormatID = @FileFormatID) AND 
							(BDO.OwnerID = @OwnerID) AND
							(MMS.MeasureSetID = @MeasureSetID) AND
							(RTN.FileFormatID = ISNULL(@ReturnFileFormatID, @FileFormatID));
							
					------------------------------------------------------------------------------------------------------
					
					DECLARE @Batches TABLE
					(
						BatchGuid uniqueidentifier NOT NULL,
						BatchID int NOT NULL,
						ID int IDENTITY(1,1) NOT NULL
					);
					
					INSERT INTO @Batches 
					        (BatchGuid, BatchID)
					SELECT	B.BatchGuid,
							B.BatchID
					FROM	Batch.[Batches] AS B
					WHERE	((@BatchID IS NULL) OR (B.BatchID = @BatchID)) AND
							((@DataRunID IS NULL) OR (B.DataRunID = @DataRunID)) 
					
					DECLARE @Data xml;
					DECLARE @ReturnData xml;
					
					DECLARE @ID int;
					DECLARE @MaxID int;
					SELECT @ID = MIN(ID), @MaxID = MAX(ID) FROM @Batches;
					
					IF @PrintSql = 1
						BEGIN
							PRINT '';
							PRINT '*** XML DATA PROCESSING **************************************************************************************';
							PRINT '';
							PRINT 'Data Run: ';
							PRINT @DataRunID;
							PRINT '';
							PRINT 'Owner: ';
							PRINT @OwnerID;
							PRINT @OwnerGuid;
							PRINT '';
							PRINT 'Measure Set: ';
							PRINT @MeasureSetID;
							PRINT @MeasureSetGuid;
							PRINT '';
							PRINT 'File Format: ';
							PRINT @FileFormatID;
							PRINT @FileFormatGuid;
							PRINT '';
							PRINT 'Return File Format: ';
							PRINT @ReturnFileFormatID;
							PRINT @ReturnFileFormatGuid;
							PRINT '';
							PRINT '';
						END
					
					WHILE @ID <= @MaxID
						BEGIN
								
							IF @PrintSql = 1
								BEGIN													
									PRINT '';
									PRINT '';
									PRINT '***BEGIN BATCH******************************************************';
									PRINT @BID;
									PRINT @BGuid;
									PRINT '';
								END
							
							--1) Identify current batch...
							SELECT	@BGuid = BatchGuid,
									@BID = BatchID
							FROM	@Batches
							WHERE	(ID = @ID);
					
							--2) Retrieve batch XML data...
							EXEC @Result = Cloud.GetBatchFileXML
														@BatchID = @BID, 
														@Data = @Data OUTPUT, 
														@FileFormatID = @FileFormatID, 
														@PrintSql = @PrintSql,
														@ReturnFileFormatID = @ReturnFileFormatID;
														
							--3) Send and process the data...
							IF @Result = 0 AND @Data IS NOT NULL
								EXEC @Result = Cloud.ProcessBatchFileXML 
														@BatchGuid = @BGuid, 
														@Data = @Data,
														@FileFormatGuid = @FileFormatGuid, 
														@MeasureSetGuid = @MeasureSetGuid,
														@OwnerGuid = @OwnerGuid, 
														@PrintSql = @PrintSql,
														@ReturnData = @ReturnData OUTPUT, 
														@ReturnFileFormatGuid = @ReturnFileFormatGuid;
							
							IF @Result = 0 AND @ReturnData IS NOT NULL AND @ReturnFileFormatID IS NOT NULL
								BEGIN;
									--4) Apply the return XML data, if applicable...
									EXEC @Result = Cloud.ApplyBatchFileXML
															@BatchID = @BID, 
															@Data = @ReturnData, 
															@FileFormatID = @ReturnFileFormatID,
															@InsertRecords = 1, 
															@PrintSql = @PrintSql;
									
									--5) Clean up any missing values...
									IF @Result = 0
										EXEC @Result = Cloud.CleanUpMissingValues @BatchID = @BID, @CleanUpType = 'Controller';
								END;		
							
											
							IF @PrintSql = 1
								BEGIN			
									PRINT '';
									PRINT '***END BATCH********************************************************';
									PRINT '';
									PRINT '';
								END
														
							IF @Data IS NULL	
								RAISERROR('Sending XML for BATCH failed.  The data could not be compiled into XML.', 16, 1);

														
							SET @LogDescr = 'Sending XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' succeeded.'; 
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
														
							SET @ID = ISNULL(@ID, 0) + 1;
						END;
				END;
			ELSE
				RAISERROR('Sending XML for BATCH failed.  The specified file format is not XML-based.', 16, 1);
			
			--------------------------------------------------------------------------

			SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
				
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
			SET @LogDescr = 'Sending XML for BATCH ' + ISNULL(CAST(@BatchID AS varchar), '?') + ' failed!'; 
			
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
GRANT EXECUTE ON  [Cloud].[SendBatchFileXml] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[SendBatchFileXml] TO [Submitter]
GO
