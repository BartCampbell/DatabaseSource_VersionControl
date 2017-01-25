SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/10/2012
-- Description:	Drops a temporary non-clustered index on the specified table, based on the unique identifier for the index.
-- =============================================
CREATE PROCEDURE [dbo].[DropTempIndex]
(
	@IndexIdentifier uniqueidentifier,
	@TableName nvarchar(128),
	@TableSchema nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @IndexName nvarchar(128);
	SET @IndexName = QUOTENAME('IX_' + REPLACE(@TableName, ' ', '_') + '_' + REPLACE(CONVERT(nvarchar(64), @IndexIdentifier), '-', ''));
	
	IF @TableName IS NOT NULL AND 
		@TableSchema IS NOT NULL AND
		(OBJECT_ID(QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName)) IS NOT NULL) --AND
		--(INDEXPROPERTY(OBJECT_ID(QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName)), @IndexName, 'IndexID') IS NOT NULL) 
		BEGIN;
			BEGIN TRY;
				DECLARE @Cmd nvarchar(max);
				SET @Cmd = 'DROP INDEX ' + @IndexName + ' ON ' + QUOTENAME(@TableSchema) + '.' + QUOTENAME(@TableName) + ' WITH ( ONLINE = OFF );'
					
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
		
				RAISERROR(@ErrorMessage, @Severity, @State);
				
				RETURN 1;
			END CATCH;
		END;
	ELSE
		BEGIN;		
			RAISERROR('There are one or more invalid parameter values.', 16, 1);
			
			RETURN 1;
		END;
END
GO
GRANT EXECUTE ON  [dbo].[DropTempIndex] TO [Processor]
GO
