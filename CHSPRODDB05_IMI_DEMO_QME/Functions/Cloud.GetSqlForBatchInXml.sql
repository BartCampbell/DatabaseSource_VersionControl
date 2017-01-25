SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/26/2011
-- Description: Retrieves the SQL command used to extract the specified batch's contents from properly formated XML.
-- =============================================
CREATE FUNCTION [Cloud].[GetSqlForBatchInXml]
(
	@FileFormatID int,
	@IncludeInsert bit,
	@RootNode nvarchar(128)
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Result nvarchar(max);
	
	DECLARE @FileFormatTypeID int;
	SELECT @FileFormatTypeID = FileFormatTypeID FROM Cloud.FileFormatTypes WHERE FileFormatTypeGuid = '11A61BE1-FF41-4CD4-8757-1ED603786C5F';
			
	IF EXISTS(SELECT TOP 1 1 FROM Cloud.FileFormats WHERE FileFormatID = @FileFormatID AND FileFormatTypeID = @FileFormatTypeID)
		BEGIN
			DECLARE @CrLf nvarchar(2);
			DECLARE @Sql nvarchar(max);
			DECLARE @SqlCte nvarchar(max);
			DECLARE @SqlDelete nvarchar(max);
			DECLARE @SqlDeleteIfExists nvarchar(max);
			DECLARE @SqlDropTable nvarchar(max);
			DECLARE @SqlInsert nvarchar(max);
			DECLARE @SqlSelect nvarchar(max);
			DECLARE @SqlSelectInto nvarchar(max);
			DECLARE @Tab nvarchar(1);

			SET @CrLf = CHAR(13) + CHAR(10);
			SET @Tab = CHAR(9);

			WITH ObjectBase AS
			(
				SELECT	NFF.FieldName,
						NFF.FileFieldID,
						NFO.FileObjectID,
						R.DATA_TYPE + 
							COALESCE('(' + CAST(NULLIF(R.CHARACTER_MAXIMUM_LENGTH, -1) AS nvarchar(32)) + ')', 
								'(' + CAST(NULLIF(R.NUMERIC_PRECISION, -1) AS nvarchar(32)) + ', ' + CAST(NULLIF(NULLIF(R.NUMERIC_SCALE, 0), -1) AS nvarchar(32)) + ')',
								CASE WHEN R.CHARACTER_MAXIMUM_LENGTH = -1 AND R.DATA_TYPE IN ('nvarchar','varchar') THEN '(max)' END, 
								'') AS InFunctionDataType,
						NFT.InFunctionName,
						NFT.InFunctionSchema,
						NFO.ObjectName,
						NUP.ParamName,
						ROW_NUMBER() OVER (PARTITION BY NFO.InSourceSchema, NFO.InSourceName ORDER BY ISNULL(NUP.SourceColumn, NFF.SourceColumn)) AS RowID,
						C.COLUMN_NAME AS SourceColumn,
						C.DATA_TYPE + 
							COALESCE('(' + CAST(NULLIF(C.CHARACTER_MAXIMUM_LENGTH, -1) AS nvarchar(32)) + ')', 
								'(' + CAST(NULLIF(C.NUMERIC_PRECISION, -1) AS nvarchar(32)) + ', ' + CAST(NULLIF(NULLIF(C.NUMERIC_SCALE, 0), -1) AS nvarchar(32)) + ')',
								CASE WHEN C.CHARACTER_MAXIMUM_LENGTH = -1 AND C.DATA_TYPE IN ('nvarchar','varchar') THEN '(max)' END, 
								'') AS SourceColumnDataType,
						NFO.InSourceName AS SourceName,
						NFO.InSourceSchema AS SourceSchema,
						'#' + NFO.InSourceSchema + '_' + NFO.InSourceName + '_' + CONVERT(nvarchar(256), RS.RandomGuid) AS TempTableName,
						NFOH.Tier,
						NFOH.XmlPath
				FROM	Cloud.FileObjectHierarchy AS NFOH
						INNER JOIN Cloud.FileObjects AS NFO
								ON NFOH.FileObjectID = NFO.FileObjectID AND
									NFO.FileFormatID = @FileFormatID AND
									NFO.InSourceName IS NOT NULL AND
									NFO.InSourceSchema IS NOT NULL AND
									NFO.IsEnabled = 1
						INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
								ON QUOTENAME(NFO.InSourceName) = QUOTENAME(C.TABLE_NAME) AND
									QUOTENAME(NFO.InSourceSchema) = QUOTENAME(C.TABLE_SCHEMA)
						LEFT OUTER JOIN Cloud.FileFields AS NFF
								ON NFOH.FileObjectID = NFF.FileObjectID AND 
									QUOTENAME(C.COLUMN_NAME) = QUOTENAME(NFF.SourceColumn)
						LEFT OUTER JOIN Cloud.FileTranslators AS NFT
								ON NFF.FileTranslatorID = NFT.FileTranslatorID
						LEFT OUTER JOIN Cloud.UniversalParameters AS NUP
								ON C.COLUMN_NAME = NUP.SourceColumn AND
									C.DATA_TYPE = NUP.SourceColumnDataType 
						LEFT OUTER JOIN INFORMATION_SCHEMA.ROUTINES AS R
								ON QUOTENAME(NFT.OutFunctionName) = QUOTENAME(R.ROUTINE_NAME) AND
									QUOTENAME(NFT.OutFunctionSchema) = QUOTENAME(R.ROUTINE_SCHEMA) AND
									R.ROUTINE_TYPE = 'FUNCTION'
						CROSS APPLY (SELECT TOP 1 * FROM Random.Seed) AS RS
				WHERE	(
							(NFF.IsShown = 1) OR
							(NUP.ParamName IS NOT NULL)
						) 
						
			),
			ObjectLastRow AS
			(
				SELECT	FileObjectID,
						CONVERT(bit, MAX(CASE WHEN SourceColumnDataType = 'xml' OR InFunctionDataType = 'xml' THEN 1 ELSE 0 END)) AS HasXmlDataType,
						ObjectName,
						MAX(RowID) AS RowID,
						SourceName,
						SourceSchema
				FROM	ObjectBase 	
				GROUP BY FileObjectID,
						ObjectName,
						SourceName,
						SourceSchema
			)
			SELECT	@SqlCte = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlCte, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'WITH XmlSource AS ' + @CrLf +
								'(' + @CrLf +
								'	SELECT	@xml AS data' + @CrLf +
								')' 
								ELSE ''
								END,
					@SqlDelete = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlDelete, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'DELETE FROM ' + QUOTENAME(OB.SourceSchema) + '.' + QUOTENAME(OB.SourceName) + ' WITH(ROWLOCK) WHERE ((1 = 1)'
								ELSE ''
								END + 
							CASE 
								WHEN OB.ParamName IS NOT NULL AND OB.SourceColumn IS NOT NULL THEN ' AND (' + QUOTENAME(OB.SourceColumn) + ' = ' + OB.ParamName + ')'
								ELSE ''
								END + 
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN ')'
								ELSE '' 
								END,
					@SqlDropTable = CASE WHEN OB.RowID = OLR.RowID THEN 'DROP TABLE ' + QUOTENAME(OB.TempTableName) ELSE '' END,
					@SqlDeleteIfExists = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlDeleteIfExists, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'IF EXISTS(SELECT TOP 1 1 FROM ' + QUOTENAME(OB.SourceSchema) + '.' + QUOTENAME(OB.SourceName) + ' WITH(NOLOCK) WHERE ((1 = 1)'
								ELSE ''
								END + 
							CASE 
								WHEN OB.ParamName IS NOT NULL AND OB.SourceColumn IS NOT NULL THEN ' AND (' + QUOTENAME(OB.SourceColumn) + ' = ' + OB.ParamName + ')'
								ELSE ''
								END + 
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN '))'
								ELSE '' 
								END,
					@SqlInsert = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlInsert, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'INSERT INTO	' + QUOTENAME(OB.SourceSchema) + '.' + QUOTENAME(OB.SourceName) + @CrLF +
									'		(' + @CrLf
								ELSE ', ' + @CrLf 
								END + 
							REPLICATE(@Tab, 3) + QUOTENAME(OB.SourceColumn) + 
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN @CrLF + REPLICATE(@Tab, 2) + ')'
								ELSE '' 
								END,
					@SqlSelect = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlSelect, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'SELECT ' 
								ELSE ', ' 
								END + 
							@CrLf + REPLICATE(@Tab, 2) + QUOTENAME(OB.SourceColumn) +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN @CrLf + 'FROM	' + QUOTENAME(OB.TempTableName) +
									@CrLf + 'ORDER BY ' + QUOTENAME(OB.TempTableName + '_RowID')
								ELSE '' 
								END,
					@SqlSelectInto = CASE WHEN OB.RowID > 1 THEN ISNULL(@SqlSelectInto, '') ELSE '' END + 
							CASE 
								WHEN OB.RowID = 1 
								THEN 'SELECT ' + CASE WHEN OLR.HasXmlDataType = 0 THEN 'DISTINCT ' ELSE '' END
								ELSE ', ' 
								END + 
							@CrLf + REPLICATE(@Tab, 2) + 
								ISNULL(OB.ParamName, 
									ISNULL(QUOTENAME(OB.InFunctionSchema) + '.' + QUOTENAME(OB.InFunctionName) + '(', '') + 
										CASE WHEN OB.SourceColumnDataType = 'xml' 
											 THEN QUOTENAME(OB.ObjectName + '_i') + '.query(''./' + OB.FieldName + '[1]/*'')'
											 ELSE QUOTENAME(OB.ObjectName + '_i') + '.value(''@' + OB.FieldName + ''', ''' + ISNULL(OB.InFunctionDataType, OB.SourceColumnDataType) + ''')'  
											 END +
										CASE WHEN OB.InFunctionSchema IS NOT NULL AND OB.InFunctionName IS NOT NULL THEN ')' ELSE '' END) +
								' AS ' + QUOTENAME(OB.SourceColumn) +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN ', ' + @CrLf + REPLICATE(@Tab, 2) + 'IDENTITY(bigint, 1, 1) AS ' + QUOTENAME(OB.TempTableName + '_RowID') + @CrLf + 
									'INTO	' + QUOTENAME(OB.TempTableName) + @CrLf + 
									'FROM	[XmlSource] AS ' + QUOTENAME(OB.ObjectName) + @CrLf +
									'		CROSS APPLY ' + QUOTENAME(OB.ObjectName) + '.[data].nodes(''/' + @RootNode + OB.XmlPath + ''') AS ' + 
									QUOTENAME(OB.ObjectName + '_t') + '(' + QUOTENAME(OB.ObjectName + '_i') + ')'
								ELSE '' 
								END,
					@Sql = ISNULL(@Sql, '') +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN '/*** SQL Statement for "' + UPPER(OB.ObjectName) + '" ' + REPLICATE('*', 48 - LEN(LEFT(OB.ObjectName, 48))) + '*/' + @CrLf + 
									CASE WHEN @IncludeInsert = 1 THEN @SqlDeleteIfExists + @CrLf + @SqlDelete + ';' + REPLICATE(@CrLf, 2) ELSE '' END + 
									@SqlCte + @CrLf +
									@SqlSelectInto + ';' + @CrLf +
									CASE WHEN @IncludeInsert = 1 THEN @CrLf + @SqlInsert ELSE '' END + @CrLf + 
									@SqlSelect + ';' + 
									REPLICATE(@CrLf, 2) +
									@SqlDropTable + ';' + 
									REPLICATE(@CrLf, 3)
								ELSE '' 
								END
			FROM	ObjectBase AS OB
					INNER JOIN ObjectLastRow AS OLR
							ON OB.FileObjectID = OLR.FileObjectID AND
								OB.ObjectName = OLR.ObjectName AND
								OB.SourceName = OLR.SourceName AND
								OB.SourceSchema = OLR.SourceSchema
			ORDER BY OB.SourceSchema, OB.SourceName, OB.RowID;

			
			SET @Result = @Sql;
		END
			
	RETURN @Result;
END


GO
GRANT EXECUTE ON  [Cloud].[GetSqlForBatchInXml] TO [Processor]
GO
