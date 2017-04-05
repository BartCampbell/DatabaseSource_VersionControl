SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/20/2011
-- Description:	Retrieves the results for the measure by age band graph.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureByAgeBandGraph]
(
	@DataRunID int,
	@MetricID int,
	@OverrideKeyFieldID tinyint = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@ResultTypeID tinyint = NULL,
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
		SET @LogObjectName = 'GetMeasureByAgeBandGraph'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
	
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ResultTypeID', @ResultTypeID);
		
		--DETERMINES THE DEFAULT RESULT TYPE FOR EACH MEASURE--------------------------
		SELECT	MeasureID,
				MAX(ResultTypeID) AS ResultTypeID
		INTO	#MeasureDefaultResultType
		FROM	Result.MeasureSummary WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID)
		GROUP BY MeasureID;
		
		CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDefaultResultType ON #MeasureDefaultResultType (MeasureID);
		
		
		--OVERRIDE KEY FIELD IF NECESSARY----------------------------------------------
		DECLARE @KeyFieldDescr varchar(64);
		DECLARE @KeyFieldID tinyint;
		DECLARE @KeyFieldName varchar(32);
		DECLARE @KeyFieldNumberFormat varchar(16);
		
		IF @OverrideKeyFieldID IS NOT NULL
			BEGIN
		
				SELECT	@KeyFieldDescr = ISNULL(RMF.Descr, RF.Descr),
						@KeyFieldID = RF.FieldID,
						@KeyFieldName = RF.FieldName,
						@KeyFieldNumberFormat = RF.NumberFormat
				FROM	Report.Fields AS RF WITH(NOLOCK)
						LEFT OUTER JOIN Report.MeasureFields AS RMF WITH(NOLOCK)
								ON RF.FieldID = RMF.FieldID AND
									(RMF.MeasureID IN (SELECT DISTINCT MeasureID FROM Result.DataSetMetricKey WHERE (DataRunID = @DataRunID) AND (MetricID = @MetricID))) 
				WHERE	(RF.FieldID = @OverrideKeyFieldID)
			END
			
		--COPIES THE MEASURE KEYS INTO A TEMP TABLE FOR BETTER PERFORMANCE-------------
		SELECT	RMFK.*,
				ISNULL(@KeyFieldDescr, RMTK.KeyFieldDescr) AS KeyFieldDescr,
				ISNULL(@KeyFieldID, RMTK.KeyFieldID) AS KeyFieldID,
				ISNULL(@KeyFieldName, RMTK.KeyFieldName) AS KeyFieldName,
				ISNULL(@KeyFieldNumberFormat, RMTK.KeyFieldNumberFormat) AS KeyFieldNumberFormat,
				ISNULL(t.ResultTypeID, 255) AS ResultTypeID,
				RMTK.ShowHeadersEachMetric,
				RMTK.ShowOnReport
		INTO	#ReportMeasureFieldKey
		FROM	Report.MeasureFieldKey AS RMFK WITH(NOLOCK)
				LEFT OUTER JOIN Report.MeasureSettingsKey AS RMTK WITH(NOLOCK)
						ON RMFK.MeasureID = RMTK.MeasureID
				LEFT OUTER JOIN #MeasureDefaultResultType AS t
						ON RMTK.MeasureID = t.MeasureID
		WHERE	RMFK.ReportType = 'Summary';
		
		CREATE UNIQUE CLUSTERED INDEX IX_#ReportMeasureFieldKey ON #ReportMeasureFieldKey (MeasureID);

		--THE RETURNED RESULTSET------------------------------------------
		--SELECT	Gender,
		--		MAX(AgeBandSegID) AS MaxAgeBandSegID,
		--		MIN(AgeBandSegID) AS MinAgeBandSegID
		--INTO	#GenderRanges
		--FROM	Result.MeasureAgeBandSummary AS RMABS
		--WHERE	(DataRunID = @DataRunID) AND
		--		(MetricID = @MetricID) AND
		--		((CountMonths > 0) OR (CountRecords > 0)) AND
		--		((@PopulationID IS NULL) OR (PopulationID = @PopulationID)) AND
		--		((@ProductLineID IS NULL) OR (ProductLineID = @ProductLineID))
		--GROUP BY Gender
		
		SELECT	RDSMABK.AgeBandSegDescr,
				RDSMABK.AgeBandSegID,
				RDSMABK.BenefitDescr,
				RDSMABK.BenefitID,
				SUM(ISNULL(RMABS.CountEvents, 0)) AS CountEvents,
				SUM(ISNULL(RMABS.CountMembers, 0)) AS CountMembers,
				SUM(ISNULL(RMABS.CountMonths, 0 )) AS CountMonths,
				SUM(ISNULL(RMABS.CountRecords, 0)) AS CountRecords,
				RDSMABK.DataRunID,
				RDSMABK.DataSetID,
				SUM(ISNULL(RMABS.[Days], 0)) AS [Days],
				MIN(RMFK.FieldDescr01) AS FieldDescr01,
				MIN(RMFK.FieldDescr02) AS FieldDescr02,
				MIN(RMFK.FieldDescr03) AS FieldDescr03,
				MIN(RMFK.FieldDescr04) AS FieldDescr04,
				MIN(RMFK.FieldDescr05) AS FieldDescr05,
				MIN(RMFK.FieldDescr06) AS FieldDescr06,
				MIN(RMFK.FieldDescr07) AS FieldDescr07,
				MIN(RMFK.FieldDescr08) AS FieldDescr08,
				MIN(RMFK.FieldDescr09) AS FieldDescr09,
				MIN(RMFK.FieldDescr10) AS FieldDescr10,
				MIN(RMFK.FieldDescr11) AS FieldDescr11,
				MIN(RMFK.FieldDescr12) AS FieldDescr12,
				MIN(RMFK.FieldID01) AS FieldID01,
				MIN(RMFK.FieldID02) AS FieldID02,
				MIN(RMFK.FieldID03) AS FieldID03,
				MIN(RMFK.FieldID04) AS FieldID04,
				MIN(RMFK.FieldID05) AS FieldID05,
				MIN(RMFK.FieldID06) AS FieldID06,
				MIN(RMFK.FieldID07) AS FieldID07,
				MIN(RMFK.FieldID08) AS FieldID08,
				MIN(RMFK.FieldID09) AS FieldID09,
				MIN(RMFK.FieldID10) AS FieldID10,
				MIN(RMFK.FieldID11) AS FieldID11,
				MIN(RMFK.FieldID12) AS FieldID12,
				MIN(RMFK.FieldName01) AS FieldName01,
				MIN(RMFK.FieldName02) AS FieldName02,
				MIN(RMFK.FieldName03) AS FieldName03,
				MIN(RMFK.FieldName04) AS FieldName04,
				MIN(RMFK.FieldName05) AS FieldName05,
				MIN(RMFK.FieldName06) AS FieldName06,
				MIN(RMFK.FieldName07) AS FieldName07,
				MIN(RMFK.FieldName08) AS FieldName08,
				MIN(RMFK.FieldName09) AS FieldName09,
				MIN(RMFK.FieldName10) AS FieldName10,
				MIN(RMFK.FieldName11) AS FieldName11,
				MIN(RMFK.FieldName12) AS FieldName12,
				MIN(RMFK.FieldNumberFormat01) AS FieldNumberFormat01,
				MIN(RMFK.FieldNumberFormat02) AS FieldNumberFormat02,
				MIN(RMFK.FieldNumberFormat03) AS FieldNumberFormat03,
				MIN(RMFK.FieldNumberFormat04) AS FieldNumberFormat04,
				MIN(RMFK.FieldNumberFormat05) AS FieldNumberFormat05,
				MIN(RMFK.FieldNumberFormat06) AS FieldNumberFormat06,
				MIN(RMFK.FieldNumberFormat07) AS FieldNumberFormat07,
				MIN(RMFK.FieldNumberFormat08) AS FieldNumberFormat08,
				MIN(RMFK.FieldNumberFormat09) AS FieldNumberFormat09,
				MIN(RMFK.FieldNumberFormat10) AS FieldNumberFormat10,
				MIN(RMFK.FieldNumberFormat11) AS FieldNumberFormat11,
				MIN(RMFK.FieldNumberFormat12) AS FieldNumberFormat12,
				RDSMABK.Gender,
				SUM(ISNULL(RMABS.IsDenominator, 0)) AS IsDenominator,
				SUM(ISNULL(RMABS.IsExclusion, 0)) AS IsExclusion,
				SUM(ISNULL(RMABS.IsIndicator, 0)) AS IsIndicator,
				SUM(ISNULL(RMABS.IsNegative, 0)) AS IsNegative,
				SUM(ISNULL(RMABS.IsNumerator, 0)) AS IsNumerator,
				SUM(ISNULL(RMABS.IsNumeratorAdmin, 0)) AS IsNumeratorAdmin,
				SUM(ISNULL(RMABS.IsNumeratorMedRcd, 0)) AS IsNumeratorMedRcd,
				MIN(RMFK.KeyFieldDescr) AS KeyFieldDescr,
				MIN(RMFK.KeyFieldID) AS KeyFieldID,
				MIN(RMFK.KeyFieldName) AS KeyFieldName,
				MIN(RMFK.KeyFieldNumberFormat) AS KeyFieldNumberFormat,
				RDSMABK.MeasureAbbrev,
				RDSMABK.MeasureID,
				RDSMABK.MetricDescr,
				RDSMABK.MetricID,
				RDSMABK.PopulationID,
				RDSMABK.ProductLineID,
				SUM(ISNULL(RMABS.Qty, 0)) AS Qty,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMABS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(COALESCE(RMABS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID)) AS ResultTypeID
		FROM	Result.DataSetMetricAgeBandKey AS RDSMABK WITH(NOLOCK)
				--INNER JOIN #GenderRanges AS GR
				--		ON ((RDSMABK.Gender = GR.Gender) OR ((RDSMABK.Gender IS NULL) AND (GR.Gender IS NULL))) AND
				--			RDSMABK.AgeBandSegID BETWEEN GR.MinAgeBandSegID AND GR.MaxAgeBandSegID 
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMABK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				LEFT OUTER JOIN Result.MeasureAgeBandSummary AS RMABS WITH(NOLOCK)
						ON RDSMABK.AgeBandSegID = RMABS.AgeBandSegID AND
							RDSMABK.BenefitID = RMABS.BenefitID AND
							RDSMABK.DataRunID = RMABS.DataRunID AND
							RDSMABK.DataSetID = RMABS.DataSetID AND
							RDSMABK.MeasureID = RMABS.MeasureID AND
							RDSMABK.MetricID = RMABS.MetricID AND
							RDSMABK.PopulationID = RMABS.PopulationID AND 
							RDSMABK.ProductLineID = RMABS.ProductLineID AND
							(
								((@ResultTypeID IS NULL) AND (RMABS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = 255) AND (RMABS.ResultTypeID NOT IN (2, 3))) OR 
								(RMABS.ResultTypeID = @ResultTypeID)
							)
		WHERE	(RDSMABK.DataRunID = @DataRunID) AND
				(RDSMABK.MetricID = @MetricID) AND
				((@PopulationID IS NULL) OR (RDSMABK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMABK.ProductLineID = @ProductLineID))
		GROUP BY RDSMABK.AgeBandSegDescr,
				RDSMABK.AgeBandSegID,
				RDSMABK.BenefitDescr,
				RDSMABK.BenefitID,
				RDSMABK.DataRunID,
				RDSMABK.DataSetID,
				RDSMABK.Gender,
				RDSMABK.MeasureAbbrev,
				RDSMABK.MeasureID,
				RDSMABK.MetricDescr,
				RDSMABK.MetricID,
				RDSMABK.PopulationID,
				RDSMABK.ProductLineID
	
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
GRANT EXECUTE ON  [Report].[GetMeasureByAgeBandGraph] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureByAgeBandGraph] TO [Reports]
GO
