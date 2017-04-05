SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/5/2013
-- Description:	Marks the specified batch as confirmed.
-- =============================================
CREATE PROCEDURE [Cloud].[ConfirmBatchSubmission]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF @BatchGuid IS NULL AND @BatchID IS NULL
			RAISERROR('The specified batch is invalid.', 16, 1);
		
		BEGIN TRANSACTION TConfirmBatch;
		
		UPDATE	BB
		SET 	ConfirmedDate = GETDATE(),
				IsConfirmed = 1
		FROM	Batch.[Batches] AS BB
		WHERE	((@BatchGuid IS NULL) OR (BB.BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BB.BatchID = @BatchID)) AND
				(ConfirmedDate IS NULL) AND
				(IsConfirmed = 0);

		COMMIT TRANSACTION TConfirmBatch;
								
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
GRANT EXECUTE ON  [Cloud].[ConfirmBatchSubmission] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConfirmBatchSubmission] TO [Submitter]
GO
