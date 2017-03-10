SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/2/2013
-- Description:	Returns the next available batch for submittal (used by the Submitter).
-- =============================================
CREATE PROCEDURE [Cloud].[GetNextBatch]
(
	@BatchGuid uniqueidentifier = NULL OUTPUT,
	@BatchID int = NULL OUTPUT,
	@Data xml = NULL OUTPUT,
	@FileFormatGuid uniqueidentifier = NULL OUTPUT,
	@FileFormatID int = NULL OUTPUT,
	@MeasureSetGuid uniqueidentifier = NULL OUTPUT,
	@MeasureSetID int = NULL OUTPUT,
	@OwnerGuid uniqueidentifier = NULL OUTPUT,
	@OwnerID int = NULL OUTPUT,
	@RetrieveBatchFileXml bit = 0,
	@ReturnFileFormatGuid uniqueidentifier = NULL OUTPUT,
	@ReturnFileFormatID int = NULL OUTPUT,
	@SourceGuid uniqueidentifier = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		--Determines the BatchGuid and BatchID if "next available batch" sent...
		IF EXISTS (SELECT TOP 1 1 FROM [Batch].[Batches] AS t WHERE (t.IsSubmitted = 0)) 
			BEGIN;
				BEGIN TRANSACTION TNextBatch;
			
				DECLARE @Batches TABLE
				(	
					BatchGuid uniqueidentifier NOT NULL,
					BatchID int NOT NULL,
					SourceGuid uniqueidentifier NULL
				);
				
				DECLARE @SortTypeID tinyint;
				SET @SortTypeID = CASE WHEN CONVERT(tinyint, RIGHT(CONVERT(varchar(32), CHECKSUM(NEWID())), 1)) <= 4 THEN 1 ELSE 2 END;

				UPDATE	BB
				SET		@FileFormatGuid = CFF1.FileFormatGuid,
						@FileFormatID = BDR.FileFormatID,
						@MeasureSetGuid = MMS.MeasureSetGuid,
						@MeasureSetID = MMS.MeasureSetID,
						@OwnerGuid = BDO.OwnerGuid,
						@OwnerID = BDO.OwnerID,
						@ReturnFileFormatGuid = CFF2.FileFormatGuid,
						@ReturnFileFormatID = BDR.ReturnFileFormatID,
						IsSubmitted = 1,
						SubmittedDate = GETDATE()
				OUTPUT	INSERTED.BatchGuid, INSERTED.BatchID, INSERTED.SourceGuid INTO @Batches(BatchGuid, BatchID, SourceGuid)
				FROM	Batch.[Batches] AS BB WITH(TABLOCKX)
						INNER JOIN Batch.DataRuns AS BDR WITH (NOLOCK)
								ON BB.DataRunID = BDR.DataRunID AND
									BDR.IsConfirmed = 1 AND
									BDR.IsSubmitted = 1
						INNER JOIN Batch.DataSets AS BDS WITH (NOLOCK)
								ON BDR.DataSetID = BDS.DataSetID
						INNER JOIN Batch.DataOwners AS BDO WITH (NOLOCK)
								ON BDS.OwnerID = BDO.OwnerID
						INNER JOIN Measure.MeasureSets AS MMS WITH (NOLOCK)
								ON BDR.MeasureSetID = MMS.MeasureSetID
						INNER JOIN Cloud.FileFormats AS CFF1 WITH (NOLOCK)
								ON BDR.FileFormatID = CFF1.FileFormatID
						LEFT OUTER JOIN Cloud.FileFormats AS CFF2 WITH (NOLOCK)
								ON BDR.ReturnFileFormatID = CFF2.FileFormatID
				WHERE	((@SortTypeID = 1) AND (BB.BatchGuid IN (SELECT CONVERT(uniqueidentifier, MIN(CONVERT(binary(16), t.BatchGuid))) AS BatchGuid FROM [Batch].[Batches] AS t WITH(TABLOCKX) WHERE (t.IsSubmitted = 0)))) OR
						((@SortTypeID = 2) AND (BB.BatchID IN (SELECT MIN(t.BatchID) AS BatchID FROM [Batch].[Batches] AS t WITH(TABLOCKX) WHERE (t.IsSubmitted = 0))))
				OPTION	(MAXDOP 1);
						
				SELECT TOP 1 @BatchGuid = BatchGuid, @BatchID = BatchID, @SourceGuid = SourceGuid FROM @Batches;
				
				IF @RetrieveBatchFileXml = 1
				EXEC Cloud.GetBatchFileXml @BatchID = @BatchID, 
											@Data = @Data OUTPUT, 
											@FileFormatID = @FileFormatID, 
											@ReturnFileFormatID = @ReturnFileFormatID;
				
				COMMIT TRANSACTION TNextBatch;
			END;
		
								
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
GRANT VIEW DEFINITION ON  [Cloud].[GetNextBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatch] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetNextBatch] TO [Submitter]
GO
