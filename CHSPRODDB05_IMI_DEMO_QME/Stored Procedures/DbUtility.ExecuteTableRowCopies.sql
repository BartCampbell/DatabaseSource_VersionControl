SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/13/2012
-- Description:	Copies the contents of a set of tables based on configuration data.
-- =============================================
CREATE PROCEDURE [DbUtility].[ExecuteTableRowCopies]
(
	@DmCopyConfigID int,
	@ExecuteSql bit = 0,
	@ParameterValues AS DbUtility.CopyParmaterValues READONLY,
	@PrintSql bit = 1,
	@ToKeyID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @KeyGuidColumn nvarchar(128);
	DECLARE @KeyIdColumn nvarchar(128);
	DECLARE @KeyTableName nvarchar(128);
	DECLARE @KeyTableSchema nvarchar(128);

	DECLARE @FromKeyGuid uniqueidentifier;
	DECLARE @ToKeyGuid uniqueidentifier;

	IF OBJECT_ID('tempdb..#Keys') IS NOT NULL
		DROP TABLE #Keys;

	CREATE TABLE #Keys 
	(
		DmCopyTableID int NOT NULL,
		FromKeyGuid uniqueidentifier NOT NULL,
		FromKeyID bigint NULL,
		ID bigint IDENTITY(1, 1) NOT NULL,
		ToKeyGuid uniqueidentifier NOT NULL DEFAULT (NEWID()),
		ToKeyID bigint NULL,
		PRIMARY KEY (ID ASC),
		UNIQUE (DmCopyTableID ASC, FromKeyGuid ASC)
	);

	SELECT	@KeyGuidColumn = KeyGuidColumn,
			@KeyIdColumn = KeyIdColumn,
			@KeyTableName = KeyTableName,
			@KeyTableSchema = KeyTableSchema
	FROM	DbUtility.CopyConfigs WITH(NOLOCK)
	WHERE	(DmCopyConfigID = @DmCopyConfigID);

	DECLARE @Tiers TABLE
	(
		DmCopyTableID int NOT NULL,
		Tier smallint NOT NULL,
		PRIMARY KEY (DmCopyTableID ASC)
	);

	WITH TableRelationships AS
	(
		SELECT	CTR.AllowOuterJoin,
				CTR.ChildColumn,
				CTR.ChildDmCopyTableID,
				CTR.DmCopyTableRelID,
				CTR.ParentColumn,
				CTR.ParentDmCopyTableID,
				CTR.WhereColumn,
				CTR.WhereCondition
		FROM	DbUtility.CopyTableRelationships AS CTR
				INNER JOIN DbUtility.CopyTables AS CTC
						ON CTR.ChildDmCopyTableID = CTC.DmCopyTableID AND
							CTC.DmCopyConfigID = @DmCopyConfigID
				INNER JOIN DbUtility.CopyTables AS CTP
						ON CTR.ParentDmCopyTableID = CTP.DmCopyTableID AND
							CTP.DmCopyConfigID = @DmCopyConfigID
	),
	TierBase AS
	(
		SELECT	TR.ParentDmCopyTableID AS DmCopyTableID, 0 AS Tier
		FROM	TableRelationships AS TR
		UNION 
		SELECT	TR.ChildDmCopyTableID AS DmCopyTableID, 1 AS Tier
		FROM	TableRelationships AS TR
		UNION ALL
		SELECT	child.ChildDmCopyTableID AS DmCopyTableID, parent.Tier + 1 AS Tier
		FROM	TableRelationships AS child
				INNER JOIN TierBase AS parent
						ON child.ParentDmCopyTableID = parent.DmCopyTableID AND
							child.ParentDmCopyTableID <> child.ChildDmCopyTableID 
	),
	Tiers AS
	(
		SELECT	DmCopyTableID,
				MAX(Tier) AS Tier
		FROM	TierBase
		GROUP BY DmCopyTableID
	)
	INSERT INTO @Tiers
	SELECT	t.DmCopyTableID,
			t.Tier
	FROM	Tiers AS t


	IF OBJECT_ID('tempdb..#TableColumnsList') IS NOT NULL
		DROP TABLE #TableColumnsList;

	SELECT	C.DATA_TYPE AS ColumnDataType,
			C.COLUMN_DEFAULT AS ColumnDefault,
			IDENTITY(smallint, 1, 1) AS ColumnID,
			C.COLUMN_NAME AS ColumnName,
			C.ORDINAL_POSITION AS ColumnOrdinal,
			C.DATETIME_PRECISION AS DateTimePrecision,
			COLUMNPROPERTY(OBJECT_ID(QUOTENAME(C.TABLE_CATALOG) + '.' + QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME)), COLUMN_NAME, 'IsComputed') AS IsComputed,
			COLUMNPROPERTY(OBJECT_ID(QUOTENAME(C.TABLE_CATALOG) + '.' + QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME)), COLUMN_NAME, 'IsIdentity') AS IsIdentity,
			CONVERT(bit, CASE C.IS_NULLABLE WHEN 'YES' THEN 1 ELSE 0 END) AS IsNullable,
			C.CHARACTER_MAXIMUM_LENGTH AS MaxLength,
			C.NUMERIC_PRECISION AS NumericPrecision,
			C.NUMERIC_SCALE AS NumericScale,
			QUOTENAME(T.TABLE_SCHEMA) + '.' + QUOTENAME(T.TABLE_NAME) AS TableFullName,
			C.TABLE_NAME AS TableName,
			C.TABLE_SCHEMA AS TableSchema
	INTO	#TableColumnsList
	FROM	INFORMATION_SCHEMA.COLUMNS AS C
			INNER JOIN INFORMATION_SCHEMA.TABLES AS T
					ON C.TABLE_CATALOG = T.TABLE_CATALOG AND
						C.TABLE_NAME = T.TABLE_NAME AND
						C.TABLE_SCHEMA = T.TABLE_SCHEMA AND
						T.TABLE_TYPE = 'BASE TABLE'
	ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME, C.ORDINAL_POSITION;

	CREATE UNIQUE CLUSTERED INDEX IX_#TableColumnsList ON #TableColumnsList (ColumnID ASC);
	CREATE UNIQUE NONCLUSTERED INDEX IX_#TableColumnsList_Names ON #TableColumnsList (TableSchema ASC, TableName ASC, ColumnName ASC) INCLUDE (ColumnOrdinal, IsComputed, IsIdentity, IsNullable);

	DECLARE @DmCopyTableID int;
	DECLARE @PrimaryGuidColumn nvarchar(128);
	DECLARE @PrimaryIdColumn nvarchar(128);
	DECLARE @TableAlias nvarchar(128);
	DECLARE @TableName nvarchar(128);
	DECLARE @TableSchema nvarchar(128);
	DECLARE @TableWhereColumn nvarchar(128);
	DECLARE @TableWhereCondition nvarchar(2048);

	DECLARE @Cmd nvarchar(max);
	DECLARE @CmdSqlFrom nvarchar(max);
	DECLARE @CmdSqlFromParents nvarchar(max);
	DECLARE @CmdSqlFromSourceKey nvarchar(max);
	DECLARE @CmdSqlInsert nvarchar(max);
	DECLARE @CmdSqlInsertColumns nvarchar(max);
	DECLARE @CmdSqlSelect nvarchar(max);
	DECLARE @CmdSqlSelectColumns nvarchar(max);
	DECLARE @CmdSqlUpdate nvarchar(max);
	DECLARE @CmdSqlWhere nvarchar(max);
	DECLARE @CmdSqlWhereParams nvarchar(max);
	DECLARE @CrLf nvarchar(2);

	SET @CrLf = CHAR(13) + CHAR(10);

	DECLARE @MaxTier smallint;
	DECLARE @MinTier smallint;
	DECLARE @Tier smallint;

	SELECT @MaxTier = MAX(Tier), @MinTier = MIN(Tier), @Tier = MIN(Tier) FROM @Tiers;

	IF @ExecuteSql = 1
		BEGIN TRANSACTION TCopyTables;

	WHILE (@Tier BETWEEN @MinTier AND @MaxTier)
		BEGIN;
			SELECT @DmCopyTableID = MIN(DmCopyTableID) FROM @Tiers WHERE Tier = @Tier;
			
			IF @PrintSql = 1
				PRINT '--- TIER ' + CONVERT(varchar, @Tier) + @CrLf;
					
			WHILE (@DmCopyTableID IS NOT NULL)
				BEGIN;
					--1) Construct the components of the SQL Statements...
					SELECT	@Cmd = NULL, @CmdSqlFrom = NULL, @CmdSqlFromParents = NULL, @CmdSqlFromSourceKey = NULL, 
							@CmdSqlInsert = NULL, @CmdSqlInsertColumns = NULL, @CmdSqlSelect = NULL, @CmdSqlSelectColumns = NULL, 
							@CmdSqlUpdate = NULL, @CmdSqlWhere = NULL, @CmdSqlWhereParams = NULL;
				
					SELECT	@PrimaryGuidColumn = PrimaryGuidColumn,
							@PrimaryIdColumn = PrimaryIdColumn,
							@TableAlias = TableAlias,
							@TableName = TableName,
							@TableSchema = TableSchema,
							@TableWhereColumn = WhereColumn,
							@TableWhereCondition = WhereCondition
					FROM	DbUtility.CopyTables AS CT
					WHERE	(DmCopyConfigID = @DmCopyConfigID) AND
							(DmCopyTableID = @DmCopyTableID);
					
					IF @PrintSql = 1
						PRINT '--- TABLE: ' + @TableSchema + '.' + @TableName + ' ' + REPLICATE('-', CASE WHEN LEN(@TableSchema + '.' + @TableName) >= 94 THEN 3 ELSE 96 - LEN(@TableSchema + '.' + @TableName) END);
					
					--1a) Set basic SQL statement values...
				SET @CmdSqlInsert =			'INSERT INTO ' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) + ' ';
				SET @CmdSqlSelect =			'SELECT	';
				SET @CmdSqlFrom =			'FROM	' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) + ' AS ' + QUOTENAME(@TableAlias) + ' ';
				SET @CmdSqlFromSourceKey =	'		INNER JOIN #Keys AS [SourceKey]' + @CrLf +
											'				ON ' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryIdColumn) + ' = [SourceKey].[FromKeyID] AND ' + @CrLf +
											'					[SourceKey].[DmCopyTableID] = ' + CONVERT(nvarchar(max), @DmCopyTableID) + ' ';
				SET @CmdSqlUpdate =			'UPDATE [SourceKey] ' + @CrLf + 
											'SET		[ToKeyID] = ' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryIdColumn) + @CrLf +
											'FROM	#Keys AS [SourceKey] ' + @CrLf +
											'		INNER JOIN ' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) + ' AS ' + QUOTENAME(@TableAlias) + @CrLf +
											'				ON [SourceKey].[ToKeyGuid] = ' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryGuidColumn) + ';';
				SET @CmdSqlWhere =			'WHERE	(1 = 1) '; 
						
				--1b) Determine INSERT columns...				
				SELECT	@CmdSqlInsertColumns = ISNULL(@CmdSqlInsertColumns + ', ', '') + QUOTENAME(ColumnName)
				FROM	#TableColumnsList
				WHERE	(TableName = @TableName) AND
						(TableSchema = @TableSchema) AND
						(IsComputed = 0) AND
						(IsIdentity = 0)
				ORDER BY ColumnOrdinal;
				SET	@CmdSqlInsertColumns = '		(' + @CmdSqlInsertColumns + ') ';
				
				--1c) Determine SELECT columns...
				DECLARE @Counter int;
				DECLARE @LastOrdinal int;
				DECLARE @LastDmCopyTableID int;
								
				SELECT	@Counter =				CASE WHEN @LastOrdinal = TCL.ColumnOrdinal THEN @Counter + 1 ELSE 1 END,
						@CmdSqlSelectColumns =	ISNULL(@CmdSqlSelectColumns + ', ', '') + 
												CASE WHEN Cnt.CountColumns > 1 AND @Counter = 1 THEN 'COALESCE('  ELSE '' END + 
												COALESCE (
															CASE WHEN CTR.ParentDmCopyTableID = -1 AND CTR.ParentColumn = @KeyIdColumn THEN CONVERT(nvarchar(max), @ToKeyID) + ' AS ' + QUOTENAME(TCL.ColumnName)  END,
															CASE WHEN TCL.ColumnName = @PrimaryGuidColumn THEN '[SourceKey].[ToKeyGuid] AS ' + QUOTENAME(TCL.ColumnName) END,
															QUOTENAME(Parent.TableAlias + CONVERT(nvarchar(max), CTR.DmCopyTableRelID)) + '.[ToKeyID]' +  CASE WHEN Cnt.CountColumns = 1 THEN ' AS ' + QUOTENAME(TCL.ColumnName) ELSE '' END, 
															QUOTENAME(CT.TableAlias) + '.' + QUOTENAME(TCL.ColumnName)
														 ) + 
												CASE 
													WHEN Cnt.CountColumns > 1 AND @Counter = Cnt.CountColumns 
													THEN 
														CASE 
															WHEN CTR.AllowOuterJoin = 1 
															THEN ', ' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(TCL.ColumnName) 
															ELSE '' 
															END + 
														') AS ' + QUOTENAME(TCL.ColumnName) 
													ELSE '' 
													END,
						@LastDmCopyTableID =	Parent.DmCopyTableID,
						@LastOrdinal =			TCL.ColumnOrdinal
				FROM	#TableColumnsList AS TCL
						INNER JOIN DbUtility.CopyTables AS CT
								ON TCL.TableName = CT.TableName AND
									TCL.TableSchema = CT.TableSchema
						OUTER APPLY (
										SELECT	COUNT(*) AS CountColumns
										FROM	DbUtility.CopyTableRelationships AS t
										WHERE	(t.ChildDmCopyTableID = CT.DmCopyTableID)  AND
												(t.ChildColumn = TCL.ColumnName)
									) AS Cnt
						LEFT OUTER JOIN DbUtility.CopyTableRelationships AS CTR
								ON CT.DmCopyTableID = CTR.ChildDmCopyTableID AND
									TCL.ColumnName = CTR.ChildColumn
						LEFT OUTER JOIN DbUtility.CopyTables AS Parent
								ON CTR.ParentDmCopyTableID = Parent.DmCopyTableID
				WHERE	(TCL.TableName = @TableName) AND
						(TCL.TableSchema = @TableSchema) AND
						(TCL.IsComputed = 0) AND
						(TCL.IsIdentity = 0)
				ORDER BY TCL.ColumnOrdinal;
				
				--1d) Determine JOIN structure for parent value restrictions and conversion...
				SELECT	@CmdSqlFromParents = ISNULL(@CmdSqlFromParents + @CrLf, '') + 
						'		' + CASE WHEN CTR.AllowOuterJoin = 1 THEN 'LEFT OUTER' ELSE 'INNER' END + ' JOIN #Keys AS ' + QUOTENAME(CT.TableAlias + CONVERT(nvarchar(max), CTR.DmCopyTableRelID)) + @CrLf +
						'				ON ' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(CTR.ChildColumn) + ' = ' + QUOTENAME(CT.TableAlias + CONVERT(nvarchar(max), CTR.DmCopyTableRelID)) + '.[FromKeyID] AND ' + @CrLf +
						'					' + QUOTENAME(CT.TableAlias + CONVERT(nvarchar(max), CTR.DmCopyTableRelID)) + '.[DmCopyTableID] = ' + CONVERT(nvarchar(max), CTR.ParentDmCopyTableID) +
						ISNULL(' AND ' + @CrLf +
						'					' +  QUOTENAME(@TableAlias) + '.' + QUOTENAME(CTR.WhereColumn) + ' ' + CTR.WhereCondition, '')
				FROM	DbUtility.CopyTableRelationships AS CTR
						INNER JOIN DbUtility.CopyTables AS CT
								ON CTR.ParentDmCopyTableID = CT.DmCopyTableID
				WHERE	(ChildDmCopyTableID = @DmCopyTableID);
															
				--1e) Determine WHERE criteria for "parameter" values...
				SELECT	@CmdSqlWhereParams = ISNULL(@CmdSqlWhereParams + @CrLf, '') + 
						'		AND (' +
						QUOTENAME(@TableAlias) + '.' + QUOTENAME(CPR.TableColumn) + ' = CONVERT(' + CP.ParamDataType + ', ''' + CONVERT(nvarchar(max), PV.ParamValue) + ''')' +
						') '
				FROM	DbUtility.CopyParameterRelationships AS CPR
						INNER JOIN DbUtility.CopyParameters AS CP
								ON CPR.DmCopyParamID = CP.DmCopyParamID AND
									CP.DmCopyConfigID = @DmCopyConfigID
						LEFT OUTER JOIN @ParameterValues AS PV
								ON CP.ParamName = PV.ParamName
				WHERE	(CPR.DmCopyTableID = @DmCopyTableID) AND
						((CP.IsOptional = 0) OR (PV.ParamValue IS NOT NULL));
								
				--2) Populate reference keys for matching...
				IF @PrimaryGuidColumn IS NOT NULL AND @PrimaryIdColumn IS NOT NULL
					BEGIN;
						--2a) Create the full SQL script to populate the key...
						SET		@Cmd = 
								@CmdSqlSelect + CONVERT(nvarchar(max), @DmCopyTableID) + ' AS DmCopyTableID, ' + @CrLf +
								'		' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryGuidColumn) + ' AS FromKeyGuid, ' + @CrLf +
								'		' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryIdColumn) + ' AS FromKeyID ' + @CrLf +
								@CmdSqlFrom + @CrLf +
								ISNULL(@CmdSqlFromParents + @CrLf, '') +
								@CmdSqlWhere + @CrLf + 
								ISNULL(@CmdSqlWhereParams + @CrLf, '') + 
								ISNULL('		AND (' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@TableWhereColumn) + ' ' + @TableWhereCondition + ')' + @CrLf , '') +
								'ORDER BY FromKeyID;';
						
						--2b) Print the SQL script...
						IF @PrintSql = 1 
							PRINT 'INSERT INTO #Keys ' + @CrLf + '		(DmCopyTableID, FromKeyGuid, FromKeyID) ' + @CrLf +@Cmd + REPLICATE(@CrLf, 2);
							
						IF @Cmd IS NULL 
							RAISERROR ('Invalid SQL statement for key population.', 16, 1);
							
						--2c) Execute the SQL script, populating the key...	
						IF @ExecuteSql = 1	
							INSERT INTO #Keys
									(DmCopyTableID,
									 FromKeyGuid,
									 FromKeyID)
							EXEC	(@Cmd);
					END;	
					
				--3) Copy the table row data...
				--3a) Create the full SQL script to copy the current table...		
				SET		@Cmd = 
						@CmdSqlInsert + @CrLf +
						@CmdSqlInsertColumns + @CrLf +
						@CmdSqlSelect + 
						ISNULL(@CmdSqlSelectColumns, '') + @CrLf +
						@CmdSqlFrom + @CrLf +
						ISNULL(@CmdSqlFromSourceKey + @CrLf, '') +
						ISNULL(@CmdSqlFromParents + @CrLf, '') +
						@CmdSqlWhere + @CrLf + 
						ISNULL(@CmdSqlWhereParams + @CrLf, '') + 
						ISNULL('		AND (' + QUOTENAME(@TableAlias) + '.' + QUOTENAME(@TableWhereColumn) + ' ' + @TableWhereCondition + ')' + @CrLf , '') +
						'ORDER BY ' + ISNULL(QUOTENAME(@TableAlias) + '.' + QUOTENAME(@PrimaryIdColumn), '1') + ';';
			
				--3b) Print the SQL script...
				IF @PrintSql = 1 
					PRINT @Cmd + REPLICATE(@CrLf, 2);
					
				IF @Cmd IS NULL 
					RAISERROR ('Invalid SQL statement for table copy.', 16, 1);
					
				--3c) Execute the SQL script, copying the table rows...	
				IF @ExecuteSql = 1	
					EXEC	(@Cmd);
					
				--4) Update the key with the new "To" ID values...
				IF @PrimaryGuidColumn IS NOT NULL AND @PrimaryIdColumn IS NOT NULL
					BEGIN;
						--4a) Create the full SQL script to update the "To" IDs...
						SET		@Cmd = @CmdSqlUpdate;				
						
						--4b) Print the SQL script...
						IF @PrintSql = 1 
							PRINT @Cmd + REPLICATE(@CrLf, 2);
							
						IF @Cmd IS NULL 
							RAISERROR ('Invalid SQL statement for "To" IDs update.', 16, 1);
							
						--4c) Execute the SQL script, updating the "To" IDs...	
						IF @ExecuteSql = 1	
							EXEC	(@Cmd);
					END;
				
					SELECT @DmCopyTableID = MIN(DmCopyTableID) FROM @Tiers WHERE Tier = @Tier AND DmCopyTableID > @DmCopyTableID;
				END;
				
			SET @Tier = @Tier + 1
		END;
		
	IF @ExecuteSql = 1
		IF NOT EXISTS (SELECT TOP 1 1 FROM #Keys WHERE ToKeyID IS NULL)
			BEGIN;
				COMMIT TRANSACTION TCopyTables;
				PRINT 'Copy completed successfully.'
			END;
		ELSE
			BEGIN;
				ROLLBACK TRANSACTION TCopyTables;
				RAISERROR('Copy failed.  One or more keys were not successfully copied.', 16, 1);
			END;

END

GO
GRANT VIEW DEFINITION ON  [DbUtility].[ExecuteTableRowCopies] TO [db_executer]
GO
GRANT EXECUTE ON  [DbUtility].[ExecuteTableRowCopies] TO [db_executer]
GO
GRANT EXECUTE ON  [DbUtility].[ExecuteTableRowCopies] TO [Processor]
GO
