SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/16/2016
-- Description:	Populates parent populations from their children's records
-- =============================================
CREATE PROCEDURE [Result].[CompileParentPopulations]
(
	@BatchID int = NULL,
	@CountRecords bigint = NULL OUTPUT,
	@DataRunID int,
	@IsLogged bit = 1,
	@OutputRecordCountsList bit = 1
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

	SET @LogBeginTime = GETDATE();
	SET @LogObjectName = 'CompileParentPopulations'; 
	SET @LogObjectSchema = 'Result'; 
		
	--Added to determine @LogEntryXrefGuid value---------------------------
	SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
	-----------------------------------------------------------------------

	DECLARE @Result int;

	DECLARE @OutputSql bit = 1;

    DECLARE @DataSetID int;
	DECLARE @OwnerID int;

	SELECT	@DataSetID = BDS.DataSetID,
			@OwnerID = BDS.OwnerID
	FROM	Batch.DataRuns AS BDR
			INNER JOIN Batch.DataSets AS BDS
					ON BDS.DataSetID = BDR.DataSetID
	WHERE	BDR.DataRunID = @DataRunID;

	IF @DataRunID IS NOT NULL AND
		@DataSetID IS NOT NULL AND
		NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureDetail AS RMD INNER JOIN Member.EnrollmentPopulations AS MNP ON MNP.ParentID = RMD.PopulationID WHERE RMD.DataRunID = @DataRunID AND (RMD.BatchID = @BatchID OR @BatchID IS NULL))
		BEGIN;

			SELECT * INTO #EnrollmentPopulationRelationships FROM Member.EnrollmentPopulationRelationships WHERE OwnerID = @OwnerID;
			CREATE UNIQUE CLUSTERED INDEX IX_#EnrollmentPopulationRelationships ON #EnrollmentPopulationRelationships (PopulationID, ParentID);

			DECLARE @TableList TABLE 
			(
				CountRecords bigint NULL DEFAULT(0),
				GuidColumnName nvarchar(128) NULL,
				HasBatchID bit NOT NULL,
				HasDataRunID bit NOT NULL,
				HasDataSetID bit NOT NULL,
				HasPopulationID bit NOT NULL,
				HasSourceRowGuid bit NOT NULL,
				HasSourceRowID bit NOT NULL,
				ID int IDENTITY(1, 1) NOT NULL,
				IDColumnName nvarchar(128) NULL,
				TableFullName nvarchar(265) NOT NULL,
				TableName nvarchar(128) NOT NULL,
				TableSchema nvarchar(128) NOT NULL,
				PRIMARY KEY (ID),
				UNIQUE (TableFullName)
			);

			WITH SingleColumnIndexes AS
			(
				SELECT	MIN(tC.DATA_TYPE) AS ColumnDataType,
						MIN(tK.COLUMN_NAME) AS ColumnName,
						tI.CONSTRAINT_NAME AS IndexName,
						MAX(CASE WHEN tI.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END) AS IsPrimaryKey,
						tI.TABLE_NAME AS TableName,
						tI.TABLE_SCHEMA AS TableSchema
				FROM	INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tI
						INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS tK
								ON tK.CONSTRAINT_CATALOG = tI.CONSTRAINT_CATALOG AND
									tK.CONSTRAINT_NAME = tI.CONSTRAINT_NAME AND
									tK.CONSTRAINT_SCHEMA = tI.CONSTRAINT_SCHEMA
						INNER JOIN INFORMATION_SCHEMA.COLUMNS AS tC
								ON tC.COLUMN_NAME = tK.COLUMN_NAME AND
									tC.TABLE_CATALOG = tI.TABLE_CATALOG AND
									tC.TABLE_NAME = tI.TABLE_NAME AND
									tC.TABLE_SCHEMA = tI.TABLE_SCHEMA
				GROUP BY tI.CONSTRAINT_NAME,
						tI.TABLE_CATALOG,
						tI.TABLE_NAME,
						tI.TABLE_SCHEMA
				HAVING	(COUNT(*) = 1)
			)
			INSERT INTO @TableList
			SELECT	0,
					COALESCE(
								MIN(I.GuidColumnName), 
								--CASE WHEN COUNT(DISTINCT CASE WHEN C.DATA_TYPE = 'uniqueidentifier' THEN C.COLUMN_NAME END) = 1 
								--	 THEN MIN(CASE WHEN C.DATA_TYPE = 'uniqueidentifier' THEN C.COLUMN_NAME END) 
								--	 END,
								MIN(CASE WHEN C.DATA_TYPE = 'uniqueidentifier' AND 
												I.IDColumnName LIKE '%ID' AND 
												C.COLUMN_NAME LIKE LEFT(I.IDColumnName, LEN(I.IDColumnName) - 2) + '%' 
										 THEN C.COLUMN_NAME END) 
							) AS GuidColumnName,
					MAX(CASE WHEN C.COLUMN_NAME = 'BatchID' THEN 1 ELSE 0 END) AS HasBatchID,
					MAX(CASE WHEN C.COLUMN_NAME = 'DataRunID' THEN 1 ELSE 0 END) AS HasDataRunID,
					MAX(CASE WHEN C.COLUMN_NAME = 'DataSetID' THEN 1 ELSE 0 END) AS HasDataSetID,
					MAX(CASE WHEN C.COLUMN_NAME = 'PopulationID' THEN 1 ELSE 0 END) AS HasPopulationID,
					MAX(CASE WHEN C.COLUMN_NAME = 'SourceRowGuid' THEN 1 ELSE 0 END) AS HasSourceRowGuid,
					MAX(CASE WHEN C.COLUMN_NAME = 'SourceRowID' THEN 1 ELSE 0 END) AS HasSourceRowID,
					MIN(I.IDColumnName) AS IDColumnName,
					QUOTENAME(T.TABLE_SCHEMA) + '.' + QUOTENAME(T.TABLE_NAME) AS TableFullName,
					T.TABLE_NAME AS TableName,
					T.TABLE_SCHEMA AS TableSchema
			FROM	INFORMATION_SCHEMA.TABLES AS T
					INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
							ON C.TABLE_CATALOG = T.TABLE_CATALOG AND
								C.TABLE_NAME = T.TABLE_NAME AND
								C.TABLE_SCHEMA = T.TABLE_SCHEMA
					OUTER APPLY (
									SELECT	MIN(CASE WHEN tI.IsPrimaryKey = 0 AND tI.ColumnDataType LIKE '%uniqueidentifier%' THEN tI.ColumnName END) AS GuidColumnName,
											MIN(CASE WHEN tI.IsPrimaryKey = 1 AND tI.ColumnDataType LIKE '%int%' THEN tI.ColumnName END) AS IDColumnName
									FROM	SingleColumnIndexes AS tI
									WHERE	tI.TableName = T.TABLE_NAME AND
											tI.TableSchema = T.TABLE_SCHEMA
									GROUP BY tI.TableName,
											tI.TableSchema
									HAVING	(COUNT(*) = 1)
								) AS I
			WHERE	(T.TABLE_TYPE = 'BASE TABLE') AND
					(
						(C.COLUMN_NAME IN ('BatchID', 'DataRunID', 'DataSetID', 'PopulationID', 'SourceRowGuid', 'SourceRowID')) OR
						(C.DATA_TYPE = 'uniqueidentifier')
					) AND
					(T.TABLE_SCHEMA IN ('Log', 'Result')) AND
					(T.TABLE_NAME NOT LIKE '%Key') AND
					(T.TABLE_NAME NOT IN ('MeasureAgeBandSummary', 'MetricMonthSummary'))
			GROUP BY T.TABLE_NAME,
					T.TABLE_SCHEMA
			HAVING	(
						(MAX(CASE WHEN 'PopulationID' = C.COLUMN_NAME THEN 1 ELSE 0 END) = 1) OR 
						(MAX(CASE WHEN 'SourceRowID' = C.COLUMN_NAME THEN 1 ELSE 0 END) = 1)
					)
			ORDER BY CASE WHEN T.TABLE_SCHEMA = 'Result' AND T.TABLE_NAME = 'MeasureDetail' THEN 1 ELSE 0 END DESC,
					HasPopulationID DESC, 
					HasSourceRowID ASC,
					TableFullName;

			--SELECT * FROM @TableList

			DECLARE @ID int, @MaxID int, @MinID int;
			SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM @TableList;

			DECLARE @CrLf nvarchar(2);
			DECLARE @SqlCmd nvarchar(max);
			DECLARE @SqlCmdFrom nvarchar(max);
			DECLARE @SqlColInsertList nvarchar(max);
			DECLARE @SqlColSelectList nvarchar(max);
			DECLARE @SqlParams nvarchar(max);

			DECLARE @CountInserts bigint;
			DECLARE @GuidColumnName nvarchar(128);
			DECLARE @HasBatchID bit;
			DECLARE @HasDataRunID bit;
			DECLARE @HasDataSetID bit;
			DECLARE @HasPopulationID bit;
			DECLARE @HasSourceRowGuid bit;
			DECLARE @HasSourceRowID bit;
			DECLARE @IDColumnName nvarchar(128);
			DECLARE @TableFullName nvarchar(512);
			DECLARE @TableName nvarchar(128);
			DECLARE @TableSchema nvarchar(128);

			SET @CrLf = CHAR(13) + CHAR(10);
			SET @SqlParams = '@BatchID int, @DataRunID int, @DataSetID int';

			IF OBJECT_ID('tempdb..#Key') IS NOT NULL
				DROP TABLE #Key;

			CREATE TABLE #Key 
			(
				[Guid] uniqueidentifier NOT NULL DEFAULT(NEWID()),
				[ID] bigint NULL,
				[OrigGuid] uniqueidentifier NOT NULL,
				[OrigID] bigint NOT NULL,
				[ParentID] int NOT NULL
			);

			CREATE UNIQUE CLUSTERED INDEX IX_#Key ON #Key ([OrigID], [ParentID]);
			CREATE UNIQUE NONCLUSTERED INDEX IX_#Key2 ON #Key ([OrigGuid], [ParentID]);

			IF OBJECT_ID('tempdb..#TempKey') IS NOT NULL
				DROP TABLE #TempKey;

			CREATE TABLE #TempKey 
			(
				[Guid] uniqueidentifier NOT NULL,
				[ID] bigint NOT NULL
			);

			CREATE UNIQUE CLUSTERED INDEX IX_#TempKey ON #TempKey ([Guid]);

			BEGIN TRY;
				BEGIN TRANSACTION TParentPopulationInsert;

				WHILE @ID BETWEEN @MinID AND @MaxID
					BEGIN;
						TRUNCATE TABLE #TempKey;

						SELECT	@CountInserts = NULL,
								@GuidColumnName = GuidColumnName,
								@HasBatchID = HasBatchID,
								@HasDataRunID = HasDataRunID,
								@HasDataSetID = HasDataSetID,
								@HasPopulationID = HasPopulationID,
								@HasSourceRowGuid = HasSourceRowGuid,
								@HasSourceRowID = HasSourceRowID,
								@IDColumnName = IDColumnName,
								@SqlCmd = NULL,
								@SqlCmdFrom = NULL,
								@SqlColInsertList = NULL,
								@SqlColSelectList = NULL,
								@TableFullName = TableFullName,
								@TableName = TableName,
								@TableSchema = TableSchema
						FROM	@TableList
						WHERE	ID = @ID;

						SELECT	@SqlColInsertList = 
									ISNULL(@SqlColInsertList + ', ', '') + QUOTENAME(C.COLUMN_NAME),
								@SqlColSelectList = 
									ISNULL(@SqlColSelectList + ', ', '') + 
									CASE WHEN (@HasSourceRowGuid = 1 AND C.COLUMN_NAME = 'SourceRowGuid') OR
											  (@ID = 1 AND @TableName = 'MeasureDetail' AND C.COLUMN_NAME = @GuidColumnName)
										 THEN '[k].[Guid]'
										 WHEN @HasSourceRowID = 1 AND C.COLUMN_NAME = 'SourceRowID'
										 THEN '[k].[ID]'
										 WHEN C.DATA_TYPE = 'uniqueidentifier' AND
											  C.COLUMN_NAME IN ('LogGuid', 'ResultRowGuid')
										 THEN 'NEWID() AS ' + QUOTENAME(C.COLUMN_NAME)
										 WHEN C.COLUMN_NAME = 'PopulationID'
										 THEN '[p].[ParentID]'
										 ELSE '[t].' + QUOTENAME(C.COLUMN_NAME)
										 END 						 
						FROM	INFORMATION_SCHEMA.COLUMNS AS C
						WHERE	C.TABLE_NAME = @TableName AND
								C.TABLE_SCHEMA = @TableSchema AND
								COLUMNPROPERTY(OBJECT_ID(QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME)), C.COLUMN_NAME ,'IsComputed') = 0 AND
								(
									(C.COLUMN_NAME NOT IN (ISNULL(@GuidColumnName, ''), ISNULL(@IDColumnName, ''))) OR
									(
										@ID = 1 AND
										@TableName = 'MeasureDetail' AND
										C.COLUMN_NAME NOT IN (ISNULL(@IDColumnName, ''))
									)
								)
						ORDER BY C.COLUMN_NAME;

						SET @SqlCmdFrom = 
							'FROM	' + @TableFullName + ' AS [t]' + @CrLf +
							CASE WHEN @HasPopulationID = 1 
								 THEN '		LEFT OUTER JOIN #EnrollmentPopulationRelationships AS [p]' + @CrLf +
									  '				ON [p].[PopulationID] = [t].[PopulationID]' + @CrLf
								 ELSE ''
								 END +
							CASE WHEN (@HasPopulationID = 0 AND (@HasSourceRowGuid = 1 OR @HasSourceRowID = 1) AND (@GuidColumnName IS NOT NULL OR @IDColumnName IS NOT NULL)) OR
									  (@ID = 1 AND @TableName = 'MeasureDetail')
								 THEN '		LEFT OUTER JOIN #Key AS [k]' + @CrLf +
									  '				ON 1 = 1 ' + @CrLf +
									  ISNULL('					AND [k].[OrigGuid] = [t].' + QUOTENAME(CASE WHEN @ID = 1 THEN @GuidColumnName WHEN @HasSourceRowGuid = 1 THEN 'SourceRowGuid' END) + @CrLf, '') + 
									  ISNULL('					AND [k].[OrigID] = [t].' + QUOTENAME(CASE WHEN @ID = 1 THEN @IDColumnName WHEN @HasSourceRowID = 1 THEN 'SourceRowID' END) + @CrLf, '')
									  -- NEED TO ADD PARENTID FILTER -------------------------------------------------
								 ELSE ''
								 END +
							CASE WHEN @ID = 1 AND @TableName = 'MeasureDetail'
								 THEN '					AND [k].[ParentID] = [p].[ParentID]' + @CrLf
								 ELSE ''
								 END +
							'WHERE	(1 = 1) ' + @CrLf +
							CASE WHEN @HasPopulationID = 1 
								 THEN '		AND ([p].[ParentID] IS NOT NULL)' + @CrLf 
								 ELSE ''
								 END +
							CASE WHEN @HasBatchID = 1 AND @BatchID IS NOT NULL
								 THEN '		AND ([t].[BatchID] = @BatchID)' + @CrLf
								 WHEN @HasBatchID = 1 AND @HasDataRunID = 0 
								 THEN '		AND ([t].[BatchID] IN (SELECT [BatchID] FROM [Batch].[Batches] WITH(NOLOCK) WHERE DataRunID = @DataRunID)' + @CrLf
								 ELSE '' 
								 END +
							CASE WHEN @HasDataRunID = 1 
								 THEN '		AND ([t].[DataRunID] = @DataRunID)' + @CrLf 
								 ELSE '' 
								 END +
							CASE WHEN @HasDataSetID = 1 
								 THEN '		AND ([t].[DataSetID] = @DataSetID)' + @CrLf 
								 ELSE '' 
								 END +
							CASE WHEN @HasPopulationID = 0 AND (@HasSourceRowGuid = 1 OR @HasSourceRowID = 1) AND (@GuidColumnName IS NOT NULL OR @IDColumnName IS NOT NULL)
								 THEN '		AND ([k].[ID] IS NOT NULL)' + @CrLf 
								 ELSE '' 
								 END;

						SET @SqlCmd = 
							'INSERT INTO ' + @TableFullName + @CrLf +
							'		(' + @SqlColInsertList + ')' + @CrLf +
							CASE WHEN @GuidColumnName IS NOT NULL AND @IDColumnName IS NOT NULL AND 
									  @HasSourceRowGuid = 0 AND @HasSourceRowID = 0 AND
									  @ID = 1 AND @TableName = 'MeasureDetail' --Result.MeasureDetail only (due to Log.PCR_ClinicalConditions missing SourceRowGuid)
								 THEN 'OUTPUT	INSERTED.' + QUOTENAME(@GuidColumnName) + ', INSERTED.' + QUOTENAME(@IDColumnName) + 
									  ' INTO #TempKey ([Guid], [ID])' + @CrLf
								 ELSE ''
								 END + 
							'SELECT	' + @SqlColSelectList + @CrLf +
							@SqlCmdFrom +
							CASE WHEN @IDColumnName IS NOT NULL
								 THEN 'ORDER BY [t].' + QUOTENAME(@IDColumnName)
								 ELSE ''
								 END +
							';' ;

						IF @ID = 1 AND @TableName = 'MeasureDetail'
							BEGIN;
								SET @SqlCmd = 
										'INSERT INTO #Key' + @CrLf +
										'		([OrigGuid], [OrigID], [ParentID])' + @CrLf +
										'SELECT	[t].' + QUOTENAME(@GuidColumnName) + ', [t].' + QUOTENAME(@IDColumnName) + ', ' + @CrLf +
										'		[p].[ParentID]' + @CrLf +
										'FROM	' + @TableFullName + ' AS [t]' + @CrLf +
										CASE WHEN @HasPopulationID = 1 
											 THEN '		INNER JOIN #EnrollmentPopulationRelationships AS [p]' + @CrLf +
												  '				ON [p].[PopulationID] = [t].[PopulationID]' + @CrLf
											 ELSE ''
											 END +
										'WHERE	(1 = 1) ' + @CrLf +
										CASE WHEN @HasBatchID = 1 AND @BatchID IS NOT NULL
											 THEN '		AND ([t].[BatchID] = @BatchID)' + @CrLf
											 WHEN @HasBatchID = 1 AND @HasDataRunID = 0 
											 THEN '		AND ([t].[BatchID] IN (SELECT [BatchID] FROM [Batch].[Batches] WITH(NOLOCK) WHERE DataRunID = @DataRunID)' + @CrLf
											 ELSE ''
											 END +
										CASE WHEN @HasDataRunID = 1 
											 THEN '		AND ([t].[DataRunID] = @DataRunID)' + @CrLf 
											 ELSE '' 
											 END +
										CASE WHEN @HasDataSetID = 1 
											 THEN '		AND ([t].[DataSetID] = @DataSetID)' + @CrLf 
											 ELSE '' 
											 END +
										';' + @CrLf +
										@CrLf +
										@SqlCmd;
							END;

						IF @OutputSql = 1
							BEGIN;
								PRINT '*** ' + @TableFullName + ' ' + REPLICATE('*', 100 - LEN(@TableFullName));
								PRINT @SqlCmd;
								PRINT @CrLf + @CrLf;
							END;

						IF @SqlCmd IS NOT NULL
							BEGIN;
								EXEC sys.sp_executesql @SqlCmd, @SqlParams, @BatchID = @BatchID, @DataRunID = @DataRunID, @DataSetID = @DataSetID;
								SET @CountInserts = @@ROWCOUNT;

								UPDATE @TableList SET CountRecords = @CountInserts WHERE ID = @ID;

								SET @CountRecords = ISNULL(@CountRecords, 0) + @CountInserts;
							END;

						IF EXISTS(SELECT TOP 1 1 FROM #TempKey)
							UPDATE	K
							SET		ID = TK.ID
							FROM	#Key AS K
									INNER JOIN #TempKey AS TK
											ON TK.[Guid] = K.[Guid];

						SET @ID = @ID + 1;
					END;

				COMMIT TRANSACTION TParentPopulationInsert;

				IF @OutputRecordCountsList = 1
					SELECT	TableFullName AS [Table Name],
							CountRecords AS [Inserted Rows]
					FROM	@TableList
					ORDER BY 1;

				SET @LogDescr = 'Compiling of parent populations completed successfully.'; 
				SET @LogEndTime = GETDATE();

				IF @IsLogged = 1
					EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
													@CountRecords = @CountRecords,
													@DataRunID = @DataRunID,
													@DataSetID = @DataSetID,
													@Descr = @LogDescr,
													@EndTime = @LogEndTime, 
													@EntryXrefGuid = @LogEntryXrefGuid, 
													@IsSuccess = 1,
													@SrcObjectName = @LogObjectName,
													@SrcObjectSchema = @LogObjectSchema;

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
				SET @LogDescr = 'Compiling of parent populations failed!';
			
				IF @IsLogged = 1
					EXEC @Result = Log.RecordEntry	@BeginTime = @LogBeginTime,
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
			END CATCH;	
		END;
	ELSE
		PRINT 'Unable to insert parent populations.  The specified data run is invalid or has already had parent populations compiled.';
END

GO
GRANT VIEW DEFINITION ON  [Result].[CompileParentPopulations] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileParentPopulations] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[CompileParentPopulations] TO [Processor]
GO
