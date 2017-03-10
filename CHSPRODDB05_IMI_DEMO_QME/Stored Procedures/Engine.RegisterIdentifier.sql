SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/6/2012
-- Description:	Sets the identifier for the current instance of the engine.
-- =============================================
CREATE PROCEDURE [Engine].[RegisterIdentifier]
(
	@EngineGuid uniqueidentifier,
	@EngineTypeGuid uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		IF @EngineGuid IS NULL AND @EngineGuid <> CONVERT(uniqueidentifier, CONVERT(binary(1), 0))
			RAISERROR('The specified identifier is invalid.', 16, 1);
		
		DECLARE @EngineTypeID int;
		SELECT @EngineTypeID = EngineTypeID FROM Engine.[Types] WHERE EngineTypeGuid = @EngineTypeGuid;
		
		IF @EngineTypeID IS NULL
			RAISERROR('The specified engine type is invalid.', 16, 1);
		
		UPDATE	Engine.Settings
		SET		EngineGuid = @EngineGuid,
				EngineTypeID = @EngineTypeID 
		WHERE	EngineID = 1;
								
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
											@PerformRollback = 0,
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
GRANT VIEW DEFINITION ON  [Engine].[RegisterIdentifier] TO [db_executer]
GO
GRANT EXECUTE ON  [Engine].[RegisterIdentifier] TO [db_executer]
GO
GRANT EXECUTE ON  [Engine].[RegisterIdentifier] TO [Processor]
GO
GRANT EXECUTE ON  [Engine].[RegisterIdentifier] TO [Submitter]
GO
