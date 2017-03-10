SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/4/2012
-- Description:	Generates a test error message.
-- =============================================
CREATE PROCEDURE [Log].[GenerateTestError]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BatchID int;
	DECLARE @BeginInitSeedDate datetime;
	DECLARE @DataRunID int;
	DECLARE @DataSetID int;
	DECLARE @EndInitSeedDate datetime;
	DECLARE @IsLogged bit;
	DECLARE @MeasureSetID int;
	DECLARE @OwnerID int;
	DECLARE @SeedDate datetime;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'GenerateTestError'; 
		SET @LogObjectSchema = 'Log'; 
		
		--Added to determine @LogEntryXrefGuid value---------------------------
		SELECT @LogEntryXrefGuid = [Log].GetEntryXrefGuid (@LogObjectSchema, @LogObjectName);
		-----------------------------------------------------------------------
					
		--SELECT TOP 1
		--		@BatchID = B.BatchID,
		--		@BeginInitSeedDate = DR.BeginInitSeedDate,
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
		--				ON B.DataSetID = DS.DataSetID;
		
		RAISERROR('A test error was generated.', 16, 1);

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
GRANT VIEW DEFINITION ON  [Log].[GenerateTestError] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[GenerateTestError] TO [db_executer]
GO
GRANT EXECUTE ON  [Log].[GenerateTestError] TO [Processor]
GO
GRANT EXECUTE ON  [Log].[GenerateTestError] TO [Submitter]
GO
