SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[RefreshMedicalRecordCompositeView]
AS 
BEGIN;
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#DynamicColumns') IS NOT NULL
		DROP TABLE #DynamicColumns;

	CREATE TABLE #DynamicColumns
	(
		MeasureComponentID int NOT NULL,
		ColumnList nvarchar(max) NULL,
		ColumnXml nvarchar(max) NULL
	);

	INSERT INTO #DynamicColumns
	        (MeasureComponentID,
	         ColumnList,
	         ColumnXml)
	EXEC dbo.GetColumnsForMedicalRecordCompositeView;

	IF OBJECT_ID('tempdb..#DataEntryTables') IS NOT NULL
		DROP TABLE #DataEntryTables;

	SELECT	DC.ColumnList,
			DC.ColumnXml,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'CreatedDate' THEN 1 ELSE 0 END)) AS HasCreatedDate,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'CreatedUser' THEN 1 ELSE 0 END)) AS HasCreatedUser,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'LastChangedDate' THEN 1 ELSE 0 END)) AS HasLastChangedDate,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'LastChangedUser' THEN 1 ELSE 0 END)) AS HasLastChangedUser,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'MedicalRecordKey' THEN 1 ELSE 0 END)) AS HasMedicalRecordKey,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'PursuitID' THEN 1 ELSE 0 END)) AS HasPursuitID,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'PursuitEventID' THEN 1 ELSE 0 END)) AS HasPursuitEventID,
			CONVERT(bit, MAX(CASE WHEN IC.COLUMN_NAME = 'ServiceDate' THEN 1 ELSE 0 END)) AS HasServiceDate,
			MC.MeasureComponentID,
			IC.TABLE_NAME AS TableName, 
			IC.TABLE_SCHEMA AS TableSchema
	INTO	#DataEntryTables
	FROM	INFORMATION_SCHEMA.COLUMNS AS IC
			INNER JOIN dbo.MeasureComponent AS MC
					ON IC.TABLE_NAME = MC.DestinationTable AND
						IC.TABLE_CATALOG = DB_NAME() AND
						IC.TABLE_SCHEMA = 'dbo'
			INNER JOIN #DynamicColumns AS DC
					ON MC.MeasureComponentID = DC.MeasureComponentID
	WHERE	MC.EnabledOnWebsite = 1
	GROUP BY MC.MeasureComponentID,
			DC.ColumnXml,
			DC.ColumnList,
			IC.TABLE_NAME, 
			IC.TABLE_SCHEMA;

	CREATE UNIQUE CLUSTERED INDEX IX_#DataEntryTables ON #DataEntryTables (TableName, TableSchema, MeasureComponentID);

	DECLARE @CrLf nvarchar(max);
	DECLARE @SqlCmd nvarchar(max);

	SET @CrLf = CHAR(13) + CHAR(10);

	SELECT	@SqlCmd = ISNULL(@SqlCmd + @CrLf + 'UNION ALL ' + @CrLf, '') + 
						'SELECT ' + 
						CASE WHEN HasMedicalRecordKey = 1 THEN '[t].[MedicalRecordKey]' ELSE 'NULL AS [MedicalRecordKey]' END + ', ' +
						CASE WHEN HasPursuitID = 1 THEN '[t].[PursuitID]' ELSE 'NULL AS [PursuitID]' END + ', ' +
						CASE WHEN HasPursuitEventID = 1 THEN '[t].[PursuitEventID]' ELSE 'NULL AS [PursuitEventID]' END + ', ' +
						CASE WHEN HasServiceDate = 1 THEN '[t].[ServiceDate]' ELSE 'NULL AS [ServiceDate]' END + ', ' +
						CASE WHEN HasCreatedDate = 1 THEN '[t].[CreatedDate]' ELSE 'NULL AS [CreatedDate]' END + ', ' +
						CASE WHEN HasCreatedUser = 1 THEN '[t].[CreatedUser]' ELSE 'NuLL AS [CreatedUser]' END + ', ' +
						CASE WHEN HasLastChangedDate = 1 THEN '[t].[LastChangedDate]' ELSE 'NULL AS [LastChangedDate]' END + ', ' +
						CASE WHEN HasLastChangedUser = 1 THEN '[t].[LastChangedUser]' ELSE 'NuLL AS [LastChangedUser]' END + ', ' +
						ColumnList + ', ' +
						'CONVERT(xml, ' + ISNULL('''' + ColumnXml + '''', 'NULL') + ') AS ColumnXml, ' +
						'CONVERT(int, ' + CONVERT(nvarchar(max), MeasureComponentID) + ') AS MeasureComponentID ' + 
						'FROM ' + QUOTENAME(TableSchema) + '.' + QUOTENAME(TableName) + ' AS t'
	FROM	#DataEntryTables

	IF OBJECT_ID('dbo.MedicalRecordComposite') IS NOT NULL AND
		EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'VIEW' AND TABLE_NAME = 'MedicalRecordComposite' AND TABLE_SCHEMA = 'dbo')
		DROP VIEW dbo.MedicalRecordComposite;

	SET @SqlCmd = 'CREATE VIEW [dbo].[MedicalRecordComposite] AS ' + @CrLf + @SqlCmd;

	--PRINT @SqlCmd;
	EXEC (@SqlCmd);

	PRINT 'Composite View Refreshed Successfully.'
END;
GO
