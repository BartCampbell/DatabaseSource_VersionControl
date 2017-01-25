SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2011
-- Description:	Creates a log entry for the specified error.
-- =============================================
CREATE PROCEDURE [Log].[RecordError]
(
	@Application nvarchar(128) = NULL,
	@BatchID int = NULL,
	@DataRunID int = NULL,
	@DataSetID int = NULL,
	@EngineGuid uniqueidentifier = NULL,
	@ErrLogID int = NULL OUTPUT,
	@ErrorNumber int = NULL,
	@ErrorType char(1) = 'X',
	@Info xml = NULL,
	@IPAddress nvarchar(48) = NULL,
	@LineNumber int = 0,
	@MeasureSetID int = NULL,
	@Message nvarchar(max),
	@OwnerID int = NULL,
	@PerformRollback bit = 1,
	@Severity int = NULL,
	@Source nvarchar(512) = NULL,
	@SPID int = NULL,
	@State int = NULL,
	@Stack nvarchar(max) = NULL,
	@Target nvarchar(512) = NULL,
	@UserName nvarchar(384) = NULL
) 
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Host nvarchar(128);
	
	IF @EngineGuid IS NULL
		SET @EngineGuid = Engine.GetEngineGuid();
	
	WHILE (@@TRANCOUNT > 0 AND ISNULL(@PerformRollback, 1) = 1)
		ROLLBACK;
	
    BEGIN TRY

		DECLARE @query_plan xml;
		
		BEGIN TRY;
			SELECT	@Application = CASE WHEN @Application IS NULL THEN APP_NAME() ELSE @Application + ' (' + APP_NAME() + ')' END,
					@Host = HOST_NAME(),
					@SPID = CASE WHEN @SPID IS NULL THEN @@SPID ELSE @SPID END;
		END TRY
		BEGIN CATCH
			--DO NOTHING
		END CATCH;
						
		BEGIN TRY;
			IF @IPAddress IS NULL 
				BEGIN;
					SELECT	@IPAddress = EC.client_net_address
					FROM	sys.dm_exec_connections AS EC		
					WHERE	(EC.session_id = @@SPID);	
				END;
		END TRY
		BEGIN CATCH
			--DO NOTHING
		END CATCH;
		   
		INSERT INTO [Log].ProcessErrors
				([Application], BatchID, DataRunID, DataSetID, LogDate, LogUser, EngineGuid, ErrorNumber, 
				ErrorType, Host, Info, IPAddress, LineNumber, MeasureSetID, [Message],  OwnerID,
				Severity, [Source], [SPID], [State], Stack, [Target])
		VALUES
				(@Application, @BatchID, @DataRunID, @DataSetID, GETDATE(), ISNULL(@UserName, suser_sname()), @EngineGuid, @ErrorNumber, 
				@ErrorType, @Host, @Info, @IPAddress, @LineNumber, @MeasureSetID, @Message, @OwnerID,
				@Severity, @Source, @SPID, @State, @Stack, @Target);

		SET @ErrLogID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
		--No Error Logging in the this process, since it is the error logger.  Just print error and return error number.
		DECLARE @ErrMessage nvarchar(512);
		SET @ErrMessage = '***ERROR: ' + ERROR_MESSAGE()
    
		PRINT @ErrMessage;
		RETURN ERROR_NUMBER();
    END CATCH
    
    IF @ErrorType = 'Q' AND ISNULL(@PerformRollback, 1) = 1
		RAISERROR (@Message, @Severity, @State);
	
	RETURN 0
END


GO
GRANT EXECUTE ON  [Log].[RecordError] TO [Controller]
GO
GRANT EXECUTE ON  [Log].[RecordError] TO [NController]
GO
GRANT EXECUTE ON  [Log].[RecordError] TO [NService]
GO
GRANT EXECUTE ON  [Log].[RecordError] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[RecordError] TO [Submitter]
GO
