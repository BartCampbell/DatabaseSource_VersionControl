SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetRecordCounts] 
(
	@TableName nvarchar(128) = NULL,
	@TableSchema nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cmd nvarchar(max);
	DECLARE @crlf nvarchar(2);
	SET @crlf = CHAR(13) + CHAR(10);
	
	SELECT	@cmd = ISNULL(@cmd + @crlf + ' UNION ' + @crlf, '') + 
			'SELECT ''' + TABLE_SCHEMA + '.' + TABLE_NAME + ''' AS TableName, COUNT(*) AS CountRecords FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + ' WITH(NOLOCK)'
	FROM	INFORMATION_SCHEMA.TABLES
	WHERE	(TABLE_TYPE = 'BASE TABLE') AND
			(@TableName IS NULL OR TABLE_NAME LIKE @TableName) AND
			(@TableSchema IS NULL OR TABLE_SCHEMA LIKE @TableSchema);
	
	SET @cmd = @cmd + ' ORDER BY 1;'
	
	PRINT @cmd;
	EXEC (@cmd);
END

GO
