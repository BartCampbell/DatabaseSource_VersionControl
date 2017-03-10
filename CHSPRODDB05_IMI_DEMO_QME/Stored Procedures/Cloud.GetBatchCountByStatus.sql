SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Returns the number of batches in the specified status.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchCountByStatus]
(
	@BatchStatusID smallint = NULL,
	@CountRecords bigint = NULL OUTPUT,
	@SelectResults bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
				
		SELECT	@CountRecords = 0 + COUNT(*) 
		FROM	Batch.[Batches] 
		WHERE	((@BatchStatusID IS NULL) OR (BatchStatusID = @BatchStatusID));	
				
		IF @SelectResults = 1
			SELECT	@CountRecords AS [Count];
								
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
GRANT VIEW DEFINITION ON  [Cloud].[GetBatchCountByStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchCountByStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchCountByStatus] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchCountByStatus] TO [Submitter]
GO
