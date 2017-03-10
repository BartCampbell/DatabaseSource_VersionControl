SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/14/2012
-- Description:	Verifies the check sum of the specified batch file after transmission.
-- =============================================
CREATE PROCEDURE [Cloud].[VerifyBatchFile]
(
	@BatchFileGuid uniqueidentifier = NULL,
	@BatchFileID int = NULL,
	@ChkSha256 varchar(64),
	@EngineGuid uniqueidentifier = NULL,
	@IsVerified bit = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		--i) Validate the batch...
		IF @BatchFileGuid IS NULL AND @BatchFileID IS NULL
			RAISERROR('The batch file was not specified.', 16, 1);

		SELECT TOP 1 
				@BatchFileGuid = BatchFileGuid, 
				@BatchFileID = BatchFileID
		FROM	Cloud.BatchFiles 
		WHERE	((@BatchFileGuid IS NULL) OR (BatchFileGuid = @BatchFileGuid)) AND
				((@BatchFileID IS NULL) OR (BatchFileID = @BatchFileID));

		IF @BatchFileGuid IS NULL
			RAISERROR('The specified batch file is invalid.', 16, 1);
		
		IF LEN(@ChkSha256) < 44
			RAISERROR('The specified file check sum is invalid.', 16, 1);
			
		BEGIN TRANSACTION TVerifyBatchFile;
			
		UPDATE	CBF
		SET		@IsVerified = 1,
				IsVerified = 1,
				VerifiedDate = GETDATE()
		FROM	Cloud.BatchFiles AS CBF
		WHERE	(CBF.BatchFileID = @BatchFileID) AND 
				(CBF.ChkSha256 = @ChkSha256);
		
		IF @IsVerified IS NULL
			SET @IsVerified = 0;
		
		COMMIT TRANSACTION TVerifyBatchFile;
		
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
GRANT EXECUTE ON  [Cloud].[VerifyBatchFile] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[VerifyBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[VerifyBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[VerifyBatchFile] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[VerifyBatchFile] TO [Submitter]
GO
