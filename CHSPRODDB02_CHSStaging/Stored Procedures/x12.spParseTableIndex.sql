SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****************************************************************************************************************************************************
Description:	Index all 837 Parse Tables
Use:

EXEC x12.spParseTableIndex
	@Action = 'CREATE' -- CREATE / DROP / REBUILD
	,@DB = 'StFran_RDSM'
	,@Schema = 'Epic'
	,@Mod = NULL -- NULL for actual table, send mod such as 'z' to alter copies with same prefix. E.g. X12TR vs zX12TR
	,@Debug = 1 -- 0 to EXEC, 1 to PRINT only

SELECT * FROM CHSStaging.x12.RefParseTableList

Change Log:
-----------------------------------------------------------------------------------------------------------------------------------------------------
2016-08-15	Michael Vlk			- Create
****************************************************************************************************************************************************/
CREATE PROCEDURE [x12].[spParseTableIndex] (
	@Action VARCHAR(10) -- CREATE / DROP / REBUILD
	,@DB VARCHAR(100)
	,@Schema VARCHAR(25) 
	,@Mod VARCHAR(10) = NULL
	,@Debug INT = 0
	)

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@SQLString NVARCHAR(MAX)
		,@TableName VARCHAR(50) --= 'zX12TR'
		,@TablePrefix VARCHAR(50) --= 'TR'
		,@ListID INT
	
	
	SELECT @ListID = MIN(ListID) FROM CHSStaging.x12.RefParseTableList

	WHILE @ListID IS NOT NULL
	BEGIN
		SELECT @TableName = TableName, @TablePrefix = TablePrefix FROM CHSStaging.x12.RefParseTableList WHERE ListID = @ListID

		IF @Action = 'DROP'
			SET @SQLString = '
				--DROP INDEX pk_' + @TableName + ' ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_RowIDParent ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_CentauriClientID ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_TransactionImplementationConventionReference ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_TransactionControlNumber ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
				DROP INDEX idx_' + @TableName + '_LoopID ON ' + @DB + '.' + @Schema + '.' + @TableName + ';
			';
		IF @Action = 'CREATE'
			SET @SQLString = '
				--CREATE CLUSTERED INDEX pk_' + @TableName + ' ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_FileLogID ,' + @TablePrefix + '_RowID);
				CREATE INDEX idx_' + @TableName + '_RowIDParent ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_RowIDParent);
				CREATE INDEX idx_' + @TableName + '_CentauriClientID ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_CentauriClientID);
				CREATE INDEX idx_' + @TableName + '_TransactionImplementationConventionReference ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_TransactionImplementationConventionReference);
				CREATE INDEX idx_' + @TableName + '_TransactionControlNumber ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_TransactionControlNumber);
				CREATE INDEX idx_' + @TableName + '_LoopID ON ' + @DB + '.' + @Schema + '.' + @TableName + ' (' + @TablePrefix + '_LoopID);
			';
		IF @Action = 'REBUILD'
			SET @SQLString = '
				ALTER INDEX ALL ON x12.' + @TableName + ' REBUILD;'

		IF @Debug >= 1 PRINT @SQLString;

		IF @Debug = 0 EXECUTE sp_executesql @SQLString;

		SELECT @ListID = MIN(ListID) FROM CHSStaging.x12.RefParseTableList WHERE ListID > @ListID
	END -- WHILE

END -- Procedure




GO
