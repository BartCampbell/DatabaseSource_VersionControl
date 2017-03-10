SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/21/2015
-- Description:	Returns a list of data runs and whether or not the runs have been summarized into the Results schema tables.
-- =============================================
CREATE PROCEDURE [Result].[GetDataRunSummarizeStatus]
(
	@DataRunID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	BDR.DataRunID, 
				BDR.CreatedBy,
				BDR.CreatedDate,
				BDR.MeasureSetID,
				BDR.FileFormatID,
				BDR.ReturnFileFormatID,
				BDR.BeginInitSeedDate,
				BDR.EndInitSeedDate,
				CONVERT(bit, CASE WHEN RDSRK.DataRunID IS NOT NULL THEN 1 ELSE 0 END) AS IsSummarized,
				RDSRK.MeasureSetDescr AS KeyDescr
		FROM	Batch.DataRuns AS BDR WITH(NOLOCK)
				LEFT OUTER JOIN Result.DataSetRunKey AS RDSRK WITH(NOLOCK)
						ON RDSRK.DataRunID = BDR.DataRunID
		WHERE	(@DataRunID IS NULL) OR (BDR.DataRunID = @DataRunID)
		ORDER BY 1;

	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(MAX);
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
GRANT VIEW DEFINITION ON  [Result].[GetDataRunSummarizeStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[GetDataRunSummarizeStatus] TO [db_executer]
GO
GRANT EXECUTE ON  [Result].[GetDataRunSummarizeStatus] TO [Processor]
GO
