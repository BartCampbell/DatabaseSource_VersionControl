SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Returns the progress log for the specified batch.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchProgressLog]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@OwnerGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	BEGIN TRY;
		
		IF @BatchID IS NULL
			SELECT	@BatchID = B.BatchID
			FROM	Batch.[Batches] AS B
					INNER JOIN Batch.DataSets AS DS
							ON B.DataSetID = DS.DataSetID
					INNER JOIN Batch.DataOwners AS DO
							ON DS.OwnerID = DO.OwnerID
			WHERE	(B.BatchGuid = @BatchGuid) AND
					(DO.OwnerGuid = @OwnerGuid);
		
		IF @BatchID IS NOT NULL
			BEGIN
		
				SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
						@DataRunID = DR.DataRunID,
						@DataSetID = DS.DataSetID,
						@EndInitSeedDate = DR.EndInitSeedDate,
						@IsLogged = DR.IsLogged,
						@MeasureSetID = DR.MeasureSetID,
						@OwnerID = DS.OwnerID,
						@SeedDate = DR.SeedDate
				FROM	Batch.[Batches] AS B 
						INNER JOIN Batch.DataRuns AS DR
								ON B.DataRunID = DR.DataRunID
						INNER JOIN Batch.DataSets AS DS 
								ON B.DataSetID = DS.DataSetID 
				WHERE (B.BatchID = @BatchID);

				DECLARE @BatchText varchar(36);
				SET @BatchText = 'BATCH ' + CAST(@BatchID AS varchar(32));
								
				DECLARE @BatchStatusC smallint;
				SET @BatchStatusC = Batch.ConvertBatchStatusIDFromAbbrev('C') - 2;
								
				WITH LogProgress AS
				(
					SELECT  B.BatchID,
					        LP.BeginTime,
					        ISNULL(NULLIF(LP.CountRecords, -1), 0) AS CountRecords,
					        LP.DataRunID,
					        LP.DataSetID,
					        REPLACE(REPLACE(LP.Descr, @BatchText, 'NEW BATCH'), 'BATCH ?', 'NEW BATCH') AS Descr,
					        ISNULL(LP.EndTime, LP.BeginTime) AS EndTime,
					        LP.ErrLogID,
					        LP.IsSuccess,
					        LP.Iteration,
					        LP.MeasureSetID,
					        LP.OwnerID,
					        LP.LogDate AS ProgDate,
					        LP.LogID AS ProgLogID,
					        LP.LogUser AS ProgUser,
					        LP.SrcObjectGuid,
					        LP.SrcObjectID
					FROM	[Log].ProcessEntries AS LP
							INNER JOIN Batch.[Batches] AS B
									ON (LP.BatchID = B.BatchID OR LP.BatchID IS NULL) AND
										LP.DataRunID = B.DataRunID AND
										LP.DataSetID = B.DataSetID
					WHERE	(B.BatchID = @BatchID) AND
							(B.BatchStatusID BETWEEN 0 AND @BatchStatusC) AND
							(LP.DataRunID = @DataRunID) AND
							(LP.DataSetID = @DataSetID) AND
							(LP.OwnerID = @OwnerID)		
				)
				SELECT	CountRecords,
						Descr,
						/*CONVERT(varchar, LP.EndTime, 101) + ' ' +*/ CONVERT(varchar, LP.EndTime, 114) + '  ' + LTRIM(REPLACE(LP.Descr, ' - ', '   ')) + 
								--ISNULL(CHAR(13) + CHAR(10) +
										--REPLICATE(' ', LEN(REPLACE(CONVERT(varchar, LP.EndTime, 101) + ' ' + CONVERT(varchar, LP.EndTime, 114) + '  ', ' ', '*'))) + '(Records: ' + CONVERT(varchar, LP.CountRecords) + ')', 
										''--)
										 AS LogItem,
						LP.EndTime AS LogTime
				FROM	LogProgress AS LP

			END
								
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
GRANT EXECUTE ON  [Cloud].[GetBatchProgressLog] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchProgressLog] TO [Submitter]
GO
