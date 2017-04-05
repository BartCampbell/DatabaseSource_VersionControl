SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/6/2012
-- Description:	Changes the recovery settings of the current database.
-- =============================================
CREATE PROCEDURE [dbo].[SetDbRecoveryOption]
(
	@DatabaseName nvarchar(128) = NULL,
	@RecoveryModel nvarchar(16) = NULL
)
AS
BEGIN	
	SET NOCOUNT ON;

	IF @DatabaseName IS NULL
		SET @DatabaseName = db_name();

	IF db_id(@DatabaseName) IS NOT NULL 
		BEGIN;
			DECLARE @InitialValue nvarchar(16);
			SELECT @InitialValue = CONVERT(nvarchar(16), DATABASEPROPERTYEX(@DatabaseName, 'RECOVERY'));

			IF @RecoveryModel IS NOT NULL AND @RecoveryModel = @InitialValue 
				PRINT 'Database recovery model for ' + QUOTENAME(@DatabaseName) + ' is already set to ''' + UPPER(@InitialValue) + '''.';
				
			ELSE IF @RecoveryModel IS NOT NULL AND @RecoveryModel IN ('SIMPLE','FULL','BULK_LOGGED') AND @RecoveryModel <> @InitialValue
				BEGIN;
				
					DECLARE @cmd nvarchar(max);
					SET @cmd = 'ALTER DATABASE ' + QUOTENAME(@DatabaseName) + ' SET RECOVERY ' + UPPER(@RecoveryModel) + ';';
					
					PRINT 'EXECUTING: ' + @cmd;
					EXEC (@cmd);
				
					DECLARE @FinalValue nvarchar(16);
					SELECT @FinalValue = CONVERT(nvarchar(16), DATABASEPROPERTYEX(@DatabaseName, 'RECOVERY'));
					
					PRINT 'Database recovery model changed from ''' + UPPER(@InitialValue) + ''' to ''' + UPPER(@FinalValue) + ''' for ' + QUOTENAME(@DatabaseName) + ' successfully.';
					
					RETURN 0;
				END
			ELSE 
				PRINT 'The specified recovery model is invalid. (''SIMPLE'', ''FULL'' or ''BULK_LOGGED'')';
		END;
	ELSE
		PRINT 'The specified database is invalid.';
	
	RETURN 1;
END
GO
GRANT EXECUTE ON  [dbo].[SetDbRecoveryOption] TO [Processor]
GO
