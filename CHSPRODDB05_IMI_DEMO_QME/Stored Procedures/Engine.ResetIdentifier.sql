SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/10/2013
-- Description:	Sets the identifier for the current instance of the engine to the default value.
-- =============================================
CREATE PROCEDURE [Engine].[ResetIdentifier]
(
	@ClearAllData bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		DECLARE @DefaultIdentifier uniqueidentifier;
		DECLARE @DefaultType uniqueidentifier;
		
		SET @DefaultIdentifier = CONVERT(uniqueidentifier, '12345678-ABCD-EFFE-DCBA-109876543210');
		SET @DefaultType = CONVERT(uniqueidentifier, '4B3C3A20-6E86-45DD-971B-4D039A4387A1');
		
		BEGIN TRANSACTION TResetIdentifier;
		
		EXEC Engine.RegisterIdentifier @EngineGuid = @DefaultIdentifier, @EngineTypeGuid = @DefaultType;
								
		IF @ClearAllData = 1
			BEGIN;
			
				SELECT * INTO #Cloud_Engines FROM Cloud.Engines WHERE EngineID = 1;
				
				TRUNCATE TABLE Cloud.Engines;
				
				INSERT INTO Cloud.Engines 
						(CountActivity, CreatedDate, EngineGuid, EngineTypeID, ExpiredDate, Host, 
						Info, IsExpired, IPAddress, LastActivityDate) 
				SELECT	CountActivity, CreatedDate, EngineGuid, EngineTypeID, ExpiredDate, Host, 
						Info, IsExpired, IPAddress, LastActivityDate 
				FROM	#Cloud_Engines;
				DROP TABLE #Cloud_Engines;
			END;
								
		COMMIT TRANSACTION TResetIdentifier;
		
		EXEC Engine.ResetEngine;		
		
		UPDATE TOP (1) Engine.Settings SET LastResetDate = NULL, SaveBatchData = 0 WHERE (EngineID = 1);
		
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
GRANT EXECUTE ON  [Engine].[ResetIdentifier] TO [Processor]
GO
GRANT EXECUTE ON  [Engine].[ResetIdentifier] TO [Submitter]
GO
