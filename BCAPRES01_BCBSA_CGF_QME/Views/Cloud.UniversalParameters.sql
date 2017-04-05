SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Cloud].[UniversalParameters] AS
SELECT	CAST('batchid' AS nvarchar(128)) AS FieldName, CAST('@BatchID' AS nvarchar(128)) AS ParamName, CAST('BatchID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType
UNION 
SELECT	CAST('datarunid' AS nvarchar(128)) AS FieldName, CAST('@DataRunID' AS nvarchar(128)) AS ParamName, CAST('DataRunID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType
UNION
SELECT	CAST('datasetid' AS nvarchar(128)) AS FieldName, CAST('@DataSetID' AS nvarchar(128)) AS ParamName, CAST('DataSetID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType
UNION
SELECT	CAST('fileformatid' AS nvarchar(128)) AS FieldName, CAST('@FileFormatID' AS nvarchar(128)) AS ParamName, CAST('FileFormatID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType
UNION
SELECT	CAST('measuresetid' AS nvarchar(128)) AS FieldName, CAST('@MeasureSetID' AS nvarchar(128)) AS ParamName, CAST('MeasureSetID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType
UNION
SELECT	CAST('ownerid' AS nvarchar(128)) AS FieldName, CAST('@OwnerID' AS nvarchar(128)) AS ParamName, CAST('OwnerID' AS nvarchar(128)) AS SourceColumn, CAST('int' AS nvarchar(128)) AS SourceColumnDataType

GO
