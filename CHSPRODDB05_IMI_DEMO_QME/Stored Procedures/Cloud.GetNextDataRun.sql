SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/10/2013
-- Description:	Returns the next available datarun for submittal (used by the Submitter).
-- =============================================
CREATE PROCEDURE [Cloud].[GetNextDataRun]
(
	@Data xml = NULL OUTPUT,
	@DataRunGuid uniqueidentifier = NULL OUTPUT,
	@DataRunID int = NULL OUTPUT,
	@DataSetGuid uniqueidentifier = NULL OUTPUT,
	@DataSetID int = NULL OUTPUT,
	@OwnerGuid uniqueidentifier = NULL OUTPUT,
	@OwnerID int = NULL OUTPUT,
	@RetrieveDataRunInfo bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
	
		IF EXISTS (SELECT TOP 1 1 FROM Batch.DataRuns WHERE (IsSubmitted = 0) AND (IsReady = 1))
			BEGIN;
		
				BEGIN TRANSACTION TNextDataRun;
			
				DECLARE @DataRuns TABLE
				(	
					DataRunGuid uniqueidentifier NOT NULL,
					DataRunID int NOT NULL
				);
				
				UPDATE	BDR
				SET		@DataSetGuid = BDS.DataSetGuid,
						@DataSetID = BDS.DataSetID,
						@OwnerGuid = BDO.OwnerGuid,
						@OwnerID = BDO.OwnerID,
						IsSubmitted = 1,
						SubmittedDate = GETDATE()
				OUTPUT	INSERTED.DataRunGuid, INSERTED.DataRunID INTO @DataRuns(DataRunGuid, DataRunID)
				FROM	Batch.DataRuns AS BDR
						INNER JOIN Batch.DataSets AS BDS WITH(NOLOCK)
								ON BDR.DataSetID = BDS.DataSetID
						INNER JOIN Batch.DataOwners AS BDO WITH(NOLOCK)
								ON BDS.OwnerID = BDO.OwnerID
				WHERE	(BDR.DataRunID IN (SELECT MIN(t.DataRunID) AS DataRunID FROM Batch.DataRuns AS t WHERE (t.IsSubmitted = 0) AND (t.IsReady = 1)))
				OPTION	(MAXDOP 1);
						
				SELECT TOP 1 @DataRunGuid = DataRunGuid, @DataRunID = DataRunID FROM @DataRuns;
				
				IF @RetrieveDataRunInfo = 1 AND @DataRunID IS NOT NULL
					EXEC Cloud.GetDataRunInfo @Data = @Data OUTPUT, @DataRunID = @DataRunID;			
					
				COMMIT TRANSACTION TNextDataRun;
				
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
GRANT VIEW DEFINITION ON  [Cloud].[GetNextDataRun] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextDataRun] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetNextDataRun] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetNextDataRun] TO [Submitter]
GO
