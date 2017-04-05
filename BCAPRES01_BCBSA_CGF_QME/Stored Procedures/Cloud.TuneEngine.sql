SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/26/2013
-- Description:	Tunes the engine by removing unnecessary data, while also rebuilding indexes and updating statistics.
-- =============================================
CREATE PROCEDURE [Cloud].[TuneEngine]
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		IF EXISTS (SELECT TOP 1 1 FROM Engine.Settings WHERE (LastResetDate IS NULL) OR (LastResetDate < DATEADD(second, ISNULL(TuneInterval, (60 * 5)) * -1, GETDATE())))
			EXEC Engine.ResetEngine;
								
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
GRANT EXECUTE ON  [Cloud].[TuneEngine] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[TuneEngine] TO [Submitter]
GO
