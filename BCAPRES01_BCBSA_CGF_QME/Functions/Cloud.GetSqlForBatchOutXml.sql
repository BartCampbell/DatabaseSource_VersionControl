SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/17/2011
-- Description: Retrieves the SQL command used to retrieve the specified batch's XML contents.
-- =============================================
CREATE FUNCTION [Cloud].[GetSqlForBatchOutXml]
(
	@FileFormatID int,
	@ParentID int = NULL,
	@Tier int = 1
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
			DECLARE @Tab nvarchar(1);
			
			SET @CrLf = CHAR(13) + CHAR(10);
			SET @Tab = CHAR(9);
		
			-----------------------------------------------------
			DECLARE @CrLf1 nvarchar(64);
			DECLARE @CrLf2 nvarchar(64);
			SET @CrLf1 = @CrLf + REPLICATE(@Tab, @Tier - 1);
			SET @CrLf2 = @CrLf + REPLICATE(@Tab, @Tier * 2);
			-----------------------------------------------------
		
			WITH ObjectBase AS
			(
				SELECT	NFF.FieldName,
						NFF.FileFieldID,
						NFO.FileObjectID,
						NFO.MaxRecords,
						NFO.ObjectName,
						NFT.OutFunctionName,
						NFT.OutFunctionSchema,
						ROW_NUMBER() OVER (PARTITION BY NFO.ObjectName ORDER BY NFF.FieldName) AS RowID,
						NFF.SourceColumn,
						NFO.OutSourceName AS SourceName,
						NFO.OutSourceSchema AS SourceSchema
				FROM	Cloud.FileObjectHierarchy AS NFOH WITH(NOLOCK)
						INNER JOIN Cloud.FileObjects AS NFO
								ON NFOH.FileObjectID = NFO.FileObjectID AND
									NFO.FileFormatID = @FileFormatID AND
									NFO.IsEnabled = 1
						INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
								ON NFO.OutSourceName = C.TABLE_NAME AND
									NFO.OutSourceSchema = C.TABLE_SCHEMA
						INNER JOIN Cloud.FileFields AS NFF WITH(NOLOCK)
								ON NFOH.FileObjectID = NFF.FileObjectID AND
									C.COLUMN_NAME = NFF.SourceColumn AND
									NFF.IsShown = 1	
						LEFT OUTER JOIN Cloud.FileTranslators AS NFT WITH(NOLOCK)
								ON NFF.FileTranslatorID = NFT.FileTranslatorID
				WHERE	(NFO.OutSourceName IS NOT NULL) AND
						(NFO.OutSourceSchema IS NOT NULL) AND
						((NFOH.ParentID = @ParentID) OR ((NFOH.ParentID IS NULL) AND (@ParentID IS NULL))) AND
						(NFOH.Tier = @Tier)
			),
			ObjectLastRow AS
			(
				SELECT	FileObjectID,
						ObjectName,
						MAX(RowID) AS RowID,
						SourceName,
						SourceSchema
				FROM	ObjectBase 	
				GROUP BY FileObjectID,
						ObjectName,
						SourceName,
						SourceSchema
			),
			ObjectHasDSMemberID AS
			(
				SELECT DISTINCT
						FileObjectID
				FROM	ObjectBase 
				WHERE	(SourceColumn IN ('DSMemberID', '[DSMemberID]', '"DSMemberID"')) AND
						(@Tier = 1)
			),
			ObjectHasDSProviderID AS
			(
				SELECT DISTINCT
						FileObjectID
				FROM	ObjectBase 
				WHERE	(SourceColumn IN ('DSProviderID', '[DSProviderID]', '"DSProviderID"')) AND
						(@Tier = 1)
			),
			ParamWhereBase AS
			(
				SELECT	NFO.FileObjectID,
						NFO.ObjectName,
						NFO.OutSourceName AS SourceName,
						NFO.OutSourceSchema AS SourceSchema,
						QUOTENAME(NFO.ObjectName) + '.' + QUOTENAME(NUP.SourceColumn) + ' = ' + NUP.ParamName AS WhereLine
				FROM	Cloud.FileObjectHierarchy AS NFOH
						INNER JOIN Cloud.FileObjects AS NFO
								ON NFOH.FileObjectID = NFO.FileObjectID AND
									NFO.FileFormatID = @FileFormatID
						INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
								ON NFO.OutSourceName = C.TABLE_NAME AND
									NFO.OutSourceSchema = C.TABLE_SCHEMA
						INNER JOIN Cloud.UniversalParameters AS NUP
								ON C.COLUMN_NAME = NUP.SourceColumn AND
									C.DATA_TYPE = NUP.SourceColumnDataType
				WHERE	((NFOH.ParentID = @ParentID) OR ((NFOH.ParentID IS NULL) AND (@ParentID IS NULL))) AND
						(NFOH.Tier = @Tier)	
			),
			WhereBase AS
			(
				SELECT	NFO.FileObjectID,
						NFO.ObjectName,
						NFO.OutSourceName AS SourceName,
						NFO.OutSourceSchema AS SourceSchema,
						QUOTENAME(NFO.ObjectName) + '.' + QUOTENAME(NFF.SourceColumn) + ' = ' + 
						QUOTENAME(NFOP.ObjectName) + '.' + QUOTENAME(NFFP.SourceColumn) AS WhereLine
				FROM	Cloud.FileObjectHierarchy AS NFOH
						INNER JOIN Cloud.FileObjects AS NFO
								ON NFOH.FileObjectID = NFO.FileObjectID AND
									NFO.FileFormatID = @FileFormatID
						INNER JOIN INFORMATION_SCHEMA.COLUMNS AS C
								ON NFO.OutSourceName = C.TABLE_NAME AND
									NFO.OutSourceSchema = C.TABLE_SCHEMA
						INNER JOIN Cloud.FileFields AS NFF
								ON NFOH.FileObjectID = NFF.FileObjectID AND
									C.COLUMN_NAME = NFF.SourceColumn
						INNER JOIN Cloud.FileRelationships AS NFR
								ON NFF.FileFieldID = NFR.ChildFieldID 
						INNER JOIN Cloud.FileFields AS NFFP
								ON NFR.ParentFieldID = NFFP.FileFieldID
						INNER JOIN Cloud.FileObjects AS NFOP
								ON NFOH.ParentID = NFOP.FileObjectID AND
									NFOP.FileFormatID = @FileFormatID
				WHERE	((NFOH.ParentID = @ParentID) OR ((NFOH.ParentID IS NULL) AND (@ParentID IS NULL))) AND
						(NFOH.Tier = @Tier)	
			)
			SELECT	@Sql = ISNULL(@Sql, '') + 
							CASE WHEN @Sql IS NOT NULL AND OB.RowID = 1 
								THEN ', ' + @CrLf1
								ELSE ''
								END +
							CASE 
								WHEN OB.RowID = 1 
								THEN '(SELECT ' + ISNULL('TOP ' + CAST(OB.MaxRecords AS nvarchar(max)), '') + @Tab 
								ELSE ', ' 
								END + 
							ISNULL(QUOTENAME(OB.OutFunctionSchema) + '.' + QUOTENAME(OB.OutFunctionName) + '(', '') +
								 QUOTENAME(OB.ObjectName) + '.' + QUOTENAME(OB.SourceColumn) +
								 CASE WHEN OB.OutFunctionSchema IS NOT NULL AND OB.OutFunctionName IS NOT NULL THEN ')' ELSE '' END +
								 ' AS ' + QUOTENAME(OB.FieldName) +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN ISNULL(', ' + @CrLf2 + Cloud.GetSqlForBatchOutXml(@FileFormatID, OB.FileObjectID, @Tier + 1) + @CrLf2, '')
								ELSE '' 
								END +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN ' ' + @CrLf2 + 'FROM	' + QUOTENAME(OB.SourceSchema) + '.' + QUOTENAME(OB.SourceName) + ' AS ' + QUOTENAME(OB.ObjectName) + ' WITH(NOLOCK) ' + @CrLf2 +
									'WHERE	(1 = 1) ' + 
									ISNULL(@CrLf2 + REPLICATE(@Tab, 2) + CAST((SELECT 'AND (' + t.WhereLine + ')' AS [data()] FROM ParamWhereBase AS t WHERE t.FileObjectID = OB.FileObjectID FOR XML PATH('')) AS nvarchar(max)), '') +
									ISNULL(@CrLf2 + REPLICATE(@Tab, 2) + CAST((SELECT 'AND (' + t.WhereLine + ')' AS [data()] FROM WhereBase AS t WHERE t.FileObjectID = OB.FileObjectID FOR XML PATH('')) AS nvarchar(max)), '') +
									CASE 
										WHEN OM.FileObjectID IS NOT NULL	
										THEN @CrLf2 + REPLICATE(@Tab, 2) + 'AND (' + QUOTENAME(OB.ObjectName) + '.[DSMemberID] IN (SELECT [tM].[DSMemberID] FROM [Cloud].[BatchMembers] AS [tM] WITH(NOLOCK) WHERE ([tM].[BatchID] = @BatchID)))'
										ELSE ''
										END +
									CASE 
										WHEN OP.FileObjectID IS NOT NULL	
										THEN @CrLf2 + REPLICATE(@Tab, 2) + 'AND (' + QUOTENAME(OB.ObjectName) + '.[DSProviderID] IN (SELECT [tP].[DSProviderID] FROM [Cloud].[BatchProviders] AS [tP] WITH(NOLOCK) WHERE ([tP].[BatchID] = @BatchID)))'
										ELSE ''
										END 
								ELSE '' 
								END +
							CASE 
								WHEN OB.RowID = OLR.RowID 
								THEN ' ' + @CrLf2 + 'FOR XML AUTO, TYPE)' + @CrLf1
								ELSE ''
								END
			FROM	ObjectBase AS OB
					INNER JOIN ObjectLastRow AS OLR
							ON OB.FileObjectID = OLR.FileObjectID AND
								OB.ObjectName = OLR.ObjectName AND
								OB.SourceName = OLR.SourceName AND
								OB.SourceSchema = OLR.SourceSchema
					LEFT OUTER JOIN ObjectHasDSMemberID AS OM
							ON OB.FileObjectID = OM.FileObjectID
					LEFT OUTER JOIN ObjectHasDSProviderID AS OP
							ON OB.FileObjectID = OP.FileObjectID
			ORDER BY OB.ObjectName, OB.RowID
			
			SET @Result = @Sql;
		END
			
	RETURN @Result;
END

GO
GRANT EXECUTE ON  [Cloud].[GetSqlForBatchOutXml] TO [Processor]
GO
