SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Cancels the specifed batch
-- =============================================
CREATE PROCEDURE [Cloud].[CancelBatch]
(
	@BatchGuid uniqueidentifier = NULL,
	@OwnerGuid uniqueidentifier = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BatchID int;
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
				
		DECLARE @Result int;
				
		IF @BatchID IS NOT NULL
			BEGIN;
				BEGIN TRANSACTION TCancelBatch;
			
				UPDATE Cloud.[Batches] SET IsCancelled = 1 WHERE BatchID = @BatchID;
				EXEC @Result = Batch.CancelProcessing @BatchID = @BatchID;			
				
				COMMIT TRANSACTION TCancelBatch;
			END;
		ELSE
			SET @Result = 1;
		
		RETURN @Result;
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
GRANT VIEW DEFINITION ON  [Cloud].[CancelBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[CancelBatch] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[CancelBatch] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[CancelBatch] TO [Submitter]
GO
