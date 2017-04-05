SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2011
-- Description:	Processes entities, executing the stored procedures corresponding to the date comparers assigned to entity criteria.
-- =============================================
CREATE PROCEDURE [Batch].[ProcessEntities]
(
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
		SET @LogObjectName = 'ProcessEntities'; 
		SET @LogObjectSchema = 'Batch'; 
				
		---------------------------------------------------------------------------
		
		DECLARE @DateCompTypeE tinyint; --Entity
		DECLARE @DateCompTypeN tinyint; --Enrollment
		DECLARE @DateCompTypeS tinyint; --Seed Date
		DECLARE @DateCompTypeV tinyint; --Event
		DECLARE @DateCompTypeM tinyint; --Member/Demographics

		SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
		SELECT @DateCompTypeM = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'M';
		
		---------------------------------------------------------------------------
		
		DECLARE @CountRecords bigint;		
				
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
							(
								(DC.DateCompTypeID IN (@DateCompTypeS, @DateCompTypeV, @DateCompTypeM)) OR 
								(
									(DC.DateCompTypeID IN (@DateCompTypeE)) AND 
									(I.Iteration > 1)
								)
							)
		ORDER BY I.Iteration, 
				DC.IsInit DESC, 
				CASE WHEN DC.DateCompTypeID = @DateCompTypeN THEN 1 ELSE 0 END,
				DC.DateCompTypeID, 
				DC.DateComparerID 
		
		SELECT @ProcedureCount = COUNT(*) FROM @Procedures;
		
		DECLARE @DateComparerGuid uniqueidentifier;
		DECLARE @DateComparerID int;
		DECLARE @DateCompTypeID tinyint;
		DECLARE @Descr varchar(128);
		DECLARE @ID smallint;
		DECLARE @IsInit bit;
		DECLARE @Iteration tinyint;
		DECLARE @ProcName nvarchar(128);
		DECLARE @ProcSchema nvarchar(128);
		
		DECLARE @ProcBeginDate datetime;
		DECLARE @ProcCountRecords bigint;
		DECLARE @ProcEndDate datetime;
		
		DECLARE @LastIsInit bit;
		DECLARE @LastIteration tinyint;
		
		DECLARE @sql nvarchar(max);
		DECLARE @params nvarchar(max);

		DECLARE @Step int;		
		DECLARE @StepCount int;
		SET @StepCount = @ProcedureCount + ISNULL((SELECT MAX(Iteration) * 6 FROM @Procedures), 0)
		
		DECLARE @EntityBaseID bigint;
		
		SELECT @ID = 1, @Step = 1;
		
		CREATE TABLE #EntityBase
		(
			Allow bit NOT NULL,
			BatchID int NOT NULL,
			BeginDate datetime NOT NULL,
			BeginOrigDate datetime NOT NULL,
			DataRunID int NOT NULL,
			DataSetID int NOT NULL,
			DataSourceID int NOT NULL,
			DateComparerID smallint NOT NULL,
			DateComparerInfo int NOT NULL,
			DateComparerLink int NULL,
			[Days] int NULL,
			DSMemberID bigint NOT NULL,
			DSProviderID bigint NULL,
			EndDate datetime NULL,
			EndOrigDate datetime NULL,
			EntityBaseID bigint NULL,
			EntityBeginDate datetime NOT NULL,
			EntityCritID int NOT NULL,
			EntityEndDate datetime NOT NULL,
			EntityEnrollInfo xml NULL,
			EntityID int NOT NULL,
			EntityInfo xml NULL,
			EntityLinkInfo xml NULL,
			EntityQtyInfo xml NULL,
			IsForIndex bit NULL,
			IsSupplemental bit NOT NULL,
			OptionNbr tinyint NOT NULL,
			Qty smallint NOT NULL,
			QtyMax smallint NOT NULL,
			QtyMin smallint NOT NULL,
			RankOrder tinyint NOT NULL,
			SourceID bigint NULL,
			SourceLinkID bigint NULL
		);
		
		DECLARE @BatchStatusC smallint; --Completed
		DECLARE @BatchStatusX smallint; --Cancelled
		SET @BatchStatusC = Batch.ConvertBatchStatusIDFromAbbrev('C');
		SET @BatchStatusX = Batch.ConvertBatchStatusIDFromAbbrev('X');
		
		WHILE 1 = 1
			BEGIN
				--Verify the current batch is still active (stop processing if the batch has been cancelled)...
				/***************************************************************************************************************************/
				IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.[Batches] WHERE ((BatchID = @BatchID) AND (BatchStatusID BETWEEN 0 AND @BatchStatusC - 2)))
					BREAK;
				
				
							
				--Retrieve the settings of the current stored procedure...
				/***************************************************************************************************************************/
				SELECT	@DateComparerGuid = DateComparerGuid,
						@DateComparerID = DateComparerID,
						@DateCompTypeID = DateCompTypeID,
						@Descr = Descr,
						@IsInit = IsInit,
						@Iteration = Iteration,
						@ProcName = ProcName,
						@ProcSchema = ProcSchema
				FROM	@Procedures
				WHERE	(ID = @ID)
				
				
				
				--Work to perform after an iteration is complete...
				--(This is the LAST set of internal processes for each iteration, identifying the entities associated with the iteration)
				/***************************************************************************************************************************/
				IF @LastIteration IS NOT NULL AND (@Iteration IS NULL OR @LastIteration <> @Iteration OR @ID > @ProcedureCount)
					BEGIN;
						--1) Copy the current iteration's records of #EntityBase to the real EntityBase...
						IF OBJECT_ID('tempdb..#EntityBase') IS NOT NULL
							BEGIN
								INSERT INTO Proxy.EntityBase
										(Allow, BatchID, BeginDate, BeginOrigDate,
										DataRunID, DataSetID, DataSourceID, DateComparerID, DateComparerInfo, DateComparerLink,
										[Days], DSMemberID, DSProviderID, EndDate, EndOrigDate, EntityBaseID, 
										EntityBeginDate, EntityCritID, EntityEndDate, EntityID, EntityInfo, EntityLinkInfo, IsForIndex,
										IsSupplemental, OptionNbr, Qty, QtyMax, QtyMin, RankOrder, SourceID, SourceLinkID)
								SELECT	Allow, BatchID, BeginDate, BeginOrigDate,
										DataRunID, DataSetID, DataSourceID, DateComparerID, DateComparerInfo, DateComparerLink,
										[Days], DSMemberID, DSProviderID, EndDate, EndOrigDate, EntityBaseID, 
										EntityBeginDate, EntityCritID, EntityEndDate, EntityID, EntityInfo, EntityLinkInfo, IsForIndex,
										IsSupplemental, OptionNbr, Qty, QtyMax, QtyMin, RankOrder, SourceID, SourceLinkID
								FROM	#EntityBase
								ORDER BY EntityBaseID, OptionNbr, RankOrder, SourceID;
																
								TRUNCATE TABLE #EntityBase;
							END;		
							
						SET @CountRecords = 0;
						
						--2) Prepare entity enrollment (run all initializing sub procedures)...
						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.ProcessEntityEnrollment @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();
						
						IF @Result = 0
							SET @LogDescr = ' - Preparing entity enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Preparing entity enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
											
						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'ProcessEntityEnrollment');
						-----------------------------------------------------------------------
												
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid, 
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'ProcessEntityEnrollment',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
						
						SET @Step = @Step + 1;
									
						--3) Calculate Continuous Enrollment...
						EXEC @Result = Batch.RunCustomProcessesForPreEnrollment @BatchID = @BatchID, @Iteration = @LastIteration;

						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.CalculateEntityEnrollment @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();
						
						IF @Result = 0
							SET @LogDescr = ' - Calculating continuous enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Calculating continuous enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
											
						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'CalculateEntityEnrollment');
						-----------------------------------------------------------------------
												
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid,  
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'CalculateEntityEnrollment',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
						
						
						SET @Step = @Step + 1;
						SET @CountRecords = 0;
						
						--4) Validate Continuous Enrollment...
						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.ValidateEntityEnrollment @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();
						
						EXEC @Result = Batch.RunCustomProcessesForPostEnrollment @BatchID = @BatchID, @Iteration = @Iteration;

						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'ValidateEntityEnrollment');
						-----------------------------------------------------------------------
						
						IF @Result = 0
							SET @LogDescr = ' - Validating continuous enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Validating continuous enrollment for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
												
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid,  
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'ValidateEntityEnrollment',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
						
						
						SET @Step = @Step + 1;
						SET @CountRecords = 0;
						
						--5) Quantify Entity Criteria (update the Qty field in EntityBase with accurate quantities)...
						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.QuantifyEntityCriteria @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();
						
						IF @Result = 0
							SET @LogDescr = ' - Quantifying entity criteria for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Quantifying entity criteria for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' +
											' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
												
						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'QuantifyEntityCriteria');
						-----------------------------------------------------------------------
												
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid,  
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'QuantifyEntityCriteria',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
						
						
						SET @Step = @Step + 1;
						SET @CountRecords = 0;
						
						--6) Analyze entity-base and enrollment data to compile final valid entities...
						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.CompileEntities @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();
						
						IF @Result = 0
							SET @LogDescr = ' - Compiling entities for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' + ' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Compiling entities for ITERATION ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' + ' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
												
						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'CompileEntities');
						-----------------------------------------------------------------------
						
						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid,  
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'CompileEntities',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
															
							
						SET @Step = @Step + 1;
						SET @CountRecords = 0;

						--7) Collapse multiple entities per period as needed...
						SET @ProcBeginDate = GETDATE();
						EXEC @Result = Batch.CollapseMultipleEntitiesInPeriod @BatchID = @BatchID, @CountRecords = @CountRecords OUT, @Iteration = @LastIteration;
						SET @ProcEndDate = GETDATE();

						IF @Result = 0
							SET @LogDescr = ' - Collapsing multiple events by period for ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' succeeded.' + ' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
						ELSE
							SET @LogDescr = ' - Collapsing multiple events by period for ' + CAST(@LastIteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
											' failed!' + ' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
												
						--Added to determine @LogEntryXrefGuid value--------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, 'CollapseMultipleEntitiesInPeriod');
						-----------------------------------------------------------------------

						EXEC @Result = Log.RecordEntry	@BatchID = @BatchID,
															@BeginTime = @ProcBeginDate,
															@CountRecords = @CountRecords,
															@DataRunID = @DataRunID,
															@DataSetID = @DataSetID,
															@Descr = @LogDescr,
															@EndTime = @ProcEndDate, 
															@EntryXrefGuid = @LogEntryXrefGuid,  
															@ExecObjectName = @LogObjectName,
															@ExecObjectSchema = @LogObjectSchema,
															@IsSuccess = 1,
															@Iteration = @LastIteration,
															@SrcObjectName = 'CollapseMultipleEntitiesInPeriod',
															@SrcObjectSchema = @LogObjectSchema,
															@StepNbr = @Step,
															@StepTot = @StepCount;
														
						SET @Step = @Step + 1;
						SET @CountRecords = 0;
															
						--8) Log previous iteration's working data...
						EXEC @Result = Batch.[LogActiveIteration] @BatchID = @BatchID, @Iteration = @LastIteration;																			
														
					END;
						
						
						
				--Exit the loop if all work is complete...	
				--(This ends all processes)
				/***************************************************************************************************************************/
				IF @ID > @ProcedureCount OR @DateComparerID IS NULL OR @Iteration IS NULL
					BREAK;
				
				
				
				--Work to perform after EntityBase has been fully "initialized"... 
				--(This is the 2ND set of internal processes to run for each iteration, after "initialization" of EntityBase is complete)
				/***************************************************************************************************************************/
				IF (@LastIsInit IS NOT NULL) AND (@LastIsInit <> @IsInit)
					BEGIN
						
						IF OBJECT_ID('tempdb..#EntityBase') IS NOT NULL
							BEGIN
								
								--1) Set the key for evaluating entity requirements...
								UPDATE t SET @EntityBaseID = EntityBaseID = ISNULL(@EntityBaseID, 0) + 1 FROM #EntityBase AS t WITH(TABLOCKX) OPTION (MAXDOP 1);
								SET @EntityBaseID = NULL;
								
								--2) Copy the current iteration's records of #EntityBase to the real EntityBase...
								INSERT INTO Proxy.EntityBase
										(Allow, BatchID, BeginDate, BeginOrigDate,
										DataRunID, DataSetID, DataSourceID, DateComparerID, DateComparerInfo, DateComparerLink,
										[Days], DSMemberID, DSProviderID, EndDate, EndOrigDate, EntityBaseID, 
										EntityBeginDate, EntityCritID, EntityEndDate, EntityID, EntityInfo, EntityLinkInfo, IsForIndex,
										IsSupplemental, OptionNbr, Qty, QtyMax, QtyMin, RankOrder, SourceID, SourceLinkID)
								SELECT	Allow, BatchID, BeginDate, BeginOrigDate,
										DataRunID, DataSetID, DataSourceID, DateComparerID, DateComparerInfo, DateComparerLink,
										[Days], DSMemberID, DSProviderID, EndDate, EndOrigDate, EntityBaseID, 
										EntityBeginDate, EntityCritID, EntityEndDate, EntityID, EntityInfo, EntityLinkInfo, IsForIndex,
										IsSupplemental, OptionNbr, Qty, QtyMax, QtyMin, RankOrder, SourceID, SourceLinkID
								FROM	#EntityBase
								ORDER BY EntityBaseID, OptionNbr, RankOrder, SourceID;
																
								TRUNCATE TABLE #EntityBase;
							END
					END
					
					
					
				--Work to perform prior to starting a new iteration...
				--(This is the 1ST set of internal processes to run for each iteration, cleaning up any previous work)
				/***************************************************************************************************************************/
				IF (@LastIteration) IS NULL OR (@LastIteration <> @Iteration)
					BEGIN						
						--1) Clear the working data from previous iteration tables, if applicable...
						DELETE FROM Proxy.EntityBase;	
						DELETE FROM Proxy.EntityEnrollment;
					END;
				
				
				
				--Execute the current stored procedure...
				--(This runs the actual procedure associated with the current step)
				/***************************************************************************************************************************/				
				SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT, @Iteration = @Iteration'
				SET @params = '@Result int OUTPUT, @BatchID int, @CountRecords bigint OUTPUT, @Iteration tinyint'
				
				SET @ProcBeginDate = GETDATE();
				SET @ProcCountRecords = 0;
				
				SET ANSI_WARNINGS OFF;
				
				--Insert the results from all other Date Comparers into #EntityBase...
				INSERT INTO #EntityBase
				        (Allow, BatchID, BeginDate, BeginOrigDate,
						DataRunID, DataSetID, DataSourceID, DateComparerID,
						DateComparerInfo, DateComparerLink, [Days],
						DSMemberID, DSProviderID, EndDate, EndOrigDate,
						EntityBaseID, EntityBeginDate, EntityCritID,
						EntityEndDate, EntityID,
						EntityInfo, EntityLinkInfo,
						IsForIndex, IsSupplemental, OptionNbr,
						Qty, QtyMax, QtyMin,
						RankOrder, SourceID, SourceLinkID)	
				EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID, @CountRecords = @ProcCountRecords OUTPUT, @Iteration = @Iteration;	
						
				SET ANSI_WARNINGS ON;
				
				--Added to determine @LogEntryXrefGuid value-------------------------
				SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, @ProcName);
				-----------------------------------------------------------------------
			
				SET @ProcEndDate = GETDATE();
			
				IF @Result = 0
					SET @LogDescr =  CASE
										WHEN @DateCompTypeID = @DateCompTypeN 
										THEN ' - Initializing entity enrollment based on'
										ELSE CASE @IsInit 
													WHEN 1 
													THEN ' - Initializing entities based on' 
													ELSE ' - Applying entity criteria for' 
													END 
										END +	
									' "' + @Descr + '" for ITERATION ' + CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
									' completed successfully.' +
									' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
				ELSE
					SET @LogDescr = CASE
										WHEN @DateCompTypeID = @DateCompTypeN 
										THEN ' - Initializing entity enrollment based on'
										ELSE CASE @IsInit 
													WHEN 1 
													THEN ' - Initializing entities based on' 
													ELSE ' - Applying entity criteria for' 
													END 
										END +	
									' "' + @Descr + '" for ITERATION ' + CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) +
									' failed!' +
									' (Step ' + CAST(@Step AS varchar(32)) + ' of ' + CAST(@StepCount AS varchar(32)) + ')'
									
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
				SET @LastIteration = @Iteration;
					
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
GRANT EXECUTE ON  [Batch].[ProcessEntities] TO [Processor]
GO
