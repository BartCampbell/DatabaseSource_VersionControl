SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/5/2013
-- Description:	Marks the specified data run as confirmed.
-- =============================================
CREATE PROCEDURE [Cloud].[ConfirmDataRunSubmission]
(
	@DataRunGuid uniqueidentifier = NULL,
	@DataRunID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF @DataRunGuid IS NULL AND @DataRunID IS NULL
			RAISERROR('The specified data run is invalid.', 16, 1);
		
		BEGIN TRANSACTION TConfirmDataRun;
		
		UPDATE	BDR
		SET 	ConfirmedDate = GETDATE(),
				IsConfirmed = 1
		FROM	Batch.DataRuns AS BDR
		WHERE	((@DataRunGuid IS NULL) OR (BDR.DataRunGuid = @DataRunGuid)) AND
				((@DataRunID IS NULL) OR (BDR.DataRunID = @DataRunID)) AND
				(ConfirmedDate IS NULL) AND
				(IsConfirmed = 0);

		COMMIT TRANSACTION TConfirmDataRun;
								
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
GRANT EXECUTE ON  [Cloud].[ConfirmDataRunSubmission] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[ConfirmDataRunSubmission] TO [Submitter]
GO
