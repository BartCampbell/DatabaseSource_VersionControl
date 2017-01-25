SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/11/2012
-- Description:	Retrieves list of measure event result rows and corrsponding reviewers for auditing.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureEventAuditList]
(
	@BeginDate datetime = NULL,
	@DataRunID int,
	@EndDate datetime = NULL,
	@Percent decimal(18,10) = 0.1,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;
	
	BEGIN TRY;
	
		IF @UserName IS NULL
			SET @USerName = SUSER_SNAME();
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'GetMeasureEventAuditList'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES ('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@BeginDate', @BeginDate);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@EndDate', @EndDate);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@Percent', @Percent);	
		
		IF @EndDate IS NULL
			SET @EndDate = DATEADD(dd, DATEDIFF(dd, 1, GETDATE()), 0);

		IF @BeginDate IS NULL
			SET @BeginDate = DATEADD(dd, -7, @EndDate);

		IF OBJECT_ID('tempdb..#AuditDetail') IS NOT NULL
			DROP TABLE #AuditDetail;

		WITH AuditSource AS
		(
			SELECT DISTINCT
					DataRunID,
					DataSetID,
					DSMemberID,
					KeyDate,
					MeasureID,
					ReviewerID
			FROM	Result.MeasureEventDetail AS RMVD WITH(NOLOCK)
			WHERE	(RMVD.DataRunID = @DataRunID) AND
					(RMVD.ReviewDate BETWEEN @BeginDate AND @EndDate) AND 
					(RMVD.ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE Abbrev IN ('H','M')))
		)
		SELECT	DataRunID,
				DataSetID,
				DSMemberID,
				KeyDate,
				MeasureID,
				ReviewerID,
				ROW_NUMBER() OVER (PARTITION BY ReviewerID, MeasureID ORDER BY DSMemberID, KeyDate) AS RowID
		INTO	#AuditDetail
		FROM	AuditSource
		ORDER BY RowID;

		CREATE UNIQUE CLUSTERED INDEX IX_#AuditDetail ON #AuditDetail (ReviewerID, MeasureID, RowID);

		IF OBJECT_ID('tempdb..#AuditSample') IS NOT NULL
			DROP TABLE #AuditSample;

		SELECT	CONVERT(decimal(18,10), MIN(RDSK.AuditRand)) AS AuditRand,
				CONVERT(decimal(18,10), COUNT(*)) / CONVERT(decimal(18,10), CEILING(COUNT(*) * @Percent)) AS AuditRatio,
				CONVERT(decimal(18,10), CEILING(COUNT(*) * @Percent)) AS CountPercent,
				CONVERT(decimal(18,10), COUNT(*)) AS CountPursuits, 
				RMVD.MeasureID,
				RDSRK.ReviewerID,
				IDENTITY(int, 1, 1) AS RowID
		INTO	#AuditSample
		FROM	#AuditDetail AS RMVD
				INNER JOIN Result.DataSetReviewerKey AS RDSRK WITH(NOLOCK)
						ON RMVD.DataRunID = RDSRK.DataRunID AND
							RMVD.DataSetID = RDSRK.DataSetID AND
							RMVD.ReviewerID = RDSRK.ReviewerID
				INNER JOIN Result.DataSetRunKey AS RDSK WITH(NOLOCK)
						ON RDSRK.DataRunID = RDSK.DataRunID AND
							RDSRK.DataSetID = RDSK.DataSetID
		GROUP BY RDSRK.DisplayName, 
				RMVD.MeasureID, 
				RDSRK.ReviewerID
		ORDER BY ReviewerID, MeasureID;

		CREATE UNIQUE CLUSTERED INDEX IX_#AuditSample ON #AuditSample (RowID);

		IF OBJECT_ID('tempdb..#AuditList') IS NOT NULL
			DROP TABLE #AuditList;

		WITH AuditInfo AS
		(
			SELECT	AuditRatio,
					CountPercent AS AuditSize,
					ISNULL(NULLIF(ROUND(AuditRand * AuditRatio, 0), 0), 1) AS AuditStart,
					RowID
			FROM	#AuditSample
		),
		AuditSelection AS
		(
			SELECT	t.N AS AuditOrder,
					CONVERT(int, AI.AuditStart + ROUND((t.N - 1) * AI.AuditRatio, 0)) AS AuditRowID,
					RowID
			FROM	AuditInfo AS AI
					INNER JOIN dbo.Tally AS t
							ON t.N BETWEEN 1 AND AI.AuditSize
		)
		SELECT	D.DataRunID,
				D.DataSetID,
				D.DSMemberID,
				D.KeyDate,
				D.MeasureID,
				D.ReviewerID
		INTO	#AuditList
		FROM	#AuditSample AS S
				INNER JOIN AuditSelection AS SL
						ON S.RowID = SL.RowID
				INNER JOIN #AuditDetail AS D
						ON S.MeasureID = D.MeasureID AND
							S.ReviewerID = D.ReviewerID AND
							SL.AuditRowID = D.RowID
		ORDER BY ReviewerID, 
				MeasureID, 
				AuditRowID;

		CREATE UNIQUE CLUSTERED INDEX IX_#AuditList ON #AuditList (DSMemberID, MeasureID, KeyDate, ReviewerID);

		SELECT DISTINCT
				RMVD.ResultRowID, D.ReviewerID
		FROM	#AuditList AS D
				INNER JOIN Result.MeasureEventDetail AS RMVD WITH(NOLOCK)
						ON D.DataRunID = RMVD.DataRunID AND
							D.DataSetID = RMVD.DataSetID AND
							D.DSMemberID = RMVD.DSMemberID AND
							D.KeyDate = RMVD.KeyDate AND
							D.MeasureID = RMVD.MeasureID;

		SET @CountRecords = ISNULL(@CountRecords, 0) + @@ROWCOUNT;
		SET @LogEndTime = GETDATE();

		EXEC @Result = [Log].RecordReportUsage	@BeginTime = @LogBeginTime,
												@CountRecords = @CountRecords,
												@EndTime = @LogEndTime, 
												@Parameters = @Parameters,
												@SrcObjectName = @LogObjectName,
												@SrcObjectSchema = @LogObjectSchema,
												@UserName = @UserName;

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
GRANT EXECUTE ON  [Report].[GetMeasureEventAuditList] TO [Processor]
GO
