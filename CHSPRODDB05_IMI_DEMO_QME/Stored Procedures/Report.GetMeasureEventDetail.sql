SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/10/2012
-- Description:	Retrieves the top-level measure/metric based summary report.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureEventDetail]
(
	@AuditBeginDate datetime = NULL,
	@AuditEndDate datetime = NULL,
	@AuditHybridOnly bit = 1,
	@AuditPercent decimal(18,10) = NULL,
	@AuditReviewerID int = NULL,
	@CustomerMemberID varchar(32) = NULL,
	@DataRunID int,
	@DSMemberID bigint = NULL,
	@MeasureID int = NULL,
	@MetricID int = NULL,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	SET @CustomerMemberID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerMemberID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');

	IF NULLIF(@CustomerMemberID, '%') IS NULL AND @DSMemberID IS NULL
		SET @DSMemberID = -1; --Keeps the report from returning all rows if no member is specified.

	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @Result int;
	
	BEGIN TRY;
	
		IF @UserName IS NULL
			SET @UserName = SUSER_SNAME();
		
		SET @LogBeginTime = GETDATE();
		SET @LogObjectName = 'GetMeasureEventDetail'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
	
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@AuditBeginDate', @AuditBeginDate);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@AuditEndDate', @AuditEndDate);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@AuditPercent', @AuditPercent);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@AuditReviewerID', @AuditReviewerID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DSMemberID', @DSMemberID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		
		---------------------------------------------------------------------------
		
		DECLARE @IsAudit bit;
		SET @IsAudit = CASE WHEN @AuditPercent IS NOT NULL AND @AuditPercent BETWEEN 0 AND 1 THEN 1 ELSE 0 END;
				
		CREATE TABLE #AuditRows
		(
			ResultRowID bigint NOT NULL,
			ReviewerDisplayName varchar(64) NULL,
			ReviewerFirstName varchar(32) NULL,
			ReviewerID int NOT NULL,
			ReviewerLastName varchar(32) NULL
		);
		
		IF @IsAudit = 1 
			BEGIN;
				INSERT INTO #AuditRows (ResultRowID, ReviewerID)
				EXEC Report.GetMeasureEventAuditList @BeginDate = @AuditBeginDate, @DataRunID = @DataRunID, @EndDate = @AuditEndDate, @Percent = @AuditPercent, @UserName = @UserName;
				
				IF @AuditReviewerID IS NOT NULL
					DELETE FROM #AuditRows WHERE ReviewerID <> @AuditReviewerID;
				
				UPDATE	AL
				SET		ReviewerDisplayName = RDSRK.DisplayName,
						ReviewerFirstName = RDSRK.FirstName,
						ReviewerLastName = RDSRK.LastName
				FROM	#AuditRows AS AL
						INNER JOIN Result.DataSetReviewerKey AS RDSRK 
								ON AL.ReviewerID = RDSRK.ReviewerID 
				WHERE	(RDSRK.DataRunID = @DataRunID);
				
				CREATE UNIQUE CLUSTERED INDEX IX_#AuditRows ON #AuditRows (ResultRowID, ReviewerID);
			END;
		--ELSE IF @MeasureID IS NULL
		--	SET @MeasureID = -1;
		
		WITH Metrics AS
		(
			SELECT DISTINCT
					MeasureAbbrev,
					MeasureDescr,
					MeasureID,
					MetricAbbrev,
					MetricDescr,
					MetricID
			FROM	Result.DataSetMetricKey WITH(NOLOCK)
			WHERE	(DataRunID = @DataRunID) AND
					((@MeasureID IS NULL) OR (MeasureID = @MeasureID)) AND
					((@MetricID IS NULL) OR (MetricID = @MetricID))
		)
		SELECT DISTINCT
				RMVD.BatchID,
				RMVD.BeginDate,
				RMVD.ClaimNum,
				RMVD.ClaimTypeID,
				RMVD.Code,
				RMVD.CodeID,
				RMVD.CodeType,
				RDSMK.CustomerMemberID,
				RMVD.DataRunID,
				RMVD.DataSetID,
				RMVD.Descr,
				RMVD.DescrHtml,
				RMVD.DSEntityID,
				RMVD.DSEventID,
				RMVD.DSMemberID,
				RMVD.EndDate,
				RMVD.EntityDescr,
				RMVD.EntityID,
				RMVD.EventBaseID,
				ISNULL(RMVD.EventDescr, '(n/a)') AS EventDescr,
				RMVD.EventID,
				RDSMK.Gender,
				@IsAudit AS IsAudit,
				RMVD.Iteration,
				RMVD.KeyDate,
				RMVD.MapTypeID,
				MX.MeasureAbbrev,
				MX.MeasureDescr,
				RMVD.MeasureID,
				RDSMK.DisplayID AS MemberDisplayID,
				RDSMK.DOB AS MemberDOB,
				RDSMK.NameDisplay AS MemberNameDisplay,
				RDSMK.NameObscure AS MemberNameObscure,
				RDSMK.SsnDisplay AS MemberSsnDisplay,
				RDSMK.SsnObscure AS MemberSsnObscure,
				MX.MetricAbbrev,
				MX.MetricDescr,
				RMVD.MetricID,
				RMVD.ResultRowID,
				AL.ReviewerDisplayName,
				AL.ReviewerFirstName,
				AL.ReviewerID,
				AL.ReviewerLastName,
				RMVD.ServDate        
		FROM	Result.MeasureEventDetail AS RMVD WITH(NOLOCK)
				INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
						ON RMVD.DataRunID = RDSMK.DataRunID AND
							RMVD.DataSetID = RDSMK.DataSetID AND
							RMVD.DSMemberID = RDSMK.DSMemberID
				INNER JOIN Metrics AS MX
						ON RMVD.MetricID = MX.MetricID
				LEFT OUTER JOIN #AuditRows AS AL
						ON RMVD.ResultRowID = AL.ResultRowID
		WHERE	(RMVD.DataRunID = @DataRunID) AND
				((@IsAudit = 0) OR (AL.ResultRowID IS NOT NULL)) AND
				((@IsAudit = 0) OR (@AuditHybridOnly = 0) OR (RMVD.ResultTypeID IN (2,3))) AND
				((@CustomerMemberID IS NULL) OR (RDSMK.CustomerMemberID = @CustomerMemberID) OR (RDSMK.CustomerMemberID LIKE @CustomerMemberID)) AND
				((@DSMemberID IS NULL) OR (RMVD.DSMemberID = @DSMemberID)) AND
				((@MeasureID IS NULL) OR (RMVD.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RMVD.MetricID = @MetricID))
		ORDER BY AL.ReviewerDisplayName,
				RDSMK.NameDisplay,
				RMVD.DSMemberID,
				RMVD.MeasureID,
				RMVD.KeyDate,
				RMVD.MapTypeID,
				RMVD.MetricID,
				RMVD.ServDate,
				RMVD.Iteration,
				RMVD.CodeType,
				RMVD.Code,
				RMVD.ClaimNum;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetMeasureEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureEventDetail] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureEventDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureEventDetail] TO [Reports]
GO
