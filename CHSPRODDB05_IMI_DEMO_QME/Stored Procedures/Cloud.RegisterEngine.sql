SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/4/2012
-- Description:	Registers the engine with the cloud-based controller and/or updates the activity data.
-- =============================================
CREATE PROCEDURE [Cloud].[RegisterEngine]
(
	@EngineGuid uniqueidentifier OUTPUT,
	@EngineID int = NULL OUTPUT,
	@EngineTypeGuid uniqueidentifier = NULL OUTPUT,
	@EngineTypeID tinyint = NULL OUTPUT,
	@Host nvarchar(256) = NULL,
	@Info xml = NULL,
	@IPAddress nvarchar(48) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		DECLARE @NoActivityTimeout int;
		SELECT @NoActivityTimeout = NoActivityTimeout FROM Engine.Settings WITH(NOLOCK) WHERE EngineID = 1;
		
		IF @EngineGuid IS NULL OR @EngineGuid = CONVERT(uniqueidentifier, CONVERT(binary(1), 0))
			RAISERROR('The specified engine identifier is invalid.', 16, 1);
				
		IF @EngineTypeGuid IS NOT NULL OR @EngineTypeID IS NOT NULL
		SELECT TOP 1
				@EngineTypeGuid = EngineTypeGuid,
				@EngineTypeID = EngineTypeID
		FROM	Engine.[Types] WITH(NOLOCK)
		WHERE	((@EngineTypeGuid IS NULL) OR (EngineTypeGuid = @EngineTypeGuid)) AND
				((@EngineTypeID IS NULL) OR (EngineTypeID = @EngineTypeID));
				
		IF @EngineTypeGuid IS NULL OR @EngineTypeID IS NULL
			SELECT TOP 1
					@EngineTypeGuid = ET.EngineTypeGuid,
					@EngineTypeID = ET.EngineTypeID
			FROM	Cloud.Engines AS CE WITH(NOLOCK)
					INNER JOIN Engine.[Types] AS ET
							ON CE.EngineTypeID = ET.EngineTypeID
			WHERE	(CE.EngineGuid = @EngineGuid);
				
		IF @EngineTypeGuid IS NULL OR @EngineTypeID IS NULL
			RAISERROR('The specified engine type is invalid.', 16, 1);
				
		BEGIN TRANSACTION TRegisterEngine;
		
		IF EXISTS	(
						SELECT TOP 1 
								1 
						FROM	Cloud.Engines AS CE
								INNER JOIN Engine.[Types] AS ET
										ON CE.EngineTypeID = ET.EngineTypeID
						WHERE	(CE.EngineGuid = @EngineGuid) AND 
								(CE.EngineTypeID = @EngineTypeID) AND
								(CE.IsExpired = 0) AND 
								(
									(CE.LastActivityDate >= DATEADD(ss, ABS(@NoActivityTimeout) * -1, GETDATE())) OR 
									(ET.AllowExpire = 0)
								)
					)
			BEGIN;
				UPDATE	CE
				SET		@EngineID = CE.EngineID,
						CountActivity = ISNULL(CE.CountActivity, 0) + 1,
						Host = ISNULL(@Host, CE.Host),
						Info = ISNULL(@Info, CE.Info),
						IPAddress = ISNULL(@IPAddress, CE.IPAddress),
						LastActivityDate = GETDATE()
				FROM	Cloud.Engines AS CE
				WHERE	(EngineGuid = @EngineGuid);
			END;
		ELSE
			BEGIN;
				UPDATE	CE
				SET		ExpiredDate = GETDATE(),
						IsExpired = 1
				FROM	Cloud.Engines AS CE
				WHERE	(EngineGuid = @EngineGuid) AND
						(IsExpired = 0);
						
				SET @EngineGuid = NEWID();
						
				INSERT INTO Cloud.Engines
						(CountActivity,
						CreatedDate,
						EngineGuid,
						EngineTypeID,
						Host,
						Info,
						IsExpired,
						IPAddress,
						LastActivityDate)
				VALUES	(1,
						GETDATE(),
						@EngineGuid,
						@EngineTypeID,
						@Host,
						@Info,
						0,
						@IPAddress,
						GETDATE()); 
						
				SET @EngineID = SCOPE_IDENTITY();
			END;
				
		COMMIT TRANSACTION TRegisterEngine;
								
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
											@EngineGuid = @EngineGuid,
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
GRANT EXECUTE ON  [Cloud].[RegisterEngine] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[RegisterEngine] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[RegisterEngine] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[RegisterEngine] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[RegisterEngine] TO [Submitter]
GO
