SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/21/2014
-- Description:	Retrieves the dynamic column configurations specific to each measure component. 
-- =============================================
CREATE PROCEDURE [dbo].[GetColumnsForMedicalRecordCompositeView]
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @MeasureComponentID int;

	DECLARE @Columns nvarchar(max);
	DECLARE @ColumnsXml nvarchar(max);
	DECLARE @TableName nvarchar(max);
	DECLARE @SqlCmd nvarchar(max);

	IF OBJECT_ID('tempdb..#MeasureComponentColumns') IS NOT NULL
		DROP TABLE #MeasureComponentColumns;

	CREATE TABLE #MeasureComponentColumns
	(
		MeasureComponentID int NOT NULL,
		ColumnList nvarchar(max) NULL,
		ColumnXml nvarchar(max) NULL
	);

	CREATE UNIQUE CLUSTERED INDEX IX_#MeasureComponentColumns ON #MeasureComponentColumns(MeasureComponentID);

	INSERT INTO #MeasureComponentColumns
			(MeasureComponentID)
	SELECT	MeasureComponentID FROM dbo.MeasureComponent WHERE DestinationTable IS NOT NULL ORDER BY MeasureComponentID;


	IF OBJECT_ID('tempdb..#PseudoTally') IS NOT NULL
		DROP TABLE #PseudoTally;

	WITH PseudoTallyBase1(N) AS
	(
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 --4 rows
	),
	PseudoTallyBase2(N) AS 
	(
		SELECT 1 FROM PseudoTallyBase1 AS t1, PseudoTallyBase1 AS t2, PseudoTallyBase1 AS t3, PseudoTallyBase1 AS t4 --4^4 rows
	) 
	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N INTO #PseudoTally FROM PseudoTallyBase2 --Sequential Numbering for N

	CREATE UNIQUE INDEX IX_PseudoTally ON #PseudoTally (N);


	WHILE (1 = 1)
		BEGIN;
			SELECT @MeasureComponentID = MIN(MeasureComponentID) FROM #MeasureComponentColumns WHERE (@MeasureComponentID IS NULL) OR (MeasureComponentID > @MeasureComponentID);

			IF @MeasureComponentID IS NOT NULL      
				BEGIN;      
					SET @Columns = NULL;
					SET @ColumnsXml = NULL;
					SET @TableName = NULL;

					IF OBJECT_ID('tempdb..#ColumnList') IS NOT NULL
						DROP TABLE #ColumnList;

					WITH ColumnListBase AS
					(
						SELECT	MD.MeasureColumnID,
								MD.MeasureComponentID,
								MD.ColumnName,
								MD.DisplayText,
								MD.TableColumnName,
								MD.TableColumnRefSource,
								MD.TableColumnRefId,
								MD.TableColumnRefValue,
								ROW_NUMBER() OVER (PARTITION BY MD.MeasureComponentID ORDER BY MD.SortKey, MD.MeasureColumnID, C.ORDINAL_POSITION) AS SortBase,
								CASE WHEN MD.TableColumnName IS NOT NULL AND
										MD.TableColumnRefSource IS NOT NULL AND
										MD.TableColumnRefId IS NOT NULL AND
										MD.TableColumnRefValue IS NOT NULL
									THEN 'varchar(100)'
									ELSE DATA_TYPE + ISNULL('(' + CONVERT(nvarchar(max), CASE WHEN DATA_TYPE NOT LIKE '%int' THEN ISNULL(CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION) END) + 
													ISNULL(',' + CONVERT(nvarchar(max), NUMERIC_SCALE), '') + ')', '') 
									END AS DataType,
								QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) AS TableName
						FROM	dbo.MeasureColumn AS MD
								INNER JOIN dbo.MeasureComponent AS MC
										ON MD.MeasureComponentID = MC.MeasureComponentID
								LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS C
										ON MD.TableColumnName = C.COLUMN_NAME AND
											MC.DestinationTable = C.TABLE_NAME AND                  
											C.TABLE_CATALOG = DB_NAME() AND                  
											C.TABLE_SCHEMA = 'dbo'              
						WHERE	(MC.MeasureComponentID = @MeasureComponentID) AND
								(MD.TableColumnName NOT IN ('CreatedDate', 'CreatedUser', 'LastChangedDate', 'LastChangedUser', 
														'MedicalRecordKey', 'PursuitID', 'PursuitEventID', 'ServiceDate')) AND
								(MD.Visible = 1) AND
								(MC.EnabledOnReviews = 1) AND
								(C.COLUMN_NAME IS NOT NULL)                              
							                         
					)
					SELECT	MeasureComponentID,
							ColumnName,
							DisplayText,
							SortBase,
							DataType,
							TableName,
							TableColumnName,
							TableColumnRefSource,
							TableColumnRefId,
							TableColumnRefValue,
							CASE WHEN LEN(CONVERT(nvarchar(max), SortBase)) = 1 THEN '0' ELSE '' END + 
								CONVERT(nvarchar(max), SortBase) AS ColumnSuffix,
							CONVERT(nvarchar(max), SortBase) AS SortOrder
					INTO	#ColumnList
					FROM	ColumnListBase  
					UNION ALL
					SELECT	@MeasureComponentID AS MeasureComponentID,
							CONVERT(varchar(50), NULL) AS ColumnName,
							CONVERT(varchar(50), NULL) AS DisplayTest,
							N AS SortBase,
							CONVERT(nvarchar(128), NULL) AS DataType,
							CONVERT(nvarchar(max), NULL) AS TablName,
							CONVERT(nvarchar(128), NULL) AS TableColumnName,
							CONVERT(nvarchar(1024), NULL) AS TableColumnRefSource,
							CONVERT(nvarchar(128), NULL) AS TableColumnRefId,
							CONVERT(nvarchar(128), NULL) AS TableColumnRefValue,
							CASE WHEN LEN(CONVERT(nvarchar(max), N)) = 1 THEN '0' ELSE '' END + 
								CONVERT(nvarchar(max), N) AS ColumnSuffix,
							CONVERT(nvarchar(max), N) AS SortOrder
					FROM	#PseudoTally AS t
					WHERE	(t.N BETWEEN (SELECT TOP 1 ISNULL(MAX(SortBase), 0) + 1 AS N FROM ColumnListBase) AND 12)

					CREATE UNIQUE CLUSTERED INDEX IX_#ColumnList ON #ColumnList (SortBase);

					SELECT	@Columns = ISNULL(@Columns + ', ', '') +
											'CONVERT(nvarchar(128), ' + ISNULL('''' + ColumnName + '''', 'NULL') + ') AS [ColId' + ColumnSuffix + '], ' +
											'CONVERT(nvarchar(128), ' + ISNULL('''' + DisplayText + '''', 'NULL') + ') AS [ColTitle' + ColumnSuffix + '], ' +
											'CONVERT(nvarchar(128), ' + ISNULL('''' + DataType + '''', 'NULL') + ') AS [ColType' + ColumnSuffix + '], ' +
											'CONVERT(nvarchar(512), ' +
											CASE WHEN TableColumnName IS NOT NULL AND
														TableColumnRefSource IS NOT NULL AND
														TableColumnRefId IS NOT NULL AND
														TableColumnRefValue IS NOT NULL
												THEN '(SELECT TOP 1 [a].' + QUOTENAME(TableColumnRefValue) + ' FROM (' + TableColumnRefSource + ') AS [a] WHERE ([a].' + QUOTENAME(TableColumnRefId) + ' = ' + '[t].' + QUOTENAME(TableColumnName) + '))'
												ELSE ISNULL('[t].' + QUOTENAME(TableColumnName), 'NULL')
												END + 
											CASE WHEN DataType LIKE '%datetime'
												THEN ', 101'
												ELSE ''
												END +
											') AS [ColValue' + ColumnSuffix + ']',
							@ColumnsXml = ISNULL(@ColumnsXml, '') + 
											CASE WHEN ColumnName IS NOT NULL AND TableColumnName IS NOT NULL
												THEN '<entry ' + 
													'id="' + ColumnName + '" ' + 
													'title="' + DisplayText + '" ' + 
													'type="' + DataType + '" ' +
													'sort="' + SortOrder + '" ' + 
													''' + ISNULL(''value="'' + LTRIM(RTRIM(REPLACE(REPLACE(CONVERT(nvarchar(512), ' + 
													CASE WHEN TableColumnName IS NOT NULL AND
															TableColumnRefSource IS NOT NULL AND
															TableColumnRefId IS NOT NULL AND
															TableColumnRefValue IS NOT NULL
														THEN '(SELECT TOP 1 [a].' + QUOTENAME(TableColumnRefValue) + ' FROM (' + TableColumnRefSource + ') AS [a] WHERE ([a].' + QUOTENAME(TableColumnRefId) + ' = ' + '[t].' + QUOTENAME(TableColumnName) + '))'
														ELSE '[t].' + QUOTENAME(TableColumnName) 
														END + 
													CASE WHEN DataType LIKE '%datetime'
														THEN ', 101'
														ELSE ''
														END +
													'), ''<'', ''''), ''>'', ''''))) + ''"'', ''isnull="true"'') + '' ' +
													'/>'
												ELSE ''
												END
					FROM	#ColumnList
					ORDER BY SortBase;

					SELECT @TableName = DestinationTable FROM dbo.MeasureComponent WHERE MeasureComponentID = @MeasureComponentID;

					SET @SqlCmd = 'SELECT ' + @Columns + ', ' +
									'CONVERT(xml, ''' + @ColumnsXml + ''') AS ColumnXml, ' + 
									CONVERT(nvarchar(max), @MeasureComponentID) + ' AS MeasureComponentID ' +
									'FROM ' + @TableName + ' AS [t]';

					UPDATE #MeasureComponentColumns SET ColumnList = @Columns, ColumnXml = NULLIF(@ColumnsXml, '') WHERE MeasureComponentID = @MeasureComponentID;           
				END;
			ELSE
				BREAK;      
		END;

	SELECT * FROM #MeasureComponentColumns;
END
GO
