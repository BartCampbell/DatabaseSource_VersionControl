SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/1/2013
-- Description:	Marks the specified file as retrieved.
-- =============================================
CREATE PROCEDURE [Cloud].[ConfirmBatchFileRetrieval]
(
	@BatchFileGuid uniqueidentifier = NULL,
	@BatchFileID int = NULL,
	@BatchStatusID smallint = NULL,
	@EngineGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF @BatchFileGuid IS NULL AND @BatchFileID IS NULL
			RAISERROR('The specified batch file is invalid.', 16, 1);
		
		BEGIN TRANSACTION TBatchFileRetrieved;
		
		DECLARE @BatchID int;
		
		UPDATE	CBF
		SET 	@BatchID = CBF.BatchID,
				IsRetrieved = 1,
				RetrievedDate = GETDATE()
		FROM	Cloud.BatchFiles AS CBF
		WHERE	((@BatchFileGuid IS NULL) OR (CBF.BatchFileGuid = @BatchFileGuid)) AND
				((@BatchFileID IS NULL) OR (CBF.BatchFileID = @BatchFileID)) AND
				(IsRetrieved = 0) AND
				(RetrievedDate IS NULL);
				
		IF @BatchID IS NOT NULL AND @BatchStatusID IS NOT NULL
			EXEC Cloud.SetBatchStatus @BatchID = @BatchID, @BatchStatusID = @BatchStatusID;
			
		COMMIT TRANSACTION TBatchFileRetrieved;
		
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
GRANT EXECUTE ON  [Cloud].[ConfirmBatchFileRetrieval] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[ConfirmBatchFileRetrieval] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[ConfirmBatchFileRetrieval] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[ConfirmBatchFileRetrieval] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConfirmBatchFileRetrieval] TO [Submitter]
GO
