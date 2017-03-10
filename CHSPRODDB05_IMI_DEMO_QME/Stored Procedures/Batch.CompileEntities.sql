SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/17/2011
-- Description:	Validates and compiles entities.
-- =============================================
CREATE PROCEDURE [Batch].[CompileEntities]
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
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @CalculateXml bit;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'CompileEntities'; 
		SET @LogObjectSchema = 'Batch'; 
	
		SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
				@CalculateXml = DR.CalculateXml,
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
		
		----------------------------------------------------------------------------------------------
		IF @BatchID IS NOT NULL AND	@Iteration IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Proxy.EntityBase)
			BEGIN;
				DECLARE @Result int;

				DECLARE @ProcedureCount smallint;
				DECLARE @Procedures TABLE 
				(
					Descr varchar(128) NOT NULL,
					ID smallint IDENTITY(1,1) NOT NULL,
					ProcName nvarchar(128) NOT NULL,
					ProcSchema nvarchar(128) NOT NULL
				);

				INSERT INTO @Procedures 
				SELECT	Descr,
						ProcName,
						ProcSchema 
				FROM	Measure.EntityTypes
				ORDER BY EntityTypeID;

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

				SET @ID = 1;

				CREATE TABLE #Entities
				(
					EntityBaseID bigint NOT NULL,
					EntityInfo XML NULL,
					IsSupplemental bit NOT NULL
				);

				WHILE 1 = 1
					BEGIN
						SELECT	@Descr = Descr,
								@ProcName = ProcName,
								@ProcSchema = ProcSchema
						FROM	@Procedures
						WHERE	(ID = @ID);
						
						--Added to determine @LogEntryXrefGuid value-------------------------
						SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@ProcSchema, @ProcName);
						-----------------------------------------------------------------------
					
						IF @ID > @ProcedureCount OR @ProcName IS NULL OR @ProcSchema IS NULL
							BREAK;
						
						SET @sql = 'EXEC @Result = ' + QUOTENAME(@ProcSchema) + '.' + QUOTENAME(@ProcName) + ' @BatchID = @BatchID, @CountRecords = @CountRecords OUTPUT, @Iteration = @Iteration'
						SET @params = '@Result int OUTPUT, @BatchID int, @CountRecords bigint OUTPUT, @Iteration tinyint'
						
						SET @ProcBeginDate = GETDATE();
						SET @ProcCountRecords = 0;
						

						SET ANSI_WARNINGS OFF;
						INSERT INTO #Entities (EntityBaseID, IsSupplemental)
						EXEC sp_executesql @sql, @params, @Result = @Result OUTPUT, @BatchID = @BatchID, @Iteration = @Iteration, @CountRecords = @ProcCountRecords OUTPUT;
						SET ANSI_WARNINGS ON;

						SET @ProcEndDate = GETDATE();
					
						IF @Result = 0
							SET @LogDescr = REPLICATE(' ', 5) + CAST(@ID AS varchar) + ') Identifying "' + LOWER(@Descr) + '" for entities from ITERATION ' + 
											CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) + ' succeeded.';
						ELSE
							SET @LogDescr = REPLICATE(' ', 5) + CAST(@ID AS varchar) + ') Identifying "' + LOWER(@Descr) + '" for entities from ITERATION ' + 
											CAST(@Iteration AS varchar(32)) + ' of BATCH ' + CAST(@BatchID AS varchar(32)) + ' failed!';
											
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
															@StepNbr = @ID,
															@StepTot = @ProcedureCount;
						IF @Result <> 0
							RAISERROR(@LogDescr, 16, 1);
							
						SET @ID = @ID + 1
					END
					
				CREATE CLUSTERED INDEX IX_#Entities ON #Entities (EntityBaseID ASC);

				--If applicable, combine and consolidate the "quantities" child elements with the "components" child elements...
				IF @CalculateXml = 1
					BEGIN;
						WITH Proxy_EntityBase AS
						(
							SELECT	EntityBaseID, 
									(
										SELECT	ISNULL(EntityQtyInfo.query('/quantities[1]/*'), NULL), 
												ISNULL(EntityInfo.query('/components[1]/*'), NULL)
										FOR XML PATH('components'), TYPE
									) AS Info 
							FROM	Proxy.EntityBase
						)
						SELECT	t.EntityBaseID, 
								dbo.CombineXml(PEV.Info, 1) AS EntityInfo
						INTO	#EntityInfoXml
						FROM	Proxy_EntityBase AS PEV
								INNER JOIN #Entities AS t
										ON t.EntityBaseID = PEV.EntityBaseID
						GROUP BY t.EntityBaseID;

						CREATE CLUSTERED INDEX IX_#EntityInfoXml ON #EntityInfoXml (EntityBaseID ASC);
						
						UPDATE	t
						SET		EntityInfo = x.EntityInfo
						FROM	#Entities AS t
								INNER JOIN #EntityInfoXml AS x
										ON x.EntityBaseID = t.EntityBaseID;

						DROP TABLE #EntityInfoXml;
					END;

				INSERT INTO	Proxy.Entities
						(BatchID, BeginDate, BeginOrigDate, BitProductLines,
						DataRunID, DataSetID, DataSourceID, [Days], DSMemberID,
						DSProviderID, EndDate, EndOrigDate, EnrollGroupID,
						EntityBaseID, EntityCritID, EntityID, EntityInfo,
						IsSupplemental, Iteration, LastSegBeginDate, LastSegEndDate, 
						Qty, SourceID, SourceLinkID)
				SELECT --DISTINCT <-- Removed DISTINCT when adding XML in 10/2015.  ("Shouldn't" cause problems.)
						@BatchID AS BatchID, 
						PEB.BeginDate, 
						PEB.BeginOrigDate, 
						PEN.BitProductLines,
						@DataRunID AS DataRunID, 
						@DataSetID AS DataSetID,
						PEB.DataSourceID,
						PEB.[Days],
						PEB.DSMemberID, PEB.DSProviderID,
						PEB.EndDate, PEB.EndOrigDate, PEN.EnrollGroupID, 
						PEB.EntityBaseID, PEB.EntityCritID, PEB.EntityID, 
						CASE WHEN @CalculateXml = 1 
							 THEN
									(
										SELECT	PEB.EntityBaseID AS baseId,
												dbo.ConvertDateToYYYYMMDD(PEB.BeginDate) AS beginDate, 
												PEB.DataSourceID AS [datasource],
												PEB.[Days] AS [days],
												dbo.ConvertDateToYYYYMMDD(PEB.EndDate) AS endDate,
												PEB.EntityID AS entityId,
												-1 AS id,
												CASE WHEN ISNULL(PEB.BeginDate, 0) <> ISNULL(PEB.BeginOrigDate, 0) 
													 THEN dbo.ConvertDateToYYYYMMDD(PEB.BeginOrigDate) 
													 END AS originalBeginDate,
												CASE WHEN ISNULL(PEB.EndDate, 0) <> ISNULL(PEB.EndOrigDate, 0) 
													 THEN dbo.ConvertDateToYYYYMMDD(PEB.EndOrigDate) 
													 END AS originalEndDate,
												PEB.Qty AS qty,
												CASE WHEN PEB.EntityEnrollInfo IS NOT NULL AND
															(
																PEB.EntityEnrollInfo.exist('/enrollment/@*') = 1 OR
																PEB.EntityEnrollInfo.exist('/enrollment/*') = 1
															)
													 THEN ISNULL(PEB.EntityEnrollInfo, NULL)
													 END,
												ISNULL(PEB.EntityLinkInfo, NULL),
												(
													--Since "quantities" and "components" elements had their children combined on a previous step, 
													--make a new "quantities" element that contains only the top-level "quantities" information.
													SELECT	PEB.EntityQtyInfo.value('/quantities[1]/@records', 'int') AS records,
															ISNULL(PEB.EntityQtyInfo.value('/quantities[1]/@qty', 'int'), 1) AS qty,
															PEB.EntityQtyInfo.value('/quantities[1]/@type', 'varchar(64)') AS [type],
															PEB.EntityQtyInfo.value('/quantities[1]/@typeId', 'tinyint') AS [typeId]
													FOR XML RAW('quantities'), TYPE
												),
												ISNULL(tE.EntityInfo, NULL) 
										FOR XML RAW('entity'), TYPE
									)
							 END AS EntityInfo, 
						tE.IsSupplemental,
						@Iteration AS Iteration, 
						PEN.LastSegBeginDate, PEN.LastSegEndDate, PEB.Qty,
						PEB.SourceID, PEB.SourceLinkID
				FROM	#Entities AS tE
						INNER JOIN Proxy.EntityEligible AS PEN
								ON tE.EntityBaseID = PEN.EntityBaseID 
						INNER JOIN Proxy.EntityBase AS PEB
								ON tE.EntityBaseID = PEB.EntityBaseID AND
									PEN.EntityBaseID = PEB.EntityBaseID AND
									PEB.RankOrder = 1;
									
				SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

				IF @CalculateXml = 1
					UPDATE	PE
					SET		EntityInfo.modify('replace value of (/entity[1]/@id) with sql:column("PE.DSEntityID")')
					FROM	Proxy.Entities AS PE
					WHERE	(PE.EntityInfo IS NOT NULL);
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
											@PerformRollback = 0,
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
GO
GRANT VIEW DEFINITION ON  [Batch].[CompileEntities] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CompileEntities] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[CompileEntities] TO [Processor]
GO
GO

GO
