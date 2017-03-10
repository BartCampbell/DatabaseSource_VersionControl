SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/30/2013
-- Description:	Sets the status of a specific batch.
-- =============================================
CREATE PROCEDURE [Cloud].[SetBatchStatus]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchSourceGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@BatchStatusID smallint = NULL,
	@EngineGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF @BatchGuid IS NULL AND @BatchID IS NULL AND @BatchSourceGuid IS NULL
			RAISERROR('The specified batch is invalid.', 16, 1);
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM Batch.[Status] WITH (NOLOCK) WHERE (BatchStatusID = @BatchStatusID))
			RAISERROR('The specified batch status is invalid.', 16, 1);
		
		BEGIN TRANSACTION TSetBatchStatus;
		
		UPDATE TOP (1) BB
		SET 	BatchStatusID = @BatchStatusID
		FROM	Batch.[Batches] AS BB
		WHERE	(BB.BatchStatusID NOT IN (-32768, 32767)) AND
				((@BatchGuid IS NULL) OR (BB.BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BB.BatchID = @BatchID)) AND
				((@BatchSourceGuid IS NULL) OR (BB.SourceGuid = @BatchSourceGuid));
								
		COMMIT TRANSACTION TSetBatchStatus;
		
		IF @EngineGuid IS NOT NULL
			EXEC Cloud.UpdateEngineActivity @EngineGuid = @EngineGuid;
								
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
GRANT EXECUTE ON  [Cloud].[SetBatchStatus] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[SetBatchStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SetBatchStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[SetBatchStatus] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[SetBatchStatus] TO [Submitter]
GO
