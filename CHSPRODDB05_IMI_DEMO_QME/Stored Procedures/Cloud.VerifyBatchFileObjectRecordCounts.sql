SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/23/2016
-- Description:	Verifies all record counts of the tables related to the file objects for the given batch or data run. 
-- =============================================
CREATE PROCEDURE [Cloud].[VerifyBatchFileObjectRecordCounts]
(
	@BatchID int = NULL,
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY;
		DECLARE @DataSetID int;
		DECLARE @EngineTypeP tinyint;
		DECLARE @EngineTypeS tinyint;
		DECLARE @FileFormatID int;

		IF @DataRunID IS NULL
			RAISERROR('The specified data run is invalid.', 16, 1);

		SELECT @EngineTypeP = EngineTypeID FROM Engine.[Types] WHERE Descr = 'Processor';
		SELECT @EngineTypeS = EngineTypeID FROM Engine.[Types] WHERE Descr = 'Submitter';

		SELECT	@DataSetID = DataSetID,
				@FileFormatID = CASE ES.EngineTypeID WHEN @EngineTypeP THEN BDR.FileFormatID WHEN @EngineTypeS THEN BDR.ReturnFileFormatID END
		FROM	Batch.DataRuns AS BDR
				CROSS JOIN Engine.Settings AS ES
		WHERE	(BDR.DataRunID = @DataRunID);

		IF @FileFormatID IS NOT NULL AND EXISTS (SELECT TOP 1 1 FROM Cloud.BatchFileObjects WHERE DataRunID = @DataRunID AND FileFormatID = @FileFormatID)
			BEGIN;
				DECLARE @Batches TABLE (BatchID int NOT NULL, PRIMARY KEY CLUSTERED (BatchID));

				INSERT INTO @Batches
				SELECT	BB.BatchID
				FROM	Batch.[Batches] AS BB
				WHERE	((@BatchID IS NULL) OR (BB.BatchID = @BatchID)) AND
						(BB.DataRunID = @DataRunID)
				ORDER BY 1;

				IF @DataSetID IS NULL OR NOT EXISTS (SELECT TOP 1 1 FROM @Batches)
					RAISERROR('The specified batch and data run combination is invalid.', 16, 1);

				DECLARE @BatchFileObjects TABLE (BatchID int NOT NULL, CountRecords bigint NULL, FileObjectID int NOT NULL, PRIMARY KEY CLUSTERED (BatchID, FileObjectID));

				DECLARE @ID int, @MaxID int, @MinID int;
				SELECT @ID = MIN(BatchID), @MaxID = MAX(BatchID), @MinID = MIN(BatchID) FROM @Batches;

				WHILE (@ID BETWEEN @MinID AND @MaxID)
					BEGIN;
						INSERT INTO @BatchFileObjects
								(BatchID, CountRecords, FileObjectID)
						EXEC Cloud.GetBatchFileObjectRecordCounts @BatchID = @ID, @FileFormatID = @FileFormatID, @FileObjectID = NULL, @IsVerify = 1;

						SELECT @ID = MIN(BatchID) FROM @Batches WHERE BatchID > @ID;
					END;
	
				BEGIN TRANSACTION TBatchFileCountVerify;

				UPDATE	CBFO
				SET		CountVerified = ISNULL(t.CountRecords, 0),
						IsVerified = CASE WHEN CBFO.CountRecords = ISNULL(t.CountRecords, 0) THEN 1 ELSE 0 END,
						CBFO.VerifiedDate = GETDATE()
				FROM	Cloud.BatchFileObjects AS CBFO
						LEFT OUTER JOIN @BatchFileObjects AS t
								ON t.BatchID = CBFO.BatchID AND
									t.FileObjectID = CBFO.FileObjectID;

				DECLARE @IsVerified bit;
				SELECT	@IsVerified = CONVERT(bit, MIN(CONVERT(tinyint, IsVerified)))
				FROM	Cloud.BatchFileObjects
				WHERE	((@BatchID IS NULL) OR (BatchID = @BatchID)) AND
						(FileFormatID = @FileFormatID) AND
						(DataRunID = @DataRunID);

				UPDATE	Result.DataSetRunKey
				SET		IsVerified = @IsVerified,
						VerifiedDate = GETDATE()
				WHERE	(DataRunID = @DataRunID);

				COMMIT TRANSACTION TBatchFileCountVerify;

				SELECT	CASE WHEN CBFO.IsVerified = 1 THEN 'Passed' ELSE 'FAILED' END AS [Verification],
						CBFO.BatchFileObjectID AS [ID],
						CBFO.BatchID AS [Batch ID],
						CFO.FileObjectID AS [File Object ID],
						CFO.ObjectName AS [File Object Name],
						CASE WHEN CFO.InSourceSchema IS NOT NULL AND CFO.InSourceName IS NOT NULL 
								THEN QUOTENAME(CFO.InSourceSchema) + '.' + QUOTENAME(CFO.InSourceName)
								ELSE ISNULL(QUOTENAME(CFO.OutSourceSchema) + '.' + QUOTENAME(CFO.OutSourceName), '')
								END AS [Object],
                        CBFO.CountRecords AS [Count Processed],
                        CBFO.CountVerified AS [Count Received],
						CBFO.CountRecords - ISNULL(CBFO.CountVerified, 0) AS [Difference],
                        CBFO.CreatedDate AS [Date Processed],
                        CBFO.VerifiedDate AS [Date Verified],
						dbo.GetTimeElapse(CBFO.CreatedDate, CBFO.VerifiedDate) AS [Time Elapse]
				INTO	#BatchFileCountVerifyResults
				FROM	Cloud.BatchFileObjects AS CBFO
						INNER JOIN Cloud.FileObjects AS CFO
								ON CFO.FileObjectID = CBFO.FileObjectID
				WHERE	((@BatchID IS NULL) OR (CBFO.BatchID = @BatchID)) AND
						(CBFO.FileFormatID = @FileFormatID) AND
						(CBFO.DataRunID = @DataRunID)

				
				SELECT	[Verification], 
						[File Object ID], 
						[File Object Name], 
						[Object],
						COUNT(DISTINCT [Batch ID]) AS [Batch Count],
						SUM([Count Processed]) AS [Total Processed],
						SUM([Count Received]) AS [Total Recevied],
						SUM([Difference]) AS [Difference]
				FROM	#BatchFileCountVerifyResults
				GROUP BY [Verification], [File Object ID], [File Object Name], [Object]
				ORDER BY [Verification], [Object];

				IF EXISTS (SELECT TOP 1 1 FROM #BatchFileCountVerifyResults WHERE Verification = 'Failed')
					SELECT	*
					FROM	#BatchFileCountVerifyResults
					WHERE	Verification = 'Failed' 
					ORDER BY [Verification], [Object], [Batch ID], [ID];

				PRINT '';
				
				IF @IsVerified = 0 
					BEGIN;
						PRINT '*** Verification of expected record counts failed. *** ';
						PRINT '(Please see resultset for details)';
						PRINT '';

						IF @BatchID IS NULL
							RAISERROR('The specified batch did not pass verification.', 16, 1);
						ELSE
							RAISERROR('The specified data run did not pass verification.', 16, 1);
					END;
				ELSE
					BEGIN;
						PRINT '*** Verification of expected record counts passed. ***';
						PRINT '';
					END;
			END;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(MAX);
		SET @ErrMsg = ERROR_MESSAGE();

		RAISERROR(@ErrMsg, 16, 1);
	END CATCH;
END
GO
GRANT EXECUTE ON  [Cloud].[VerifyBatchFileObjectRecordCounts] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[VerifyBatchFileObjectRecordCounts] TO [Submitter]
GO
