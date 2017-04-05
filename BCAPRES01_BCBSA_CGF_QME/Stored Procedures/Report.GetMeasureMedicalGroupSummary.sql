SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/10/2011
-- Description:	Retrieves the top-level measure/metric based summary report for medical groups.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureMedicalGroupSummary]
(
	@DataRunID int,
	@MeasClassID smallint = NULL,
	@MeasureID int = NULL,
	@MedGrpID int = NULL,
	@MetricID int = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@RegionName varchar(64) = NULL,
	@ResultTypeID tinyint = NULL,
	@SubMeasClassID smallint = NULL,
	@SubRegionName varchar(64) = NULL,
	@TopMeasClassID smallint = NULL,
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
		SET @LogObjectName = 'GetMeasureMedicalGroupSummary'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES ('@DataRunID', @DataRunID);
		--INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DSProviderID', @DSProviderID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasClassID', @MeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MedGrpID', @MedGrpID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@RegionName', @RegionName);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ResultTypeID', @ResultTypeID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@SubMeasClassID', @SubMeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@SubRegionName', @SubRegionName);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@TopMeasClassID', @TopMeasClassID);
		
		--DETERMINES THE DEFAULT RESULT TYPE FOR EACH MEASURE
		SELECT	MeasureID,
				MAX(ResultTypeID) AS ResultTypeID
		INTO	#MeasureDefaultResultType
		FROM	Result.MeasureSummary WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID)
		GROUP BY MeasureID;
		
		CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDefaultResultType ON #MeasureDefaultResultType (MeasureID);
		
		
		--COPIES THE MEASURE KEYS INTO TEMP TABLE FOR BETTER PERFORMANCE
		SELECT	RMFK.*,
				RMTK.KeyFieldDescr,
				RMTK.KeyFieldID,
				RMTK.KeyFieldName,
				ISNULL(t.ResultTypeID, 255) AS ResultTypeID,
				RMTK.ShowHeadersEachMetric,
				RMTK.ShowOnReport
		INTO	#ReportMeasureFieldKey
		FROM	Report.MeasureFieldKey AS RMFK WITH(NOLOCK)
				LEFT OUTER JOIN Report.MeasureSettingsKey AS RMTK WITH(NOLOCK)
						ON RMFK.MeasureID = RMTK.MeasureID
				LEFT OUTER JOIN #MeasureDefaultResultType AS t
						ON RMTK.MeasureID = t.MeasureID
		WHERE	RMFK.ReportType = 'Provider';
		
		CREATE UNIQUE CLUSTERED INDEX IX_#ReportMeasureFieldKey ON #ReportMeasureFieldKey (MeasureID);


		--THE RETURNERED RESULTSET------------------------------------------
		WITH ResultDataSetMetricKey AS
		(
			SELECT DISTINCT
					[BenefitDescr],
					[BenefitID],
					[DataRunID],
					[DataSetID],
					[IsHybrid],
					[IsParent],
					[MeasClassDescr],
					[MeasClassID],
					[MeasureAbbrev],
					[MeasureDescr],
					[MeasureGuid],
					[MeasureID],
					[MetricAbbrev],
					[MetricDescr],
					[MetricGuid],
					[MetricID],
					[PopulationID],
					[ProductLineID],
					[SubMeasClassDescr],
					[SubMeasClassID],
					[TopMeasClassDescr],
					[TopMeasClassID]
			FROM	Result.DataSetMetricKey WITH(NOLOCK)
		)
		SELECT	RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				0 AS CountMonths,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
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
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				MIN(RMFK.KeyFieldDescr) AS KeyFieldDescr,
				MIN(RMFK.KeyFieldID) AS KeyFieldID,
				MIN(RMFK.KeyFieldName) AS KeyFieldName,
				RDSMK.MeasClassDescr,
				RDSMK.MeasClassID,
				RDSMK.MeasureAbbrev,
				RDSMK.MeasureDescr,
				RDSMK.MeasureGuid,
				RDSMK.MeasureID,
				ISNULL(NULLIF(NULLIF(NULLIF(MIN(RDSMGK.MedGrpFullName), ''), '(NONE)'), 'N/A'), '(No Medical Group Assigned)') AS MedGrpFullName,
				ISNULL(RMS.MedGrpID, -1) AS MedGrpID,
				ISNULL(NULLIF(NULLIF(NULLIF(MIN(RDSMGK.MedGrpName), ''), '(NONE)'), 'N/A'), '(No Medical Group Assigned)') AS MedGrpName,
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				RDSMK.MetricGuid,
				RDSMK.MetricID,
				MIN(RDSPK.Descr) AS PopulationDescr,
				RDSMK.PopulationID,
				MIN(RDSPK.PopulationNum) AS PopulationNum,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty,
				ISNULL(NULLIF(NULLIF(NULLIF(MIN(RDSMGK.RegionName), ''), '(NONE)'), 'N/A'), '(No Medical Group Assigned)') AS RegionName,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(COALESCE(RMS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID)) AS ResultTypeID,
				CAST(MIN(CAST(RMFK.ShowHeadersEachMetric AS smallint)) AS bit) AS ShowHeadersEachMetric,
				CAST(MIN(CAST(RMFK.ShowOnReport AS smallint)) AS bit) AS ShowOnReport,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				ISNULL(NULLIF(NULLIF(NULLIF(MIN(RDSMGK.SubRegionName), ''), '(NONE)'), 'N/A'), '(No Medical Group Assigned)') AS SubRegionName,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID,
				0 AS TotMQty,
				0 AS TotXQty
		FROM	ResultDataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK WITH(NOLOCK)
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN Result.MeasureProviderSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = 255) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
				LEFT OUTER JOIN Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
						ON RMS.DataRunID = RDSMGK.DataRunID AND	
							RMS.DataSetID = RDSMGK.DataSetID AND
							RMS.MedGrpID = RDSMGK.MedGrpID
		WHERE	(RDSMK.DataRunID = @DataRunID) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				((@MedGrpID IS NULL) OR (RMS.MedGrpID = @MedGrpID)) AND
				((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@SubRegionName IS NULL) OR (RDSMGK.SubRegionName = @SubRegionName)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID)) AND
				((@ResultTypeID IS NULL) OR (@ResultTypeID NOT IN (2, 3)) OR (RDSMK.IsHybrid = 1))
		GROUP BY RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MeasClassDescr,
				RDSMK.MeasClassID,
				RDSMK.MeasureAbbrev,
				RDSMK.MeasureDescr,
				RDSMK.MeasureGuid,
				RDSMK.MeasureID,
				RMS.MedGrpID,
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				RDSMK.MetricGuid,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID
		ORDER BY MeasClassDescr, MetricAbbrev, PopulationID, ProductLineID , RegionName, SubRegionName, MedGrpName
	
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
GRANT EXECUTE ON  [Report].[GetMeasureMedicalGroupSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureMedicalGroupSummary] TO [Reports]
GO
