SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/20/2011
-- Description:	Processes entity enrollment, executing the stored procedures corresponding to the date comparers assigned to entity enrollment criteria.
--				(Created from Batch.ProcessEntities)
-- =============================================
CREATE PROCEDURE [Batch].[ProcessEntityEnrollment]
(
	@BatchID int,
	@CountRecords bigint = 0 OUTPUT, 
	@Iteration tinyint
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
		SET @LogObjectName = 'ProcessEntityEnrollment'; 
		SET @LogObjectSchema = 'Batch'; 
				
		---------------------------------------------------------------------------
		
		DECLARE @DateCompTypeE tinyint; --Entity
		DECLARE @DateCompTypeN tinyint; --Enrollment
		DECLARE @DateCompTypeS tinyint; --Seed Date
		DECLARE @DateCompTypeV tinyint; --Event

		SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
		
		---------------------------------------------------------------------------
				
		DECLARE @ProcedureCount smallint;
		DECLARE @Procedures TABLE 
		(
			DateComparerGuid uniqueidentifier NOT NULL,
			DateComparerID smallint NOT NULL,
			DateCompTypeID tinyint NOT NULL,
			Descr varchar(128) NOT NULL,
			ID smallint IDENTITY(1,1) NOT NULL,
			IsInit bit NOT NULL,
			Iteration tinyint NOT NULL,
			ProcName nvarchar(128) NOT NULL,
			ProcSchema nvarchar(128) NOT NULL
		);
		
		WITH MaxIteration AS
		(
			SELECT	MAX(Iteration) AS Iteration
			FROM	Measure.Entities
			WHERE	(IsEnabled = 1) AND
					(MeasureSetID = @MeasureSetID)
		),
		Iterations AS
		(
			SELECT	T.N AS Iteration
			FROM	dbo.Tally AS T
					INNER JOIN MaxIteration AS MI
							ON T.N <= MI.Iteration 
		)
		INSERT INTO @Procedures 
		SELECT	DC.DateComparerGuid,
				DC.DateComparerID,
				DC.DateCompTypeID,
				DC.Descr,
				DC.IsInit,
				I.Iteration,
				DC.ProcName,
				DC.ProcSchema 
		FROM	Measure.DateComparers AS DC
				INNER JOIN Iterations AS I
						ON DC.ProcName IS NOT NULL AND
							DC.ProcSchema IS NOT NULL AND
							DC.DateCompTypeID = @DateCompTypeN 
		WHERE	(I.Iteration = @Iteration)
		ORDER BY I.Iteration, 
				DC.IsInit DESC, 
				CASE WHEN DC.DateCompTypeID = 3 THEN 1 ELSE 0 END,
				DC.DateCompTypeID, 
				DC.DateComparerID 
		
		SELECT @ProcedureCount = COUNT(*) FROM @Procedures;
		
		DECLARE @DateComparerGuid uniqueidentifier;
		DECLARE @DateComparerID int;
		DECLARE @DateCompTypeID tinyint;
		DECLARE @Descr varchar(128);
		DECLARE @ID smallint;
		DECLARE @IsInit bit;
		DECLARE @ProcName nvarchar(128);
		DECLARE @ProcSchema nvarchar(128);
		
		DECLARE @ProcBeginDate datetime;
		DECLARE @ProcCountRecords bigint;
		DECLARE @ProcEndDate datetime;
		
		DECLARE @LastIsInit bit;
		
		DECLARE @sql nvarchar(max);
		DECLARE @params nvarchar(max);

		DECLARE @Step int;		
		DECLARE @StepCount int;
		SET @StepCount = @ProcedureCount --+ ISNULL((SELECT MAX(Iteration) * 2 FROM @Procedures), 0)
		
		SELECT @ID = 1, @Step = 1;
		
		WHILE (@ID <= @ProcedureCount)
			BEGIN
			
				--Retrieve the settings of the current stored procedure...
				/***************************************************************************************************************************/
				SELECT	@DateComparerGuid = DateComparerGuid,
						@DateComparerID = DateComparerID,
						@DateCompTypeID = DateCompTypeID,
						@Descr = Descr,
						@IsInit = IsInit,
						@ProcName = ProcName,
						@ProcSchema = ProcSchema
				FROM	@Procedures
				WHERE	(ID = @ID);
			
		
				--Execute the current stored procedure...
				--(This runs the actual procedure associated with the current step)
				/***************************************************************************************************************************/				
				SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT, @Iteration = @Iteration'
				SET @params = '@Result int OUTPUT, @BatchID int, @CountRecords bigint OUTPUT, @Iteration tinyint'
				
				SET @ProcBeginDate = GETDATE();
				SET @ProcCountRecords = 0;
				
				SET ANSI_WARNINGS OFF;
				
				EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID, @CountRecords = @ProcCountRecords OUTPUT, @Iteration = @Iteration;	

				SET ANSI_WARNINGS ON;
			
				SET @ProcEndDate = GETDATE();
			
				IF @Result = 0
					BEGIN;
						SET @LogDescr = REPLICATE(' ', 5) + CAST(@Step AS varchar) + ')' + 
										' Initializing entity enrollment based on' +	
										' "' + @Descr + '" for ITERATION ' + CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
										' completed successfully.';
						
						SET @CountRecords = ISNULL(@CountRecords, 0) + @ProcCountRecords;			
					END;
				ELSE
					SET @LogDescr = REPLICATE(' ', 5) + CAST(@Step AS varchar) + ')' + 
									' Initializing entity enrollment based on' +	
									' "' + @Descr + '" for ITERATION ' + CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
									' failed!';
									
									
				--Added to determine @LogEntryXrefGuid value---------------------------
				SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, @ProcName);
				-----------------------------------------------------------------------
															
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
													@SrcObjectName = @ProcName,
													@SrcObjectSchema = @ProcSchema,
													@StepNbr = @Step,
													@StepTot = @StepCount;
				
				IF @Result <> 0
					RAISERROR(@LogDescr, 16, 1);
					
				SET @LastIsInit = @IsInit;	
					
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
GRANT VIEW DEFINITION ON  [Batch].[ProcessEntityEnrollment] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ProcessEntityEnrollment] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[ProcessEntityEnrollment] TO [Processor]
GO
