SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/20/2011
-- Description:	Updates table index statistics based on the specified criteria.
-- =============================================
CREATE PROCEDURE [dbo].[RefreshStatistics]
(
	@TableName nvarchar(128) = NULL,
	@TableSchema nvarchar(128) = NULL
)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @sql nvarchar(MAX)

	SELECT	@sql = ISNULL(@sql + CHAR(13) + CHAR(10), '') + 'UPDATE STATISTICS ' + QUOTENAME(T.TABLE_SCHEMA) + '.' + QUOTENAME(T.TABLE_NAME) + ';' 
	FROM	INFORMATION_SCHEMA.TABLES AS T
	WHERE	((@TableName IS NULL) OR (T.TABLE_NAME = @TableName)) AND
			((@TableSchema IS NULL) OR (T.TABLE_SCHEMA = @TableSchema)) AND
			(TABLE_TYPE = 'BASE TABLE')
	ORDER BY T.TABLE_SCHEMA, T.TABLE_NAME;

	PRINT 'EXECUTING THE FOLLOWING COMMANDS:';
	PRINT '********************************************************************************************';
	PRINT @sql;    
    PRINT '********************************************************************************************';
    
    EXEC (@sql);
    
    RETURN 0;
END


GO
GRANT VIEW DEFINITION ON  [dbo].[RefreshStatistics] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[RefreshStatistics] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[RefreshStatistics] TO [Processor]
GO
