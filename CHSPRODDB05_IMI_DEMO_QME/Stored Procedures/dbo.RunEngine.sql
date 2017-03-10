SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 7/31/2012
-- Description:	Runs the engine locally.
-- =============================================
CREATE PROCEDURE [dbo].[RunEngine] 
(
	@BatchSize int = 2147483647,			--DEFAULT: 1 large batch
	--@BeginInitSeedDate datetime = NULL	--DEFAULT: Use extrapolated date from @SeedDate
	@CalculateMbrMonths bit = 1,			--DEFAULT: Yes, calculate member months
	@CalculateXml bit = 1,					--DEFAULT: Yes, calculate event/entity XML info
	@DataSetID int = NULL,					--DEFAULT: New data set	 
	@DefaultIhdsProviderId int = NULL,		--DEFAULT: Automatically selects a default provider
	--@EndInitSeedDate datetime = NULL,		--DEFAULT: Use extrapolated date from @SeedDate
	@FileFormatID int = NULL,				--DEFAULT: None specified, will error on @RunRemoteTest = 1, if not set
	@HedisMeasureID varchar(10) = NULL,		--DEFAULT: No filtering for test decks (only use for NCQA Certification)
	@MeasureID int = NULL,					--DEFAULT: All measures
	@MeasureSetID int,					
	@OwnerID int,
	@ReturnFileFormatID int = NULL,			--DEFAULT: None specified, will error on @RunRemoteTest = 1, if not set
	@RunRemoteTest bit = 0,					--DEFAULT: No, do not simulate a remote processing test internally
	@SeedDate datetime,
	@ShowDataRunInfo bit = 1,				--DEFAULT: Yes, show the data set and data run records when entire process completes
	@ShowProcessLog bit = 1,				--DEFAULT: Yes, show the process log when entire process completes
	@ShowResultsSummary bit = 1,			--DEFAULT: Yes, show results summary when entire process completes
	@SummarizeResults bit = 1,				--DEFAULT, Yes, summarize resutls upon completion
	@TargetDatabase nvarchar(128) = NULL,	--DEFAULT: Leave "target" database as is
	@Top int = 0							--DEFAULT: Return no sample rows
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataRunID int; 
	DECLARE @Result int;
      
	IF @TargetDatabase IS NOT NULL
		EXEC @Result = Import.SetSourceDatabase @DatabaseName = @TargetDatabase;
		
	IF ISNULL(@Result, 0) = 0
		EXEC @Result = dbo.SetDbRecoveryOption @RecoveryModel = N'BULK_LOGGED';

	IF ISNULL(@Result, 0) = 0 AND @DefaultIhdsProviderId IS NULL
		SELECT TOP 1 
				@DefaultIhdsProviderId = ihds_prov_id 
		FROM	dbo.Provider 
		WHERE	((CustomerProviderID = 'UNK001') OR (TaxID = 'UNK001')) AND 
				((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID));

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Batch.PurgeInternalTables @BatchID = NULL, @ForcePurge = 1, @IgnoreMembers = 0;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = dbo.RebuildIndexes @TableSchema = N'Measure';

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = dbo.RefreshStatistics @TableSchema = N'Measure';	

	IF ISNULL(@Result, 0) = 0 AND @DataSetID IS NULL
		EXEC @Result = Batch.ImportDataSet @DataSetID = @DataSetID OUTPUT, @DefaultIhdsProviderId = @DefaultIhdsProviderId, @HedisMeasureID = @HedisMeasureID, @OwnerID = @OwnerID, @Top = @Top;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Batch.CreateDataSetBatches @BatchSize = @BatchSize, @CalculateMbrMonths = @CalculateMbrMonths, @CalculateXml = @CalculateXml, @DataRunID = @DataRunID OUTPUT, @DataSetID = @DataSetID, @IsReady = 0, @MeasureID = @MeasureID, @MeasureSetID = @MeasureSetID, @SeedDate = @SeedDate;

	IF ISNULL(@Result, 0) = 0
		UPDATE Batch.DataRuns SET IsConfirmed = 1, IsReady = 1, IsSubmitted = 1 WHERE DataRunID = @DataRunID;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Measure.RefreshXrefs @DataRunID = @DataRunID;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Measure.RankEventOptions @DataRunID = @DataRunID;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Measure.RankEntityOptions @DataRunID = @DataRunID;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = Measure.ApplyEntityIterations @DataRunID = @DataRunID;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = dbo.RebuildIndexes;

	IF ISNULL(@Result, 0) = 0
		EXEC @Result = dbo.RefreshStatistics;

	IF @RunRemoteTest = 0
		BEGIN;
			IF ISNULL(@Result, 0) = 0
				EXEC @Result = Batch.RunDataSetProcedures @DataRunID = @DataRunID;
		END;
	ELSE
		BEGIN;
			IF ISNULL(@Result, 0 ) = 0
				EXEC @Result = Cloud.SendBatchFileXML 
											@DataRunID = @DataRunID,
											@FileFormatID = @FileFormatID, 
											@PrintSql = 0,
											@ReturnFileFormatID = @ReturnFileFormatID;
		END;
		

	IF ISNULL(@Result, 0) = 0 AND @SummarizeResults = 1
		BEGIN;
			EXEC @Result = Result.SummarizeAll @DataRunID = @DataRunID;
			
			IF ISNULL(@Result, 0) = 0
				EXEC @Result = Result.CompileMeasureEventDetail @DataRunID = @DataRunID;
		END;

	EXEC @Result = dbo.SetDbRecoveryOption @RecoveryModel = N'SIMPLE';

	DECLARE @CountErrors bigint;
	DECLARE @CountFailures bigint;

	SELECT @CountErrors = COUNT(*) FROM [Log].ProcessErrors WHERE DataSetID = @DataSetID AND (DataRunID IS NULL OR DataRunID = @DataRunID);
	SELECT @CountFailures = COUNT(*) FROM [Log].ProcessEntries WHERE (IsSuccess = 0  OR Descr LIKE '%fail%') AND DataSetID = @DataSetID AND (DataRunID IS NULL OR DataRunID = @DataRunID);
	SELECT @CountErrors AS CountErrors, @CountFailures AS CountFailures;

	IF ISNULL(@CountErrors, 0) <> 0
		SELECT 'ERRORS' AS [TableName], * FROM [Log].ProcessErrors WHERE ((DataRunID = @DataRunID) OR (DataSetID = @DataSetID));

	IF ISNULL(@CountFailures, 0) <> 0
		SELECT 'FAILURES' AS [TableName], * FROM [Log].ProcessEntries WHERE (((DataRunID = @DataRunID) OR (DataSetID = @DataSetID)) AND ((IsSuccess = 0)  OR (Descr LIKE '%fail%')));

	IF @ShowResultsSummary = 1
		BEGIN;
			SELECT	RMD.MeasureID, M.Abbrev AS Measure, 
					MX.Descr AS Metric,
					COUNT(DISTINCT RMD.DSMemberID) AS CountMembers,
					COUNT(*) AS CountRecords, 
					SUM(CAST(RMD.IsDenominator AS int)) AS Denominator, 
					SUM(CAST(RMD.IsNumerator  AS int)) AS Numerator,
					SUM(CAST(RMD.IsExclusion  AS int)) AS Exclusion,
					SUM(CAST(RMD.IsIndicator  AS int)) AS Indicator
			FROM	[Result].[MeasureDetail] AS RMD 
					INNER JOIN Measure.Measures AS M 
							ON RMD.MeasureID = M.MeasureID 
					INNER JOIN Measure.Metrics AS MX
							ON RMD.MetricID = MX.MetricID
			WHERE	(DataRunID = @DataRunID) 
			GROUP BY RMD.MeasureID, M.Abbrev, MX.Descr, MX.Abbrev
			ORDER BY MX.Abbrev;
		END;
		
	IF @ShowDataRunInfo = 1
		BEGIN;
			SELECT * FROM Batch.DataSets WHERE DataSetID = @DataSetID;
			SELECT * FROM Batch.DataRuns WHERE DataRunID = @DataRunID;
		END;
		
	IF @ShowProcessLog = 1
		SELECT * FROM [Log].ProcessEntries WHERE DataSetID = @DataSetID; 
    
END

GO
GRANT VIEW DEFINITION ON  [dbo].[RunEngine] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[RunEngine] TO [db_executer]
GO
GRANT EXECUTE ON  [dbo].[RunEngine] TO [Processor]
GO
