SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/21/2011
-- Description:	Runs custom processes before results are finalized.
-- =============================================
CREATE PROCEDURE [Batch].[RunCustomProcessesForPreResults]
(
	@BatchID int,
	@Iteration tinyint = NULL,
	@MeasureID int = NULL
)
AS
BEGIN
SET NOCOUNT ON;
	
	--DECLARE @BeginInitSeedDate datetime;
	--DECLARE @DataRunID int;
	--DECLARE @DataSetID int;
	--DECLARE @EndInitSeedDate datetime;
	--DECLARE @IsLogged bit;
	--DECLARE @MeasureSetID int;
	--DECLARE @OwnerID int;
	--DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;	
		--SELECT	@BeginInitSeedDate = DR.BeginInitSeedDate,
		--		@DataRunID = DR.DataRunID,
		--		@DataSetID = DS.DataSetID,
		--		@EndInitSeedDate = DR.EndInitSeedDate,
		--		@IsLogged = DR.IsLogged,
		--		@MeasureSetID = DR.MeasureSetID,
		--		@OwnerID = DS.OwnerID,
		--		@SeedDate = DR.SeedDate
		--FROM	Batch.[Batches] AS B 
		--		INNER JOIN Batch.DataRuns AS DR
		--				ON B.DataRunID = DR.DataRunID
		--		INNER JOIN Batch.DataSets AS DS 
		--				ON B.DataSetID = DS.DataSetID 
		--WHERE	(B.BatchID = @BatchID);

		DECLARE @MeasProcTypeID tinyint;

		SELECT	@MeasProcTypeID = MeasProcTypeID
		FROM	Measure.CustomProcessTypes 
		WHERE	(Abbrev = 'PreR');
		
		EXEC @Result = Batch.RunCustomProcesses  
						@BatchID = @BatchID, 
						@Iteration = @Iteration, 
						@MeasureID = @MeasureID,
						@MeasProcTypeID = @MeasProcTypeID;

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
GRANT VIEW DEFINITION ON  [Batch].[RunCustomProcessesForPreResults] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[RunCustomProcessesForPreResults] TO [db_executer]
GO
GRANT EXECUTE ON  [Batch].[RunCustomProcessesForPreResults] TO [Processor]
GO
