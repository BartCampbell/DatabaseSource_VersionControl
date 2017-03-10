SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/6/2012
-- Description:	Updates the activity data of the specified engine.
-- =============================================
CREATE PROCEDURE [Cloud].[UpdateEngineActivity]
(
	@EngineGuid uniqueidentifier = NULL OUTPUT,
	@EngineID int = NULL OUTPUT,
	@EngineTypeGuid uniqueidentifier = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		IF @EngineGuid IS NULL AND @EngineID IS NOT NULL
			SELECT @EngineGuid = EngineGuid FROM Cloud.Engines WITH(NOLOCK) WHERE (EngineID = @EngineID);
		
		UPDATE	CE
		SET		CountActivity = ISNULL(CE.CountActivity, 0) + 1,
				LastActivityDate = GETDATE()
		FROM	Cloud.Engines AS CE
		WHERE	(EngineGuid = @EngineGuid) AND 
				(IsExpired = 0);
		
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
		DECLARE @ErrType char(1);
		
		DECLARE @ErrResult int;
		
		SELECT	@ErrApp = DB_NAME(),
				@ErrLine = ERROR_LINE(),
				@ErrMessage = ERROR_MESSAGE(),
				@ErrNumber = ERROR_NUMBER(),
				@ErrSeverity = ERROR_SEVERITY(),
				@ErrSource = ERROR_PROCEDURE(),
				@ErrState = ERROR_STATE();
				
		--If a deadlock occurs in this procedure, no harm is done.  Log error but do not raise/throw it again.
		IF @ErrNumber = 1205
			SET @ErrType = 'I';
		ELSE
			SET @ErrType = 'Q';
		
		EXEC @ErrResult = [Log].RecordError	@Application = @ErrApp,
											@LineNumber = @ErrLine,
											@Message = @ErrMessage,
											@EngineGuid = @EngineGuid,
											@ErrorNumber = @ErrNumber,
											@ErrorType = @ErrType,
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
GRANT EXECUTE ON  [Cloud].[UpdateEngineActivity] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[UpdateEngineActivity] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[UpdateEngineActivity] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[UpdateEngineActivity] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[UpdateEngineActivity] TO [Submitter]
GO
