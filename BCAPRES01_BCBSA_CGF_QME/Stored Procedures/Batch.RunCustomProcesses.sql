SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/20/2011
-- Description:	Runs all custom processes associated with the current batch for the specified custom process type.
-- =============================================
CREATE PROCEDURE [Batch].[RunCustomProcesses]
(
	@BatchID int,
	@Iteration tinyint,
	@MeasureID int = NULL,
	@MeasProcTypeID tinyint
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
	
	BEGIN TRY;
		
		DECLARE @BeginInitSeedDate datetime;
		DECLARE @DataRunID int;
		DECLARE @DataSetID int;
		DECLARE @EndInitSeedDate datetime;
		DECLARE @IsLogged bit;
		DECLARE @MeasureSetID int;
		DECLARE @OwnerID int;
		DECLARE @SeedDate datetime;
		
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
		WHERE (B.BatchID = @BatchID);
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'RunCustomProcesses'; 
		SET @LogObjectSchema = 'Batch'; 
				
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
				
		DECLARE @ProcedureCount smallint;
		DECLARE @Procedures TABLE 
		(
			Descr varchar(128) NOT NULL,
			ID smallint IDENTITY(1,1) NOT NULL,
			ProcName nvarchar(128) NOT NULL,
			ProcSchema nvarchar(128) NOT NULL,
			RunOrder int NOT NULL
		);
		

		INSERT INTO @Procedures 
		SELECT	MIN(MCP.Descr) AS Descr,
				MCP.ProcName,
				MCP.ProcSchema,
				MIN(MCP.RunOrder) AS RunOrder
		FROM	Measure.CustomProcesses AS MCP
		WHERE	(MeasProcTypeID = @MeasProcTypeID) AND
				(
					(@MeasureID IS NULL) OR
					(MeasureID = @MeasureID)
				) AND
				(MeasureID IN (SELECT MeasureID FROM Measure.Measures WHERE IsEnabled = 1 AND MeasureSetID = @MeasureSetID)) AND
				(
					--Added 2/9/2017 to limit measures, when appropriate (second half of OR is intended as failsafe for multi-node processing)...
					MeasureID IN (SELECT MeasureID FROM Batch.BatchMeasures WHERE BatchID = @BatchID) OR
					NOT EXISTS (SELECT TOP 1 1 FROM Batch.BatchMeasures WHERE BatchID = @BatchID)
				)
		GROUP BY MCP.Descr,
				MCP.ProcName,
				MCP.ProcSchema
		ORDER BY RunOrder, ProcSchema, ProcName;
		
		SELECT @ProcedureCount = COUNT(*) FROM @Procedures;

		DECLARE @Descr varchar(128);
		DECLARE @ID smallint;
		DECLARE @ProcName nvarchar(128);
		DECLARE @ProcSchema nvarchar(128);
		
		DECLARE @ProcBeginDate datetime;
		DECLARE @ProcCountRecords bigint;
		DECLARE @ProcEndDate datetime;
		
		DECLARE @sql nvarchar(max);
		DECLARE @params nvarchar(max);

		DECLARE @Step int;		
		DECLARE @StepCount int;
		SET @StepCount = @ProcedureCount;
		
		SELECT @ID = 1, @Step = 1;
		
		WHILE (@ID <= @ProcedureCount)
			BEGIN
			
				--Retrieve the settings of the current stored procedure...
				/***************************************************************************************************************************/
				SELECT	@Descr = Descr,
						@ProcName = ProcName,
						@ProcSchema = ProcSchema
				FROM	@Procedures
				WHERE	(ID = @ID)
			
				--Execute the current stored procedure...
				--(This runs the actual procedure associated with the current step)
				/***************************************************************************************************************************/	
				
				SET @LogDescr = NULL;
				
				SET @ProcBeginDate = GETDATE();
				SET @ProcCountRecords = 0;
				
				--SET ANSI_WARNINGS OFF;
				
				--Determine if the current stored procedure has the required parameters...
				IF (Batch.HasProcedureParameter(@ProcSchema, @ProcName, '@BatchID') = 1) AND 
					(Batch.HasProcedureParameter(@ProcSchema, @ProcName, '@CountRecords') = 1)
				   
					--Determine if the stored procedure has the optional iteration parameter...
					IF Batch.HasProcedureParameter(@ProcSchema, @ProcName, '@Iteration') = 1
						BEGIN			
							SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT, @Iteration = @Iteration'
							SET @params = '@Result int OUTPUT, @BatchID int, @CountRecords bigint OUTPUT, @Iteration tinyint';
					
							EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID, @CountRecords = @ProcCountRecords OUTPUT, @Iteration = @Iteration;	
						END
					ELSE
						BEGIN
							SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT'
							SET @params = '@Result int OUTPUT, @BatchID int, @CountRecords bigint OUTPUT';
						
							EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID, @CountRecords = @ProcCountRecords OUTPUT;	
						END
				ELSE
					SET @LogDescr = REPLICATE(' ', 5) + CAST(@Step AS varchar) + ')' + 
										' Running custom process' +	
										' "' + @Descr + '"' + ISNULL(' for ITERATION ' + CAST(@Iteration AS varchar(32)), '') + 
										' of BATCH ' + CAST(@BatchID AS varchar(32)) +
										' aborted!  The associated stored procedure is missing one or more required parameters.';
				
				--SET ANSI_WARNINGS ON;
			
				SET @ProcEndDate = GETDATE();
			
				IF @LogDescr IS NULL
					IF @Result = 0
						SET @LogDescr = REPLICATE(' ', 5) + CAST(@Step AS varchar) + ')' + 
										' Running custom process' +	
										' "' + @Descr + '"' + ISNULL(' for ITERATION ' + CAST(@Iteration AS varchar(32)), '') + 
										' of BATCH ' + CAST(@BatchID AS varchar(32)) +
										' completed successfully.';
					ELSE
						SET @LogDescr = REPLICATE(' ', 5) + CAST(@Step AS varchar) + ')' + 
										' Running custom process' +	
										' "' + @Descr + '"' + ISNULL(' for ITERATION ' + CAST(@Iteration AS varchar(32)), '') + 
										' of BATCH ' + CAST(@BatchID AS varchar(32)) +
										' failed!';
									
				EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
													@BeginTime = @ProcBeginDate,
													@CountRecords = @ProcCountRecords,
													@DataRunID = @DataRunID,
													@DataSetID = @DataSetID,
													@Descr = @LogDescr,
													@EndTime = @ProcEndDate, 
													@EntryXrefGuid = @LogEntryXrefGuid, 
													@ExecObjectName = @LogObjectName,
													@ExecObjectSchema = @LogObjectSchema,
													@IsSuccess = 1,
													@Iteration = @Iteration,
													@SrcObjectName = @LogObjectName,
													@SrcObjectSchema = @LogObjectSchema,
													@StepNbr = @Step,
													@StepTot = @StepCount;
				
				IF @Result <> 0
					RAISERROR(@LogDescr, 16, 1);
					
				SET @ID = @ID + 1;
				SET @Step = @Step + 1;
			END;

		RETURN 0;
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
GRANT EXECUTE ON  [Batch].[RunCustomProcesses] TO [Processor]
GO
