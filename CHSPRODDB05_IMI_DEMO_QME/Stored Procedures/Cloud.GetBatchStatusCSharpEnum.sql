SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/1/2013
-- Description:	Returns all batch status formatted for pasting into the C# BatchStatus enum.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchStatusCSharpEnum]
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	Descr + ' = ' + CONVERT(varchar(16), BatchStatusID) + ', ' AS [public enum BatchStatus : short]
		FROM	Batch.[Status] 
		ORDER BY BatchStatusID;
								
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
GRANT VIEW DEFINITION ON  [Cloud].[GetBatchStatusCSharpEnum] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchStatusCSharpEnum] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchStatusCSharpEnum] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchStatusCSharpEnum] TO [Submitter]
GO
