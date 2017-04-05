SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/12/2013
-- Description:	Grants access to the Processor group on all executables.
-- =============================================
CREATE PROCEDURE [Cloud].[AssignProcessorPermissions]
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;

		EXEC sys.sp_addrolemember @rolename = 'db_datareader', @membername = 'Processor';
		EXEC sys.sp_addrolemember @rolename = 'db_datawriter', @membername = 'Processor';
	
		IF OBJECT_ID('tempdb..#SqlCmds') IS NOT NULL
			DROP TABLE #SqlCmds;
			
		DECLARE @SqlCmd nvarchar(max);
		CREATE TABLE #SqlCmds
		(
			ID int IDENTITY(1, 1) NOT NULL,
			SqlCmd nvarchar(max) NOT NULL
		);

		INSERT INTO #SqlCmds
				(SqlCmd)
		SELECT DISTINCT
				'GRANT EXECUTE ON ' + QUOTENAME(ROUTINE_SCHEMA) + '.' + QUOTENAME(ROUTINE_NAME) + ' TO [Processor];' AS Cmd 
		FROM	INFORMATION_SCHEMA.ROUTINES
		WHERE	ROUTINE_SCHEMA NOT IN ('sys') AND
				((DATA_TYPE IS NULL) OR (DATA_TYPE <> 'TABLE'))
		ORDER BY Cmd;

		DECLARE @ID int, @MaxID int, @MinID int;
		SELECT @ID = MIN(ID), @MaxID = MAX(ID), @MinID = MIN(ID) FROM #SqlCmds;

		WHILE (@ID BETWEEN @MinID AND @MaxID)
			BEGIN;
				SELECT @SqlCmd = SqlCmd FROM #SqlCmds WHERE (ID = @ID);
				
				PRINT @SqlCmd;
				EXEC (@SqlCmd);
			
				SET @ID = @ID + 1;
			END;

		
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(max);
		DECLARE @ErrNumber int;
		DECLARE @ErrSeverity int;
		DECLARE @ErrSource nvarchar(512);
		DECLARE @ErrState int;
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@ErrorNumber = @ErrNumber,
											@ErrorType = 'Q',
											@ErrLogID = @ErrLogID OUTPUT,
											@PerformRollback = 1,
											@Severity = @ErrSeverity,
											@Source = @ErrSource,
											@State = @ErrState;
		
		IF @ErrResult <> 0
			BEGIN
				PRINT '*** Error Log Failure:  Unable to record the specified entry. ***'
				SET @ErrNumber = @ErrLine * -1;
			END
			
		RETURN @ErrNumber;
	END CATCH;
END




GO
GRANT EXECUTE ON  [Cloud].[AssignProcessorPermissions] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[AssignProcessorPermissions] TO [Submitter]
GO
