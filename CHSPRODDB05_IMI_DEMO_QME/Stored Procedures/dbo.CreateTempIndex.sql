SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/10/2012
-- Description:	Creates a temporary non-clustered index on the specified table, returning the unique identifier for the index.
-- =============================================
CREATE PROCEDURE [dbo].[CreateTempIndex]
(
	@IndexColumns nvarchar(max),
	@IndexFilter nvarchar(max),
	@IndexIdentifier uniqueidentifier = NULL OUTPUT,
	@TableName nvarchar(128),
	@TableSchema nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SET @IndexIdentifier = NEWID();
	
	DECLARE @IndexName nvarchar(128);
	SET @IndexName = QUOTENAME('IX_' + REPLACE(@TableName, ' ', '_') + '_' + REPLACE(CONVERT(nvarchar(64), @IndexIdentifier), '-', ''));
	
	IF @IndexColumns IS NOT NULL AND 
		LEN(@IndexColumns) > 1 AND
		@IndexFilter IS NOT NULL AND 
		LEN(@IndexFilter) > 3 AND
		@TableName IS NOT NULL AND 
		@TableSchema IS NOT NULL AND
		(OBJECT_ID(QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName)) IS NOT NULL) AND
		(EXISTS (
					SELECT TOP 1 
							1 
					FROM	INFORMATION_SCHEMA.TABLES 
					WHERE	(TABLE_NAME = @TableName) AND 
							(TABLE_SCHEMA = @TableSchema) AND
							(TABLE_TYPE = 'BASE TABLE')
				))
		BEGIN;
			BEGIN TRY;				
				DECLARE @Cmd nvarchar(max);
				SET @Cmd = 'CREATE NONCLUSTERED INDEX ' + @IndexName + ' ' +
							'ON ' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) + ' (' + @IndexColumns + ') ' + 
							'WHERE (' + @IndexFilter + ') WITH ( ONLINE = ON );'
					
				PRINT @Cmd;
				EXEC (@Cmd);
				
				RETURN 0;
			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessage nvarchar(max);
				DECLARE @Severity int;
				DECLARE @State int;
				
				SET @ErrorMessage = ERROR_MESSAGE();
				SET @Severity = ERROR_SEVERITY();
				SET @State = ERROR_STATE();
		
				SET @IndexIdentifier = NULL;
				RAISERROR(@ErrorMessage, @Severity, @State);
				
				RETURN 1;
			END CATCH;
		END;
	ELSE
		BEGIN;		
			SET @IndexIdentifier = NULL;
			
			RAISERROR('There are one or more invalid parameter values.', 16, 1);
			
			RETURN 1;
		END;
END
GO
GRANT EXECUTE ON  [dbo].[CreateTempIndex] TO [Processor]
GO
