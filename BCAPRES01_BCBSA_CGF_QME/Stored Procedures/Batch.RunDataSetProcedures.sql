SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/25/2011
-- Description:	Executes the procedures associated with the specified run of a dataset.
-- =============================================
CREATE PROCEDURE [Batch].[RunDataSetProcedures]
(
	@DataRunID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @DataRunGuid uniqueidentifier;
	DECLARE @DataSetGuid uniqueidentifier;

	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;
	
	BEGIN TRY;
		
		DECLARE @DataSetID int;
		DECLARE @MeasureSetID int;
		DECLARE @OwnerID int;
		
		SELECT	@DataRunGuid = DR.DataRunGuid,
				@DataSetID = DR.DataSetID,
				@DataSetGuid = DS.DataSetGuid,
				@MeasureSetID = DR.MeasureSetID,
				@OwnerID = DS.OwnerID
		FROM	Batch.DataRuns AS DR
				INNER JOIN Batch.DataSets AS DS
						ON DR.DataSetID = DS.DataSetID 
		WHERE	(DR.DataRunID = @DataRunID);
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RunDataSetProcedures'; 
		SET @LogObjectSchema = 'Batch'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		BEGIN TRY;
			
			SET @LogDescr = 'Batch processing of RUN-' + CAST(@DataRunGuid AS varchar(36)) + ' started.'; 
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = -1, 
												@DataRunID = @DataRunID,
												@DataSetID = @DataSetID,
												@Descr = @LogDescr,
												@EndTime = @LogEndTime, 
												@EntryXrefGuid = @LogEntryXrefGuid, 
												@IsSuccess = 1,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema;
			
			DECLARE @ProcedureCount smallint;
			DECLARE @Procedures TABLE 
			(
				BatchID int NOT NULL,
				Descr varchar(128) NOT NULL,
				ID smallint IDENTITY(1,1) NOT NULL,
				ProcName nvarchar(128) NOT NULL,
				ProcSchema nvarchar(128) NOT NULL,
				ProcGuid uniqueidentifier NOT NULL
			);
			
			WITH	BatchProcedures AS
			(
					SELECT DISTINCT
							SPECIFIC_NAME AS ProcName,
							SPECIFIC_SCHEMA AS ProcSchema
					FROM	INFORMATION_SCHEMA.PARAMETERS
					WHERE	((PARAMETER_NAME = '@BatchID') AND
							(DATA_TYPE = 'int'))
			),
			AllowedProcedures AS
			(
				SELECT DISTINCT
						P.Descr, P.ProcName, P.ProcSchema, P.ProcGuid, P.RunOrder
				FROM	Batch.[Procedures] AS P
						INNER JOIN Batch.DataSetProcedures AS DSP
								ON P.ProcID = DSP.ProcID
						INNER JOIN BatchProcedures AS BP
								ON P.ProcName = BP.ProcName AND
									P.ProcSchema = BP.ProcSchema
				WHERE	(DSP.DataSetID = @DataSetID) AND
						(DSP.IsEnabled = 1) AND
						(P.IsEnabled = 1)
			)
			INSERT INTO @Procedures 
					(BatchID, Descr, ProcName, ProcSchema, ProcGuid)
			SELECT	B.BatchID, P.Descr, P.ProcName, P.ProcSchema, P.ProcGuid
			FROM	AllowedProcedures AS P
					INNER JOIN Batch.[Batches] AS B
							ON B.DataRunID = @DataRunID
			ORDER BY B.BatchID, P.RunOrder ASC;
			
			SELECT @ProcedureCount = COUNT(*) FROM @Procedures;
			
			DECLARE @BatchID int;
			DECLARE @Descr varchar(128);
			DECLARE @ID smallint;
			DECLARE @ProcName nvarchar(128);
			DECLARE @ProcSchema nvarchar(128);
			DECLARE @ProcGuid uniqueidentifier;
			
			DECLARE @ProcBeginDate datetime;
			DECLARE @ProcEndDate datetime;
			
			DECLARE @sql nvarchar(max);
			DECLARE @params nvarchar(max);
			
			DECLARE @IsCancelled bit;
			
			SET @ID = 1;
			SET @IsCancelled = 0;
			
			DECLARE @BatchStatusC smallint;
			DECLARE @BatchStatusX smallint;
			DECLARE @BatchStatusY smallint;
			SET @BatchStatusC = Batch.ConvertBatchStatusIDFromAbbrev('C');
			SET @BatchStatusX = Batch.ConvertBatchStatusIDFromAbbrev('X');
			SET @BatchStatusY = Batch.ConvertBatchStatusIDFromAbbrev('X');
			
			WHILE (@ID <= @ProcedureCount)
				BEGIN
					SELECT	@BatchID = BatchID,
							@Descr = Descr,
							@ProcName = ProcName,
							@ProcBeginDate = GETDATE(),
							@ProcSchema = ProcSchema,
							@ProcGuid = ProcGuid
					FROM	@Procedures
					WHERE	(ID = @ID)
					
					IF EXISTS(SELECT TOP 1 1 FROM Batch.[Batches] WHERE BatchID = @BatchID AND BatchStatusID BETWEEN 0 AND @BatchStatusC - 1)
						BEGIN
							SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID'
							SET @params = '@Result int OUTPUT, @BatchID int'
							
							EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID;
						
							SET @ProcEndDate = GETDATE();
						
							IF @Result = 0
								BEGIN
									SET @LogDescr = ' - "' + @Descr + '" completed successfully.'
								END
							ELSE
								BEGIN
									SET @LogDescr = '"' + @Descr + '" failed!';
									
									RAISERROR(@LogDescr, 16, 1);
								END
						END
					ELSE IF EXISTS(SELECT TOP 1 1 FROM Batch.[Batches] WHERE BatchID = @BatchID AND BatchStatusID IN (@BatchStatusX, @BatchStatusY))
						BEGIN
							SET @ProcEndDate = GETDATE();
							SET @LogDescr = ' *** BATCH ' + CAST(@BatchID AS varchar(32)) + ' CANCELLED! *** ';
							
							DELETE FROM @Procedures WHERE BatchID = @BatchID;
							
							UPDATE	Batch.[Batches]
							SET		BatchStatusID = @BatchStatusX
							WHERE	(BatchID = @BatchID) AND
									(BatchStatusID  = @BatchStatusY);
							
							EXEC @Result = Log.RecordEntry	@BeginTime = @ProcBeginDate,
																@CountRecords = @ProcedureCount, 
																@DataRunID = @DataRunID,
																@DataSetID = @DataSetID,
																@Descr = @LogDescr,
																@EndTime = @ProcEndDate, 
																@EntryXrefGuid = @LogEntryXrefGuid, 
																@IsSuccess = 0,
																@SrcObjectName = @LogObjectName,
																@SrcObjectSchema = @LogObjectSchema;
																
							SET @IsCancelled = 1;
						END
					
					SET @ID = @ID + 1
				END

			IF @IsCancelled = 0
				SET @LogDescr = 'Batch processing of RUN-' + CAST(@DataRunGuid AS varchar(36)) + ' completed succcessfully.'; 
			ELSE
				SET @LogDescr = 'Batch processing of RUN-' + CAST(@DataRunGuid AS varchar(36)) + ' completed succcessfully, but one or more batches were cancelled.'; 
			
			SET @LogEndTime = GETDATE();
			
			UPDATE	Batch.DataSets
			SET
					CountClaims = 
									(	
										SELECT	COUNT(*) AS Cnt 
										FROM	Claim.Claims AS C WITH(NOLOCK)
										WHERE	DataSetID = @DataSetID
									)
			WHERE	DataSetID = @DataSetID;
			
			EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
												@CountRecords = @ProcedureCount, 
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
			SET @LogDescr = 'Batch processing of RUN-' + CAST(@DataRunGuid AS varchar(36)) + ' failed!';
			
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
GRANT EXECUTE ON  [Batch].[RunDataSetProcedures] TO [Processor]
GO
