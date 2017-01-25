SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/13/2011
-- Description:	Returns the percentage of progress made in processing the specified batch.
-- =============================================
CREATE PROCEDURE [Cloud].[GetBatchProgress]
(
	@BatchGuid uniqueidentifier = NULL,
	@BatchID int = NULL,
	@OwnerGuid uniqueidentifier = NULL,
	@PercentCompleted decimal(18,6) = NULL OUTPUT,
	@SelectResults bit = 1 
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @BatchStatusID smallint;
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
		
		SELECT	@BatchStatusID = B.BatchStatusID,
				@BeginInitSeedDate = DR.BeginInitSeedDate,
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
				
		----------------------------------------------------------------------------------------------		
		
		DECLARE @DateCompTypeE tinyint; --Entity
		DECLARE @DateCompTypeN tinyint; --Enrollment
		DECLARE @DateCompTypeS tinyint; --Seed Date
		DECLARE @DateCompTypeV tinyint; --Event

		SELECT @DateCompTypeE = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'E';
		SELECT @DateCompTypeN = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'N';
		SELECT @DateCompTypeS = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'S';
		SELECT @DateCompTypeV = DateCompTypeID FROM Measure.DateComparerTypes WHERE Abbrev = 'V';
		
		----------------------------------------------------------------------------------------------
		
		DECLARE @BatchStatusC smallint;
		DECLARE @BatchStatusX smallint;
		SET @BatchStatusC = Batch.ConvertBatchStatusIDFromAbbrev('C');
		SET @BatchStatusX = Batch.ConvertBatchStatusIDFromAbbrev('X');
		
		DECLARE @CountActual bigint;
		DECLARE @CountExpected bigint; 
		
		IF @BatchStatusID BETWEEN 0 AND @BatchStatusC - 2
			BEGIN
			
				WITH MaxIteration AS
				(
					SELECT	MAX(Iteration) AS Iteration
					FROM	Measure.Entities
					WHERE	(IsEnabled = 1) AND
							(MeasureSetID = @MeasureSetID)
				),
				Iterations AS
				(
					SELECT	T.N AS Iteration
					FROM	dbo.Tally AS T
							INNER JOIN MaxIteration AS MI
									ON T.N <= MI.Iteration 
				),
				CustomProcessesCount AS
				(
					SELECT	COUNT(DISTINCT CP.MeasProcID) AS CountRecords
					FROM	Measure.CustomProcesses AS CP
							INNER JOIN Measure.Measures AS M
									ON CP.MeasureID = M.MeasureID
					WHERE	(M.MeasureSetID = @MeasureSetID)
				),
				DataSetProceduresCount AS
				(
					SELECT	COUNT(DISTINCT P.ProcID) AS CountRecords
					FROM	[Batch].[Procedures] AS P
							INNER JOIN Batch.DataSetProcedures AS DSP
									ON P.ProcID = DSP.ProcID AND
										DSP.IsEnabled = 1
							LEFT OUTER JOIN Measure.CustomProcesses AS MCP
									ON P.ProcName = MCP.ProcName AND
										P.ProcSchema = MCP.ProcSchema
					WHERE	(DSP.DataSetID = 1) AND
							(MCP.MeasProcID IS NULL) AND
							(
								(P.ProcSchema NOT IN ('Batch', '[Batch]')) OR
								(
									(P.ProcSchema IN ('Batch', '[Batch]')) AND 
									(P.ProcName NOT LIKE 'RunCustomProcesses%') AND 
									(P.ProcName NOT LIKE '[RunCustomProcesses%')
								)
							)
				),
				EntityTypesCount AS
				(
					SELECT	COUNT(*) AS CountRecords
					FROM	Measure.EntityTypes
				),
				DateComparersCount AS
				(
				SELECT	COUNT(*) AS CountRecords
				FROM	Measure.DateComparers AS DC
						INNER JOIN Iterations AS I
								ON DC.ProcName IS NOT NULL AND
									DC.ProcSchema IS NOT NULL AND
									(
										(DC.DateCompTypeID IN (@DateCompTypeS, @DateCompTypeV, @DateCompTypeN)) OR 
										(
											(DC.DateCompTypeID IN (@DateCompTypeE)) AND 
											(I.Iteration > 1)
										)
									)
									
				)
				SELECT	@CountExpected = 
							--Count of custom measure procedures to run
							(SELECT TOP 1 CountRecords FROM CustomProcessesCount) + 
							
							--Count of data set procedures to run
							(SELECT TOP 1 CountRecords FROM DataSetProceduresCount) + 
							
							--Count of Date Comparer procedures to run (includes Enrollment)
							(SELECT TOP 1 CountRecords FROM DateComparersCount) + 
							
							--Count of iteration-specific procedures to run (see Batch.ProcessEntities)
							((SELECT TOP 1 Iteration FROM MaxIteration) * 2) + 
							
							--Count of entity-compiling procedures to run
							((SELECT TOP 1 Iteration FROM MaxIteration) * (SELECT TOP 1 CountRecords FROM EntityTypesCount)) +
							
							--Count of log entries made automatically when running a remote batch (see Cloud.ProcessBatchFileXML)	
							5;
				
				SELECT	@CountActual = COUNT(*) FROM [Log].ProcessEntries WHERE (BatchID = @BatchID) OR (DataRunID = @DataRunID);
									
				
				SELECT	@PercentCompleted =
							(			
								CAST(CASE WHEN @CountActual > @CountExpected THEN @CountExpected ELSE @CountActual END AS decimal(18,6)) + 
								CAST(ISNULL((SELECT COUNT(*) FROM Batch.[Batches] WHERE ((BatchID = @BatchID) AND (BatchStatusID = @BatchStatusC))), 0) AS decimal(18,6))
							) /
							(
								CAST(@CountExpected AS decimal(18,6)) + 
								1
							);		
			END;
		ELSE IF (@BatchStatusID = @BatchStatusX)
			SET @PercentCompleted = 0;
		ELSE IF (@BatchStatusID = @BatchStatusC)
			SET @PercentCompleted = 1;
		
		IF @SelectResults = 1
			SELECT	@PercentCompleted AS [Percent];
								
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
GRANT EXECUTE ON  [Cloud].[GetBatchProgress] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetBatchProgress] TO [Submitter]
GO
