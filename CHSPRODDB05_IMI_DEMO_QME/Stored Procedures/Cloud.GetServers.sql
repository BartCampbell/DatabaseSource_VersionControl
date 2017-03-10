SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Returns one or more servers based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Cloud].[GetServers]
(
	@IsEnabled bit = NULL,
	@ServerGuid uniqueidentifier = NULL,
	@ServerID smallint = NULL,
	@ServerTypeID tinyint = NULL
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
		--WHERE (B.BatchID = @BatchID);
				
		SELECT	*
		FROM	Cloud.[Servers]
		WHERE	((@IsEnabled IS NULL) OR (IsEnabled = @IsEnabled)) AND
				((@ServerGuid IS NULL) OR (ServerGuid = @ServerGuid)) AND
				((@ServerID IS NULL) OR (ServerID = @ServerID)) AND
				((@ServerTypeID IS NULL) OR (ServerTypeID = @ServerTypeID))
								
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
GRANT VIEW DEFINITION ON  [Cloud].[GetServers] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetServers] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetServers] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetServers] TO [Submitter]
GO
