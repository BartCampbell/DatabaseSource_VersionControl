SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/2/2013
-- Description:	Returns the completion status of one or more data runs.
-- =============================================
CREATE PROCEDURE [Cloud].[GetDataRunCompletion]
(
	@DataRunSourceGuid uniqueidentifier = NULL,
	@DataSetSourceGuid uniqueidentifier = NULL,
	@MachineName nvarchar(512) = NULL,
	@SqlDatabaseName nvarchar(512) = NULL,
	@SqlServername nvarchar(512) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		DECLARE @BatchStatusC smallint;
		SELECT @BatchStatusC = BatchStatusID FROM Batch.[Status] WHERE Abbrev = 'C';

		DECLARE @DataRuns TABLE
		(
			DataRunID int NOT NULL
		);

		DECLARE @BatchStatusDuration TABLE
		(
			AvgDuration decimal(24, 6) NOT NULL,
			BatchStatusID int NOT NULL,
			ID int IDENTITY(1, 1) NOT NULL,
			StatusPercentage decimal(18,12) NULL
		);

		DECLARE @BatchStatusPercentage TABLE
		(
			BatchStatusID int NOT NULL,
			StatusPercentage decimal(18,12) NULL
		);

		--1) Determine the data run(s) to analyze...
		WITH PossibleDataSetSources AS
		(
			SELECT 
					BDS.SourceGuid AS DataSetSourceGuid,
					MAX(BDS.DataSetID) AS DataSetID
			FROM	Cloud.[Batches] AS CB WITH(NOLOCK)
					INNER JOIN Cloud.Engines AS CE WITH(NOLOCK)
							ON CB.EngineID = CE.EngineID
					INNER JOIN Batch.[Batches] AS BB WITH(NOLOCK)
							ON CB.BatchID = BB.BatchID
					INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK)
							ON BB.DataRunID = BDR.DataRunID
					INNER JOIN Batch.DataSets AS BDS WITH(NOLOCK)
							ON BDR.DataSetID = BDS.DataSetID
			WHERE	((@DataSetSourceGuid IS NULL) OR (BDS.SourceGuid = @DataSetSourceGuid)) AND
					((@MachineName IS NULL) OR (CE.MachineName = @MachineName)) AND
					((@SqlDatabaseName IS NULL) OR (CE.SqlDatabaseName = @SqlDatabaseName)) AND
					((@SqlServername IS NULL) OR (CE.SqlServerName = @SqlServername))	
			GROUP BY BDS.SourceGuid		
		),
		PossibleDataSets AS
		(
			SELECT DataSetID FROM Batch.DataSets WITH(NOLOCK) WHERE (SourceGuid IN (SELECT TOP 1 DataSetSourceGuid FROM PossibleDataSetSources ORDER BY DataSetID DESC)) 
		),
		PossibleDataRuns AS
		(
			SELECT	DataRunID, DataSetID
			FROM	Batch.DataRuns AS BDR
			WHERE	(
						(BDR.SourceGuid = @DataRunSourceGuid) OR
						(
							(@DataRunSourceGuid IS NULL) AND
							(BDR.DataSetID IN (SELECT DataSetID FROM PossibleDataSets))
						)
					)
		)
		INSERT INTO @DataRuns
		SELECT	BDR.DataRunID 
		FROM	Batch.DataRuns AS BDR WITH(NOLOCK)
		WHERE	(BDR.DataRunID IN (SELECT t.DataRunID FROM PossibleDataRuns AS t));
		
		--2a) Determine average duration of batches in each status...
		WITH BatchAssignment AS
		(
			SELECT DISTINCT
					BB.BatchID
			FROM	Batch.[Batches] AS BB
			WHERE	(BB.BatchStatusID = @BatchStatusC) AND
					(BB.DataRunID IN (SELECT DISTINCT t.DataRunID FROM @DataRuns AS t))
		),
		BatchStatuses AS
		(
			SELECT	LBS.BatchID,
					LBS.BatchStatusID,
					LBS.LogDate,
					LBS.LogID,
					LBS.LogUser,
					BSP.StatusOrder
			FROM	Log.BatchStatuses AS LBS WITH (NOLOCK)
					INNER JOIN BatchAssignment AS BA
							ON LBS.BatchID = BA.BatchID
					INNER JOIN Batch.StatusPercentage AS BSP WITH (NOLOCK)
							ON LBS.BatchStatusID = BSP.BatchStatusID
			WHERE	(LBS.BatchStatusID > 0)
		),
		BatchStatusDuration AS
		(
			SELECT	BS1.BatchID,
					BS1.BatchStatusID,
					BS1.LogUser,
					BS1.LogDate AS StatusBeginDate,
					BS2.LogDate AS StatusEndDate,
					BS1.StatusOrder
			FROM	BatchStatuses AS BS1
					LEFT OUTER JOIN BatchStatuses AS BS2
							ON BS1.BatchID = BS2.BatchID AND
								BS1.StatusOrder = BS2.StatusOrder - 1
		)
		INSERT INTO @BatchStatusDuration
				(AvgDuration,
				BatchStatusID)
		SELECT	CONVERT(decimal(24, 6), ROUND(CONVERT(decimal(24, 6), ISNULL(AVG(CONVERT(decimal(24, 6), dbo.DiffMilliseconds(BSD.StatusBeginDate, BSD.StatusEndDate))), 0)) / 1000, 6)) AS AvgDuration,
				BSD.BatchStatusID
		FROM	BatchStatusDuration AS BSD
				INNER JOIN BatchAssignment AS BA
						ON BSD.BatchID = BA.BatchID
				INNER JOIN Batch.[Status] AS BS WITH (NOLOCK)
						ON BSD.BatchStatusID = BS.BatchStatusID AND
							BS.DoesWork = 1
		GROUP BY BSD.BatchStatusID, BSD.StatusOrder
		ORDER BY StatusOrder;

		--2b) Determine the percentage completion of a batch at each status (i.e. "Processed" status means the batch is 75-90% complete)...
		WITH TotalDuration AS
		(
			SELECT	SUM(CONVERT(decimal(24,6), AvgDuration)) AS TotAvgDuration
			FROM	@BatchStatusDuration
		)
		UPDATE BSD
		SET		StatusPercentage = ROUND(CONVERT(decimal(18,12), CONVERT(decimal(24,12), BSD.AvgDuration) / CONVERT(decimal(24,12), TD.TotAvgDuration)), 10)
		FROM	@BatchStatusDuration AS BSD,
				TotalDuration AS TD;

		--3) Populate the local BatchStatusDuration reference table with either the calculated avg durations (@BatchStatusDuration) or the template view (Batch.StatusPercentage)...
		IF EXISTS (SELECT TOP 1 1 FROM @BatchStatusDuration)
			INSERT INTO @BatchStatusPercentage
					(BatchStatusID,
					StatusPercentage)
			SELECT	BS.BatchStatusID,
					SUM(ISNULL(BSD.StatusPercentage, 0)) AS StatusPercentage
			FROM	Batch.[Status] AS BS
					LEFT OUTER JOIN @BatchStatusDuration AS BSD
							ON BSD.BatchStatusID BETWEEN 1 AND BS.BatchStatusID - 1
			GROUP BY BS.BatchStatusID
					
		ELSE
			INSERT INTO @BatchStatusPercentage
					(BatchStatusID,
					StatusPercentage)
			SELECT	BatchStatusID,
					StatusPercentage
			FROM	Batch.StatusPercentage;

		--4) Return run time and completion percentage...
		WITH RunTimeSummary AS
		(
			SELECT	MIN(LogDate) AS BeginDate, 
					MAX(LogDate) AS EndDate,
					dbo.GetTimeElapse(MIN(LogDate), MAX(LogDate)) AS RunTime
			FROM	Log.BatchStatuses 
			WHERE	(BatchID IN (SELECT DISTINCT BatchID FROM Batch.[Batches] WHERE DataRunID IN (SELECT DISTINCT t.DataRunID FROM @DataRuns AS t)))
		),
		CompletionSummary AS
		(
			SELECT	ROUND(CONVERT(decimal(18,12), SUM(BSP.StatusPercentage)) / CONVERT(decimal(18,12), COUNT(*)), 6) AS PercentOverall, 
					ROUND(CONVERT(decimal(18,12), SUM(CASE WHEN BB.BatchStatusID = @BatchStatusC THEN 1 ELSE 0 END)) / CONVERT(decimal(18,12), COUNT(*)), 6) AS PercentCompletedBatches  
			FROM	Batch.[Batches] AS BB WITH(NOLOCK) 
					INNER JOIN @BatchStatusPercentage AS BSP 
							ON BB.BatchStatusID = BSP.BatchStatusID 
			WHERE	(BB.DataRunID IN (SELECT DISTINCT t.DataRunID FROM @DataRuns AS t))
		),
		Combined AS
		(
			SELECT	RTS.BeginDate,
					RTS.EndDate,
					CASE WHEN CS.PercentOverall > 0 THEN DATEADD(second, dbo.FixIntOverflow(CONVERT(decimal(18,12), dbo.DiffSeconds(RTS.BeginDate, RTS.EndDate)) / CONVERT(decimal(18,12), CS.PercentOverall)), RTS.BeginDate) END AS EstEndDate,
					RTS.RunTime,
					CS.PercentCompletedBatches,
					CS.PercentOverall
			FROM	RunTimeSummary AS RTS,
					CompletionSummary AS CS
		)
		SELECT	t.RunTime AS ActualRunTime,
				t.BeginDate,
				t.EndDate,
				t.EstEndDate,
				dbo.GetTimeElapse(t.BeginDate, t.EstEndDate) AS EstRunTime,
				dbo.GetTimeElapse(t.BeginDate, DATEADD(second, dbo.FixIntOverflow(dbo.DiffSeconds(t.EndDate, t.BeginDate)), t.EstEndDate)) AS EstRemainTime,
				CONVERT(varchar(8), CONVERT(decimal(6,1), ROUND(t.PercentCompletedBatches * 100, 1))) + '%' AS PercentCompletedBatches,
				CONVERT(varchar(8), CONVERT(decimal(6,1), ROUND(t.PercentOverall * 100, 1))) + '%' AS PercentOverall
		FROM	Combined AS t
		WHERE	(t.BeginDate IS NOT NULL) OR
				(t.PercentOverall IS NOT NULL);

		--5) Return the number of batches in each status...
		SELECT	BB.BatchStatusID, 
				COUNT(*) AS CountBatches, 
				MIN(BatchID) AS MinBatchID, 
				MAX(BatchID) AS MaxBatchID, 
				MIN(BS.Descr) AS BatchStatus, 
				MIN(BS.Comments) AS Comments, 
				AVG(CountClaimLines) AS AvgCountClaimLines, 
				AVG(CountMembers) AS AvgCountMembers,
				SUM(CountClaimLines) AS SumCountClaimLines, 
				SUM(CountMembers) AS SumCountMembers 
		FROM	Batch.[Batches] AS BB WITH(NOLOCK) 
				INNER JOIN Batch.[Status] AS BS WITH(NOLOCK) 
						ON BB.BatchStatusID = BS.BatchStatusID 
		WHERE	(BB.DataRunID IN (SELECT DataRunID FROM @DataRuns)) 
		GROUP BY BB.BatchStatusID 
		ORDER BY BB.BatchStatusID;

		--6) Return the avg duration of each batch status, as used for calculating time estimates...
		SELECT  dbo.GetTimeElapse(0, DATEADD(millisecond, BSD.AvgDuration * 1000, 0)) AS AvgDuration,
				BSD.BatchStatusID,
				BSD.StatusPercentage,
				BS.Descr AS BatchStatus, 
				BS.Comments AS Comments
		FROM	@BatchStatusDuration AS BSD 
				INNER JOIN Batch.[Status] AS BS 
						ON BSD.BatchStatusID = BS.BatchStatusID
		WHERE	(1 IN (SELECT TOP 1 1 FROM @DataRuns));
								
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
GRANT EXECUTE ON  [Cloud].[GetDataRunCompletion] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetDataRunCompletion] TO [Submitter]
GO
