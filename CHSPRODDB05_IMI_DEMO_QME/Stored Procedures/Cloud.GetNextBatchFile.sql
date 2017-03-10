SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/2/2013
-- Description:	Returns the next available batch file for retrieval from the cloud (used by the Controller).
-- =============================================
CREATE PROCEDURE [Cloud].[GetNextBatchFile]
(
	@BatchFileGuid uniqueidentifier = NULL OUTPUT,
	@BatchFileID int = NULL OUTPUT,
	@BatchGuid uniqueidentifier = NULL OUTPUT,
	@BatchID int = NULL,	
	@DataRunGuid uniqueidentifier = NULL,
	@DataRunID int = NULL,
	@EngineGuid uniqueidentifier,
	@FileFormatCtgyAbbrev varchar(16) = NULL,
	@FileFormatCtgyGuid uniqueidentifier = NULL,
	@FileFormatCtgyID tinyint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

	BEGIN TRY;
	
		IF @EngineGuid IS NULL
			RAISERROR('The requesting engine identifier was not specified.', 16, 1);		
			
		DECLARE @EngineID int;
		SELECT @EngineID = EngineID FROM Cloud.Engines WHERE EngineGuid = @EngineGuid AND IsExpired = 0;
		
		IF @EngineID IS NULL
			RAISERROR('The requesting engine identifier is invalid.', 16, 1);	
	
		IF @DataRunGuid IS NULL AND @DataRunID IS NULL AND @FileFormatCtgyAbbrev IS NULL AND
			@FileFormatCtgyGuid IS NULL AND @FileFormatCtgyID IS NULL
			RAISERROR('Unable to retrieve next batch file.  The specified criteria is invalid.', 16, 1);
		
		BEGIN TRANSACTION TNextBatchFile;
		
		DECLARE @BatchFiles TABLE
		(	
			BatchFileGuid uniqueidentifier NOT NULL,
			BatchFileID int NOT NULL
		);

		WITH NextBatchFile AS
		(
			SELECT	MIN(CBF.BatchFileID) AS BatchFileID
			FROM	Cloud.BatchFiles AS CBF WITH(TABLOCKX)
					INNER JOIN Cloud.[Batches] AS CB WITH(SERIALIZABLE)
							ON CBF.BatchID = CB.BatchID
					INNER JOIN Batch.[Batches] AS BB WITH(SERIALIZABLE)
							ON CB.BatchID = BB.BatchID
					INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK)
							ON BB.DataRunID = BDR.DataRunID
					INNER JOIN Cloud.FileFormats AS CFF WITH(NOLOCK) 
							ON CBF.FileFormatID = CFF.FileFormatID 
					INNER JOIN Cloud.FileFormatCategories AS CFFC WITH(NOLOCK)
							ON CFF.FileFormatCtgyID = CFFC.FileFormatCtgyID
			WHERE	(CBF.IsAssigned = 0) AND
					(CBF.IsSubmitted = 1) AND
					(BB.BatchStatusID > 0) AND
					(BB.BatchStatusID < 32767) AND
					--Prevents results files from going to the wrong source------------------------------
					((CFFC.MatchEngine = 0) OR (CB.EngineID = @EngineID)) AND 
					-------------------------------------------------------------------------------------
					((@DataRunGuid IS NULL) OR (BDR.DataRunGuid = @DataRunGuid)) AND
					((@DataRunID IS NULL) OR (BDR.DataRunID = @DataRunID)) AND
					((@FileFormatCtgyAbbrev IS NULL) OR (CFFC.Abbrev = @FileFormatCtgyAbbrev)) AND
					((@FileFormatCtgyGuid IS NULL) OR (CFFC.FileFormatCtgyGuid = @FileFormatCtgyGuid)) AND
					((@FileFormatCtgyID IS NULL) OR (CFFC.FileFormatCtgyID = @FileFormatCtgyID))	
		)
		UPDATE	CBF
		SET		@BatchGuid = BB.BatchGuid,
				@BatchID = BB.BatchID,
				IsAssigned = 1,
				AssignedDate = GETDATE(),
				AssignedEngine = @EngineGuid
		OUTPUT	INSERTED.BatchFileGuid, INSERTED.BatchFileID INTO @BatchFiles(BatchFileGuid, BatchFileID)
		FROM	Cloud.BatchFiles AS CBF WITH(TABLOCKX)
				INNER JOIN Batch.[Batches] AS BB
						ON CBF.BatchID = BB.BatchID
		WHERE	(CBF.BatchFileID IN (SELECT MIN(t.BatchFileID) FROM NextBatchFile AS t)) AND
				(CBF.IsAssigned = 0) AND
				(CBF.IsSubmitted = 1) AND
				(BB.BatchStatusID > 0) AND
				(BB.BatchStatusID < 32767)
		OPTION (MAXDOP 1);
				
		SELECT TOP 1 @BatchFileGuid = BatchFileGuid, @BatchFileID = BatchFileID FROM @BatchFiles;
		
		EXEC Cloud.GetBatchFiles @BatchFileID = @BatchFileID;
		
		COMMIT TRANSACTION TNextBatchFile;
		
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
GRANT EXECUTE ON  [Cloud].[GetNextBatchFile] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetNextBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatchFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatchFile] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatchFile] TO [Submitter]
GO
