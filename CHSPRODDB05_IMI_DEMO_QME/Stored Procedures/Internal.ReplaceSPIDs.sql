SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/21/2014
-- Description:	Replaces the SPID values in all internal tables with the specified SPID value.
-- =============================================
CREATE PROCEDURE [Internal].[ReplaceSPIDs]
(
	@SPID int = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

    IF @SPID IS NULL
		SET @SPID = @@SPID;
		
	
	SELECT DISTINCT
			'IF (SELECT COUNT(DISTINCT [SPID]) FROM ' + QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME) + ') <= 1' + CHAR(13) + CHAR(10) +
			'UPDATE ' + QUOTENAME(C.TABLE_SCHEMA) + '.' + QUOTENAME(C.TABLE_NAME) + ' SET [SPID] = ' + CONVERT(nvarchar(max), @SPID) + ' WHERE ([SPID] <> ' + CONVERT(nvarchar(max), @SPID) + ');' AS Cmd,
			IDENTITY(smallint, 1, 1) AS ID,  
			C.TABLE_NAME AS TableName,
			C.TABLE_SCHEMA AS TableSchema  
	INTO	#InternalTables
	FROM	INFORMATION_SCHEMA.COLUMNS AS C
			INNER JOIN INFORMATION_SCHEMA.TABLES AS T
					ON C.TABLE_CATALOG = T.TABLE_CATALOG AND
						C.TABLE_NAME = T.TABLE_NAME AND
						C.TABLE_SCHEMA = T.TABLE_SCHEMA AND
						T.TABLE_TYPE = 'BASE TABLE'                  
	WHERE	C.COLUMN_NAME = 'SPID' AND
			C.TABLE_SCHEMA = 'INTERNAL';
	 
	DECLARE @ID smallint;
	DECLARE @MaxID smallint;
	DECLARE @MinID smallint;

	SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #InternalTables;

	DECLARE @Cmd nvarchar(max);
	DECLARE @CountRecords bigint;
	DECLARE @TableName nvarchar(261);

	WHILE @ID BETWEEN @MinID AND @MaxID
		BEGIN;
			SELECT @Cmd = Cmd, @TableName = QUOTENAME(TableSchema) + '.' + QUOTENAME(TableName) FROM #InternalTables WHERE ID = @ID;

			IF @Cmd IS NOT NULL
				BEGIN;
					PRINT 'UPDATING ' + @TableName + '...';
					PRINT @Cmd;
					EXEC (@Cmd);

					SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;

					PRINT '';
					PRINT '';
				END;         

			SET @ID = @ID + 1;
		END;

		IF @CountRecords IS NOT NULL AND @CountRecords > 0
			BEGIN;
				EXEC dbo.RebuildIndexes		@TableSchema = N'Internal';
				EXEC dbo.RefreshStatistics	@TableSchema = N'Internal';
			END;

END

GO
GRANT VIEW DEFINITION ON  [Internal].[ReplaceSPIDs] TO [db_executer]
GO
GRANT EXECUTE ON  [Internal].[ReplaceSPIDs] TO [db_executer]
GO
GRANT EXECUTE ON  [Internal].[ReplaceSPIDs] TO [Processor]
GO
