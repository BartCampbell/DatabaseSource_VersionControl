SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2016
-- Description:	Records all record counts of the tables related to the file objects in the specified file format for the given batch. 
-- =============================================
CREATE PROCEDURE [Cloud].[CaptureBatchFileObjectRecordCounts]
(
	@BatchID int,
	@FileFormatID int,
	@FileObjectID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @DataRunID int;
	DECLARE @DataSetID int;

	SELECT	@DataRunID = BB.DataRunID,
			@DataSetID = BB.DataSetID
	FROM	Batch.[Batches] AS BB
	WHERE	(BB.BatchID = @BatchID);

	DECLARE @BatchFileObjects TABLE (BatchID int NOT NULL, CountRecords bigint NULL, FileObjectID int NOT NULL, PRIMARY KEY CLUSTERED (FileObjectID));

	INSERT INTO @BatchFileObjects
			(BatchID, CountRecords, FileObjectID)
	EXEC Cloud.GetBatchFileObjectRecordCounts @BatchID = @BatchID, @FileFormatID = @FileFormatID, @FileObjectID = @FileObjectID;
	
	INSERT INTO Cloud.BatchFileObjects
			(BatchID,
			CountRecords,
			DataRunID,
			DataSetID,
			FileFormatID,
			FileObjectID)
	SELECT	t.BatchID,
			t.CountRecords,
			@DataRunID,
			@DataSetID,
			CFO.FileFormatID,
			CFO.FileObjectID
	FROM	@BatchFileObjects AS t
			INNER JOIN Cloud.FileObjects AS CFO
					ON CFO.FileObjectID = t.FileObjectID
			LEFT OUTER JOIN Cloud.BatchFileObjects AS CBFO
					ON CBFO.BatchID = t.BatchID AND
						CBFO.FileObjectID = CFO.FileObjectID
	WHERE	(CBFO.BatchFileObjectID IS NULL)
	ORDER BY t.BatchID, t.FileObjectID;

END

GO
GRANT VIEW DEFINITION ON  [Cloud].[CaptureBatchFileObjectRecordCounts] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[CaptureBatchFileObjectRecordCounts] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[CaptureBatchFileObjectRecordCounts] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[CaptureBatchFileObjectRecordCounts] TO [Submitter]
GO
