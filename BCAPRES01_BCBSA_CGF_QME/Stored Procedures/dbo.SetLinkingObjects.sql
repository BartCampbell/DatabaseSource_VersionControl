SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/12/2012
-- Description:	Sets the table object pointers (as views or synonyms) to the specified database's tables, based on the specified schema.
-- =============================================
CREATE PROCEDURE [dbo].[SetLinkingObjects]
(
	@DatabaseName nvarchar(128),
	@NewSchemaName nvarchar(128) = NULL,
	@SchemaName nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AsViews bit;
	SET @AsViews = 1; 

	DECLARE @SourceTables TABLE
	(
		ID int IDENTITY(1, 1) NOT NULL,
		TableName nvarchar(128) NOT NULL,
		TableSchema nvarchar(128) NOT NULL
	);
	
	DECLARE @InitCmd nvarchar(max);
	SET @InitCmd = 'SELECT [TABLE_NAME], [TABLE_SCHEMA] FROM ' + QUOTENAME(@DatabaseName) + '.[INFORMATION_SCHEMA].[TABLES] WHERE [TABLE_SCHEMA] = ''' + @SchemaName + ''';';
	
	INSERT INTO @SourceTables
			(TableName, TableSchema)
	EXEC (@InitCmd);
	
    WITH SourceTableNames AS
    (
		SELECT	CONVERT(bit, 0) AS IsCritical,
				QUOTENAME(ISNULL(@NewSchemaName, TableSchema)) + '.' + TableName AS NewTableName,
				QUOTENAME(TableSchema) + '.' + TableName AS TableName
		FROM	@SourceTables
    )
    SELECT	CASE @AsViews 
				WHEN 1 THEN
					'CREATE VIEW ' + T.NewTableName + ' AS SELECT * FROM ' + QUOTENAME(@DatabaseName) + '.' + T.TableName + ';'
				ELSE
					'CREATE SYNONYM ' + T.NewTableName + ' FOR ' + QUOTENAME(@DatabaseName) + '.' + T.TableName + ';'
				END AS Cmd,
			IDENTITY(int, 1, 1) AS CmdID,
			CASE 
				WHEN OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.NewTableName) IS NOT NULL 
				THEN 
					CASE 
						WHEN OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.NewTableName), 'IsView') = 1 
						THEN 'DROP VIEW ' + T.NewTableName + ';'
						WHEN OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.NewTableName), 'IsExecuted') = 0 AND
								OBJECTPROPERTY(OBJECT_ID(QUOTENAME(DB_NAME()) + '.' + T.NewTableName), 'IsTable') = 0 
						THEN 'DROP SYNONYM ' + T.NewTableName + ';'
						END 
				END AS DropCmd,
			t.IsCritical,
			CASE WHEN OBJECT_ID(QUOTENAME(@DatabaseName) + '.' + T.TableName) IS NOT NULL THEN 1 ELSE 0 END AS IsValidObject,
			t.TableName
	INTO	#Commands
    FROM	SourceTableNames AS t;
    
    DECLARE @Cmd nvarchar(max);
    DECLARE @CmdID int;
    DECLARE @DropCmd nvarchar(max);
    DECLARE @IsCritical bit;
    DECLARE @IsValidObject bit;
    DECLARE @MaxCmdID int;
    DECLARE @TableName nvarchar(260);
        
    SELECT @MaxCmdID = MAX(CmdID) FROM #Commands;
    
    IF @MaxCmdID IS NOT NULL
		WHILE (1 = 1)
			BEGIN;
				SET @CmdID = ISNULL(@CmdID, 0) + 1 
				IF @CmdID > @MaxCmdID
					BREAK;
		    
				SELECT	@Cmd = Cmd, 
						@DropCmd = DropCmd, 
						@IsCritical = IsCritical, 
						@IsValidObject = IsValidObject,
						@TableName = TableName
				FROM	#Commands 
				WHERE	(CmdID = @CmdID);
				
				IF @IsValidObject = 1
					BEGIN;
						IF NULLIF(LTRIM(@DropCmd), '') IS NOT NULL
							EXEC (@DropCmd);
							
						
						EXEC (@Cmd);
					END;
				ELSE IF @IsCritical = 1
					BEGIN
						DECLARE @ErrorMessage varchar(512);
						SET @ErrorMessage = 'Unable to create linking object, because the source object does not exist. Cannot execute: "' + @Cmd + '".';

						RAISERROR(@ErrorMessage, 16, 1);				
					END;
			END;
    
    RETURN 0;
    
END

GO
GRANT EXECUTE ON  [dbo].[SetLinkingObjects] TO [Processor]
GO
