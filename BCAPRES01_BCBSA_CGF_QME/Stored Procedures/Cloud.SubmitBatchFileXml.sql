SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/17/2012
-- Description:	Submits xml-based batch file data to the database tables.
-- =============================================
CREATE PROCEDURE [Cloud].[SubmitBatchFileXml]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@BatchSourceGuid uniqueidentifier = NULL,
	@CleanUpType varchar(16) = NULL,
	@Data xml,
	@FileFormatGuid uniqueidentifier = NULL,
	@FileFormatID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		--i) Validate the batch...
		IF @BatchGuid IS NULL AND @BatchID IS NULL AND @BatchSourceGuid IS NULL
			RAISERROR('The batch was not specified.', 16, 1);

		SELECT TOP 1 
				@BatchGuid = BatchGuid, 
				@BatchID = BatchID,
				@BatchSourceGuid = SourceGuid
		FROM	Batch.[Batches] 
		WHERE	((@BatchGuid IS NULL) OR (BatchGuid = @BatchGuid)) AND
				((@BatchID IS NULL) OR (BatchID = @BatchID)) AND
				((@BatchSourceGuid IS NULL) OR (SourceGuid = @BatchSourceGuid));

		IF @BatchGuid IS NULL OR @BatchID IS NULL
			RAISERROR('The specified batch is invalid.', 16, 1);
		
		--ii) Validate the file format...
		IF @FileFormatGuid IS NULL AND @FileFormatID IS NULL
			RAISERROR('The file format was not specified.', 16, 1);
		
		SELECT TOP 1
				@FileFormatGuid = FileFormatGuid,
				@FileFormatID = FileFormatID
		FROM	Cloud.FileFormats
		WHERE	((@FileFormatGuid IS NULL) OR (FileFormatGuid = @FileFormatGuid)) AND
				((@FileFormatID IS NULL) OR (FileFormatID = @FileFormatID));

		IF @FileFormatGuid IS NULL OR @FileFormatID IS NULL
			RAISERROR('The specified file format is invalid.', 16, 1);		
								
		IF @Data IS NOT NULL
			BEGIN;
				DECLARE @Result int;
				
				--i) Store the batch data, if setting is enabled...
				IF EXISTS (SELECT TOP 1 1 FROM Engine.Settings WHERE SaveBatchData = 1)
					INSERT INTO Batch.BatchData
					        (BatchID,
					         CreatedBy,
					         CreatedDate,
					         Data,
					         FileFormatID)
					VALUES  (@BatchID,
							SUSER_SNAME(),
							GETDATE(),
							@Data,
							@FileFormatID);
			
				--1) Apply the return XML data, if applicable...
				EXEC @Result = Cloud.ApplyBatchFileXML
										@BatchID = @BatchID, 
										@Data = @Data, 
										@FileFormatID = @FileFormatID,
										@InsertRecords = 1, 
										@PrintSql = 0;
				
				--2) Clean up any missing values...
				IF @Result = 0 AND @CleanUpType IS NOT NULL
					EXEC @Result = Cloud.CleanUpMissingValues @BatchID = @BatchID, @CleanUpType = @CleanUpType;

				--3) Mark batch as "retrieved"...
				IF @Result = 0
					UPDATE Batch.[Batches] SET IsRetrieved = 1, RetrievedDate = GETDATE() WHERE BatchID = @BatchID;
			END;
		ELSE
			RAISERROR('The specified xml data is invalid.', 16, 1);	

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
GRANT EXECUTE ON  [Cloud].[SubmitBatchFileXml] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[SubmitBatchFileXml] TO [Submitter]
GO
