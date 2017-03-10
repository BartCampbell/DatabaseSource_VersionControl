SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/8/2013
-- Description:	Retrieves the top-level measure/metric based summary comparison vs. NCQA's means and percentiles.
--				(Based on Report.GetMeasureSummaryComparison)
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureSummaryVsPercentiles]
(
	@FromDataRunID int,
	@MeasClassID smallint = NULL,
	@MeasureID int = NULL,
	@MetricID int = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@ResultTypeID tinyint = NULL,
	@ShowNoPercentiles bit = 1,
	@SubMeasClassID smallint = NULL,
	@ToDataRunID int,
	@TopMeasClassID smallint = NULL,
	@UserName nvarchar(128) = NULL,
	@Year smallint = NULL OUTPUT
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
		SET @LogObjectName = 'GetMeasureSummaryVsPercentiles'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
	
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@FromDataRunID', @FromDataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasClassID', @MeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ResultTypeID', @ResultTypeID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@SubMeasClassID', @SubMeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ToDataRunID', @ToDataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@TopMeasClassID', @TopMeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@Year', @Year);
		
		IF @Year IS NULL
			SELECT @Year = MAX(IdssYear) FROM Report.MeansAndPercentiles
		
		IF OBJECT_ID('tempdb..#CrossDataRunMetricKey') IS NOT NULL
			DROP TABLE #CrossDataRunMetricKey;

		SELECT	*
		INTO	#CrossDataRunMetricKey
		FROM	Result.GetCrossDataRunMetricKey(@FromDataRunID, @ToDataRunID);
	
		--DETERMINES THE DEFAULT RESULT TYPE FOR EACH MEASURE--------------------------
		IF OBJECT_ID('tempdb..#MeasureDefaultResultType') IS NOT NULL
			DROP TABLE #MeasureDefaultResultType;
			
		SELECT	DataRunID,
				MeasureID,
				MAX(ResultTypeID) AS ResultTypeID
		INTO	#MeasureDefaultResultType
		FROM	Result.MeasureSummary WITH(NOLOCK)
		WHERE	(DataRunID = @FromDataRunID)
		GROUP BY DataRunID, MeasureID
		UNION 
		SELECT	DataRunID,
				MeasureID,
				MAX(ResultTypeID) AS ResultTypeID
		FROM	Result.MeasureSummary WITH(NOLOCK)
		WHERE	(DataRunID = @ToDataRunID)
		GROUP BY DataRunID, MeasureID;
		
		CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDefaultResultType ON #MeasureDefaultResultType (MeasureID, DataRunID);
		
		
		--COPIES THE MEASURE KEYS INTO A TEMP TABLE FOR BETTER PERFORMANCE-------------
		IF OBJECT_ID('tempdb..#ReportMeasureFieldKey') IS NOT NULL
			DROP TABLE #ReportMeasureFieldKey;
		
		SELECT	@FromDataRunID AS DataRunID,
				RMFK.*,
				RMTK.KeyFieldDescr,
				RMTK.KeyFieldID,
				RMTK.KeyFieldName,
				RMTK.KeyFieldNumberFormat,
				ISNULL(t.ResultTypeID, 255) AS ResultTypeID,
				RMTK.ShowHeadersEachMetric,
				RMTK.ShowOnReport
		INTO	#ReportMeasureFieldKey
		FROM	Report.MeasureFieldKey AS RMFK WITH(NOLOCK)
				LEFT OUTER JOIN Report.MeasureSettingsKey AS RMTK WITH(NOLOCK)
						ON RMFK.MeasureID = RMTK.MeasureID
				LEFT OUTER JOIN #MeasureDefaultResultType AS t
						ON RMTK.MeasureID = t.MeasureID AND
							t.DataRunID = @FromDataRunID
		WHERE	(RMFK.ReportType = 'Comparison')
		UNION 		
		SELECT	@ToDataRunID AS DataRunID,
				RMFK.*,
				RMTK.KeyFieldDescr,
				RMTK.KeyFieldID,
				RMTK.KeyFieldName,
				RMTK.KeyFieldNumberFormat,
				ISNULL(t.ResultTypeID, 255) AS ResultTypeID,
				RMTK.ShowHeadersEachMetric,
				RMTK.ShowOnReport
		FROM	Report.MeasureFieldKey AS RMFK WITH(NOLOCK)
				LEFT OUTER JOIN Report.MeasureSettingsKey AS RMTK WITH(NOLOCK)
						ON RMFK.MeasureID = RMTK.MeasureID
				LEFT OUTER JOIN #MeasureDefaultResultType AS t
						ON RMTK.MeasureID = t.MeasureID AND
							t.DataRunID = @ToDataRunID
		WHERE	(RMFK.ReportType = 'Comparison');
		
		CREATE UNIQUE CLUSTERED INDEX IX_#ReportMeasureFieldKey ON #ReportMeasureFieldKey (MeasureID, DataRunID);

		--CREATES THE MEASURE-LEVEL SUMMARY DATA----------------------------
		IF OBJECT_ID('tempdb..#FromMeasureTotals') IS NOT NULL
			DROP TABLE #FromMeasureTotals;
			
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#FromMeasureTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RDSPK.DataRunID = RMFK.DataRunID AND
							RMFK.ShowOnReport = 1
				INNER JOIN Result.MeasureSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = -1) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
		WHERE	(RDSMK.DataRunID = @FromDataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				--((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				--((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID;
				
		IF OBJECT_ID('tempdb..#ToMeasureTotals') IS NOT NULL
			DROP TABLE #ToMeasureTotals;
			
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#ToMeasureTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RDSPK.DataRunID = RMFK.DataRunID AND
							RMFK.ShowOnReport = 1 
				INNER JOIN Result.MeasureSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = -1) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
		WHERE	(RDSMK.DataRunID = @ToDataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				--((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				--((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID;

		--CREATES THE METRIC-LEVEL SUMMARY DATA-----------------------------
		IF OBJECT_ID('tempdb..#FromMetricTotals') IS NOT NULL
			DROP TABLE #FromMetricTotals;
			
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#FromMetricTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN Result.MeasureSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = -1) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
		WHERE	(RDSMK.DataRunID = @FromDataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				--((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				--((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID;
				
		IF OBJECT_ID('tempdb..#ToMetricTotals') IS NOT NULL
			DROP TABLE #ToMetricTotals;
			
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#ToMetricTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN Result.MeasureSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = -1) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
		WHERE	(RDSMK.DataRunID = @ToDataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				--((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				--((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID;

		--THE RETURNED RESULTSET------------------------------------------
		WITH MeasureSummary AS
		(
			SELECT	[AgeBandID],
					[AgeBandSegID],
					SUM([CountEvents]) AS [CountEvents],
					SUM([CountMembers]) AS [CountMembers],
					SUM([CountRecords]) AS [CountRecords],
					[DataRunID],
					[DataSetID],
					SUM([Days]) AS [Days],
					SUM([IsDenominator]) AS [IsDenominator],
					SUM([IsExclusion]) AS [IsExclusion],
					SUM([IsIndicator]) AS [IsIndicator],
					SUM([IsNegative]) AS [IsNegative],
					SUM([IsNumerator]) AS [IsNumerator],
					SUM([IsNumeratorAdmin]) AS [IsNumeratorAdmin],
					SUM([IsNumeratorFSS]) AS [IsNumeratorFSS],
					SUM([IsNumeratorMedRcd]) AS [IsNumeratorMedRcd],
					[MeasureID],
					[MetricID],
					MIN(PayerID) AS PayerID,
					[PopulationID],
					[ProductLineID],
					SUM([Qty]) AS [Qty],
					[ResultTypeID]
			FROM	Result.MeasureSummary AS RMS WITH(NOLOCK)
			WHERE	DataRunID IN (@FromDataRunID, @ToDataRunID)
			GROUP BY [AgeBandID],
					[AgeBandSegID],
					[DataRunID],
					[DataSetID],
					[MeasureID],
					[MetricID],
					[PopulationID],
					[ProductLineID],
					[ResultTypeID]
		),
		DefaultPayer AS
		(
			SELECT TOP 1 PayerID FROM MeasureSummary
		)
		SELECT	RDSMK.AgeBandSegDescr,
				RDSMK.AgeBandSegID,
				RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				--RDSMK.DataRunID,
				--RDSMK.DataSetID,
				MIN(COALESCE(RMFK1.FieldDescr01, RMFK2.FieldDescr01)) AS FieldDescr01,
				MIN(COALESCE(RMFK1.FieldDescr02, RMFK2.FieldDescr02)) AS FieldDescr02,
				MIN(COALESCE(RMFK1.FieldDescr03, RMFK2.FieldDescr03)) AS FieldDescr03,
				MIN(COALESCE(RMFK1.FieldDescr04, RMFK2.FieldDescr04)) AS FieldDescr04,
				MIN(COALESCE(RMFK1.FieldDescr05, RMFK2.FieldDescr05)) AS FieldDescr05,
				MIN(COALESCE(RMFK1.FieldDescr06, RMFK2.FieldDescr06)) AS FieldDescr06,
				MIN(COALESCE(RMFK1.FieldDescr07, RMFK2.FieldDescr07)) AS FieldDescr07,
				MIN(COALESCE(RMFK1.FieldDescr08, RMFK2.FieldDescr08)) AS FieldDescr08,
				MIN(COALESCE(RMFK1.FieldDescr09, RMFK2.FieldDescr09)) AS FieldDescr09,
				MIN(COALESCE(RMFK1.FieldDescr10, RMFK2.FieldDescr10)) AS FieldDescr10,
				MIN(COALESCE(RMFK1.FieldDescr11, RMFK2.FieldDescr11)) AS FieldDescr11,
				MIN(COALESCE(RMFK1.FieldDescr12, RMFK2.FieldDescr12)) AS FieldDescr12,
				MIN(COALESCE(RMFK1.FieldID01, RMFK2.FieldID01)) AS FieldID01,
				MIN(COALESCE(RMFK1.FieldID02, RMFK2.FieldID02)) AS FieldID02,
				MIN(COALESCE(RMFK1.FieldID03, RMFK2.FieldID03)) AS FieldID03,
				MIN(COALESCE(RMFK1.FieldID04, RMFK2.FieldID04)) AS FieldID04,
				MIN(COALESCE(RMFK1.FieldID05, RMFK2.FieldID05)) AS FieldID05,
				MIN(COALESCE(RMFK1.FieldID06, RMFK2.FieldID06)) AS FieldID06,
				MIN(COALESCE(RMFK1.FieldID07, RMFK2.FieldID07)) AS FieldID07,
				MIN(COALESCE(RMFK1.FieldID08, RMFK2.FieldID08)) AS FieldID08,
				MIN(COALESCE(RMFK1.FieldID09, RMFK2.FieldID09)) AS FieldID09,
				MIN(COALESCE(RMFK1.FieldID10, RMFK2.FieldID10)) AS FieldID10,
				MIN(COALESCE(RMFK1.FieldID11, RMFK2.FieldID11)) AS FieldID11,
				MIN(COALESCE(RMFK1.FieldID12, RMFK2.FieldID12)) AS FieldID12,
				MIN(COALESCE(RMFK1.FieldName01, RMFK2.FieldName01)) AS FieldName01,
				MIN(COALESCE(RMFK1.FieldName02, RMFK2.FieldName02)) AS FieldName02,
				MIN(COALESCE(RMFK1.FieldName03, RMFK2.FieldName03)) AS FieldName03,
				MIN(COALESCE(RMFK1.FieldName04, RMFK2.FieldName04)) AS FieldName04,
				MIN(COALESCE(RMFK1.FieldName05, RMFK2.FieldName05)) AS FieldName05,
				MIN(COALESCE(RMFK1.FieldName06, RMFK2.FieldName06)) AS FieldName06,
				MIN(COALESCE(RMFK1.FieldName07, RMFK2.FieldName07)) AS FieldName07,
				MIN(COALESCE(RMFK1.FieldName08, RMFK2.FieldName08)) AS FieldName08,
				MIN(COALESCE(RMFK1.FieldName09, RMFK2.FieldName09)) AS FieldName09,
				MIN(COALESCE(RMFK1.FieldName10, RMFK2.FieldName10)) AS FieldName10,
				MIN(COALESCE(RMFK1.FieldName11, RMFK2.FieldName11)) AS FieldName11,
				MIN(COALESCE(RMFK1.FieldName12, RMFK2.FieldName12)) AS FieldName12,
				MIN(COALESCE(RMFK1.FieldNumberFormat01, RMFK2.FieldNumberFormat01)) AS FieldNumberFormat01,
				MIN(COALESCE(RMFK1.FieldNumberFormat02, RMFK2.FieldNumberFormat02)) AS FieldNumberFormat02,
				MIN(COALESCE(RMFK1.FieldNumberFormat03, RMFK2.FieldNumberFormat03)) AS FieldNumberFormat03,
				MIN(COALESCE(RMFK1.FieldNumberFormat04, RMFK2.FieldNumberFormat04)) AS FieldNumberFormat04,
				MIN(COALESCE(RMFK1.FieldNumberFormat05, RMFK2.FieldNumberFormat05)) AS FieldNumberFormat05,
				MIN(COALESCE(RMFK1.FieldNumberFormat06, RMFK2.FieldNumberFormat06)) AS FieldNumberFormat06,
				MIN(COALESCE(RMFK1.FieldNumberFormat07, RMFK2.FieldNumberFormat07)) AS FieldNumberFormat07,
				MIN(COALESCE(RMFK1.FieldNumberFormat08, RMFK2.FieldNumberFormat08)) AS FieldNumberFormat08,
				MIN(COALESCE(RMFK1.FieldNumberFormat09, RMFK2.FieldNumberFormat09)) AS FieldNumberFormat09,
				MIN(COALESCE(RMFK1.FieldNumberFormat10, RMFK2.FieldNumberFormat10)) AS FieldNumberFormat10,
				MIN(COALESCE(RMFK1.FieldNumberFormat11, RMFK2.FieldNumberFormat11)) AS FieldNumberFormat11,
				MIN(COALESCE(RMFK1.FieldNumberFormat12, RMFK2.FieldNumberFormat12)) AS FieldNumberFormat12,
				RDSMK.Gender,
				MIN(COALESCE(RMFK1.KeyFieldDescr, RMFK2.KeyFieldDescr)) AS KeyFieldDescr,
				MIN(COALESCE(RMFK1.KeyFieldID, RMFK2.KeyFieldID)) AS KeyFieldID,
				MIN(COALESCE(RMFK1.KeyFieldName, RMFK2.KeyFieldName)) AS KeyFieldName,
				MIN(COALESCE(RMFK1.KeyFieldNumberFormat, RMFK2.KeyFieldNumberFormat)) AS KeyFieldNumberFormat,
				RDSMK.MeasClassDescr,
				RDSMK.MeasClassID,
				RDSMK.MeasureAbbrev,
				RDSMK.MeasureDescr,
				--RDSMK.MeasureID,
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				--RDSMK.MetricID,
				MIN(COALESCE(RDSPK1.Descr, RDSPK1.Descr)) AS PopulationDescr,
				RDSMK.PopulationID,
				MIN(COALESCE(RDSPK1.PopulationNum, RDSPK1.PopulationNum)) AS PopulationNum,
				RDSMK.ProductLineID,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMS1.ResultTypeID, RMS2.ResultTypeID, RMFK1.ResultTypeID, RMFK2.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(COALESCE(RMS1.ResultTypeID, RMS2.ResultTypeID, RMFK1.ResultTypeID, RMFK2.ResultTypeID, @ResultTypeID)) AS ResultTypeID,
				CAST(MIN(CAST(COALESCE(RMFK1.ShowHeadersEachMetric, RMFK2.ShowHeadersEachMetric) AS smallint)) AS bit) AS ShowHeadersEachMetric,
				CAST(MIN(CAST(COALESCE(RMFK1.ShowOnReport, RMFK2.ShowOnReport) AS smallint)) AS bit) AS ShowOnReport,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID,
				
				--------------------------------------------------------
				CONVERT(uniqueidentifier, MIN(CONVERT(binary(16), RDSMK.FromMeasureGuid))) AS FromMeasureGuid,
				MIN(RDSMK.FromMeasureID) AS FromMeasureID,
				MIN(RDSMK.FromMetricID) AS FromMetricID,
				CONVERT(uniqueidentifier, MIN(CONVERT(binary(16), RDSMK.ToMeasureGuid))) AS ToMeasureGuid,
				MIN(RDSMK.ToMeasureID) AS ToMeasureID,
				MIN(RDSMK.ToMetricID) AS ToMetricID,
				--------------------------------------------------------
				
				--MEAN AND PERCENTILES
				COALESCE(MIN(RMPABS.Mean), MIN(RMPMX.Mean)) AS MeanAbs,
				MIN(RMPMX.Mean) AS MeanMx,
				COALESCE(MIN(RMPABS.Percent05), MIN(RMPMX.Percent05)) AS Percent05Abs,
				MIN(RMPMX.Percent05) AS Percent05Mx,
				COALESCE(MIN(RMPABS.Percent10), MIN(RMPMX.Percent10)) AS Percent10Abs,
				MIN(RMPMX.Percent10) AS Percent10Mx,
				COALESCE(MIN(RMPABS.Percent25), MIN(RMPMX.Percent25)) AS Percent25Abs,
				MIN(RMPMX.Percent25) AS Percent25Mx,
				COALESCE(MIN(RMPABS.Percent50), MIN(RMPMX.Percent50)) AS Percent50Abs,
				MIN(RMPMX.Percent50) AS Percent50Mx,
				COALESCE(MIN(RMPABS.Percent75), MIN(RMPMX.Percent75)) AS Percent75Abs,
				MIN(RMPMX.Percent75) AS Percent75Mx,
				COALESCE(MIN(RMPABS.Percent90), MIN(RMPMX.Percent90)) AS Percent90Abs,
				MIN(RMPMX.Percent90) AS Percent90Mx,
				COALESCE(MIN(RMPABS.Percent95), MIN(RMPMX.Percent95)) AS Percent95Abs,
				MIN(RMPMX.Percent95) AS Percent95Mx,
				MIN(RMPABS.PayerID) AS MeanPayerID,
				MIN(RMPABS.IdssYear) AS MeanYear,
				MIN(RMPMX.PayerID) AS PercentPayerID,
				MIN(RMPMX.IdssYear) AS PercentYear,
								
				
				--FROM DATA RUN VALUE FIELDS
				ISNULL(SUM(RMS1.CountEvents), 0) AS FromCountEvents,
				ISNULL(SUM(RMS1.CountMembers), 0) AS FromCountMembers,
				0 AS FromCountMonths,
				ISNULL(SUM(RMS1.CountRecords), 0) AS FromCountRecords,
				ISNULL(SUM(RMS1.[Days]), 0) AS [FromDays],
				ISNULL(SUM(RMS1.IsDenominator), 0) AS [FromIsDenominator],
				ISNULL(SUM(RMS1.IsExclusion), 0) AS [FromIsExclusion],
				ISNULL(SUM(RMS1.IsNegative), 0) AS FromIsNegative,
				ISNULL(SUM(RMS1.IsNumerator), 0) AS [FromIsNumerator],
				ISNULL(SUM(RMS1.Qty), 0) AS FromQty,
				ISNULL(MIN(MT1.CountEvents), 0) AS FromTotMCountEvents,
				ISNULL(MIN(MT1.CountMembers), 0) AS FromTotMCountMembers,
				ISNULL(MIN(MT1.CountRecords), 0) AS FromTotMCountRecords,
				ISNULL(MIN(MT1.[Days]), 0) AS FromTotMDays,
				ISNULL(MIN(MT1.IsDenominator), 0) AS FromTotMIsDenominator,
				ISNULL(MIN(MT1.IsExclusion), 0) AS FromTotMIsExclusion,
				ISNULL(MIN(MT1.IsNegative), 0) AS FromTotMIsNegative,
				ISNULL(MIN(MT1.IsNumerator), 0) AS FromTotMIsNumerator,
				ISNULL(MIN(MT1.Qty), 0) AS FromTotMQty,
				ISNULL(MIN(XT1.CountEvents), 0) AS FromTotXCountEvents,
				ISNULL(MIN(XT1.CountMembers), 0) AS FromTotXCountMembers,
				ISNULL(MIN(XT1.CountRecords), 0) AS FromTotXCountRecords,
				ISNULL(MIN(XT1.[Days]), 0) AS FromTotXDays,
				ISNULL(MIN(XT1.IsDenominator), 0) AS FromTotXIsDenominator,
				ISNULL(MIN(XT1.IsExclusion), 0) AS FromTotXIsExclusion,
				ISNULL(MIN(XT1.IsNegative), 0) AS FromTotXIsNegative,
				ISNULL(MIN(XT1.IsNumerator), 0) AS FromTotXIsNumerator,
				ISNULL(MIN(XT1.Qty), 0) AS FromTotXQty,
				--TO DATA RUN VALUE FIELDS
				ISNULL(SUM(RMS2.CountEvents), 0) AS ToCountEvents,
				ISNULL(SUM(RMS2.CountMembers), 0) AS ToCountMembers,
				0 AS ToCountMonths,
				ISNULL(SUM(RMS2.CountRecords), 0) AS ToCountRecords,
				ISNULL(SUM(RMS2.[Days]), 0) AS [ToDays],
				ISNULL(SUM(RMS2.IsDenominator), 0) AS [ToIsDenominator],
				ISNULL(SUM(RMS2.IsExclusion), 0) AS [ToIsExclusion],
				ISNULL(SUM(RMS2.IsNegative), 0) AS ToIsNegative,
				ISNULL(SUM(RMS2.IsNumerator), 0) AS [ToIsNumerator],
				ISNULL(SUM(RMS2.Qty), 0) AS ToQty,
				ISNULL(MIN(MT2.CountEvents), 0) AS ToTotMCountEvents,
				ISNULL(MIN(MT2.CountMembers), 0) AS ToTotMCountMembers,
				ISNULL(MIN(MT2.CountRecords), 0) AS ToTotMCountRecords,
				ISNULL(MIN(MT2.[Days]), 0) AS ToTotMDays,
				ISNULL(MIN(MT2.IsDenominator), 0) AS ToTotMIsDenominator,
				ISNULL(MIN(MT2.IsExclusion), 0) AS ToTotMIsExclusion,
				ISNULL(MIN(MT2.IsNegative), 0) AS ToTotMIsNegative,
				ISNULL(MIN(MT2.IsNumerator), 0) AS ToTotMIsNumerator,
				ISNULL(MIN(MT2.Qty), 0) AS ToTotMQty,
				ISNULL(MIN(XT2.CountEvents), 0) AS ToTotXCountEvents,
				ISNULL(MIN(XT2.CountMembers), 0) AS ToTotXCountMembers,
				ISNULL(MIN(XT2.CountRecords), 0) AS ToTotXCountRecords,
				ISNULL(MIN(XT2.[Days]), 0) AS ToTotXDays,
				ISNULL(MIN(XT2.IsDenominator), 0) AS ToTotXIsDenominator,
				ISNULL(MIN(XT2.IsExclusion), 0) AS ToTotXIsExclusion,
				ISNULL(MIN(XT2.IsNegative), 0) AS ToTotXIsNegative,
				ISNULL(MIN(XT2.IsNumerator), 0) AS ToTotXIsNumerator,
				ISNULL(MIN(XT2.Qty), 0) AS ToTotXQty
		FROM	#CrossDataRunMetricKey AS RDSMK
				CROSS JOIN DefaultPayer DP
				LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK1 WITH(NOLOCK)
						ON RDSMK.FromDataSetID = RDSPK1.DataSetID AND
							RDSMK.FromDataRunID = RDSPK1.DataRunID AND
							RDSMK.PopulationID = RDSPK1.PopulationID
				LEFT OUTER JOIN Result.DataSetPopulationKey AS RDSPK2 WITH(NOLOCK)
						ON RDSMK.ToDataSetID = RDSPK2.DataSetID AND
							RDSMK.ToDataRunID = RDSPK2.DataRunID AND
							RDSMK.PopulationID = RDSPK2.PopulationID
				LEFT OUTER JOIN #ReportMeasureFieldKey AS RMFK1
						ON RDSMK.FromMeasureID = RMFK1.MeasureID AND
							RDSMK.FromDataRunID = RMFK1.DataRunID AND
							RMFK1.ShowOnReport = 1
				LEFT OUTER JOIN #ReportMeasureFieldKey AS RMFK2
						ON RDSMK.ToMeasureID = RMFK2.MeasureID AND
							RDSMK.ToDataRunID = RMFK2.DataRunID AND
							RMFK2.ShowOnReport = 1
				LEFT OUTER JOIN MeasureSummary AS RMS1
						ON RDSMK.FromDataSetID = RMS1.DataSetID AND
							RDSMK.FromDataRunID = RMS1.DataRunID AND
							RDSMK.FromMeasureID = RMS1.MeasureID AND
							RDSMK.FromMetricID = RMS1.MetricID AND
							RDSMK.PopulationID = RMS1.PopulationID AND
							RDSMK.ProductLineID = RMS1.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS1.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS1.ResultTypeID = COALESCE(RMFK2.ResultTypeID, RMFK1.ResultTypeID))) OR 
								((@ResultTypeID = 255) AND (RMS1.ResultTypeID NOT IN (2, 3))) OR 
								(RMS1.ResultTypeID = @ResultTypeID)
							)
				LEFT OUTER JOIN MeasureSummary AS RMS2
						ON RDSMK.ToDataSetID = RMS2.DataSetID AND
							RDSMK.ToDataRunID = RMS2.DataRunID AND
							RDSMK.ToMeasureID = RMS2.MeasureID AND
							RDSMK.ToMetricID = RMS2.MetricID AND
							RDSMK.PopulationID = RMS2.PopulationID AND
							RDSMK.ProductLineID = RMS2.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS2.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS2.ResultTypeID = COALESCE(RMFK2.ResultTypeID, RMFK1.ResultTypeID))) OR 
								((@ResultTypeID = 255) AND (RMS2.ResultTypeID NOT IN (2, 3))) OR 
								(RMS2.ResultTypeID = @ResultTypeID)
							)
				LEFT OUTER JOIN #FromMeasureTotals AS MT1
						ON RDSMK.FromDataRunID = MT1.DataRunID AND
							RDSMK.FromDataSetID = MT1.DataSetID AND
							RDSMK.FromMeasureID = MT1.MeasureID AND
							RDSMK.PopulationID = MT1.PopulationID AND
							RDSMK.ProductLineID = MT1.ProductLineID
				LEFT OUTER JOIN #ToMeasureTotals AS MT2
						ON RDSMK.ToDataRunID = MT2.DataRunID AND
							RDSMK.ToDataSetID = MT2.DataSetID AND
							RDSMK.ToMeasureID = MT2.MeasureID AND
							RDSMK.PopulationID = MT2.PopulationID AND
							RDSMK.ProductLineID = MT2.ProductLineID
				LEFT OUTER JOIN #FromMetricTotals AS XT1
						ON RDSMK.FromDataRunID = XT1.DataRunID AND
							RDSMK.FromDataSetID = XT1.DataSetID AND
							RDSMK.FromMetricID = XT1.MetricID AND
							RDSMK.PopulationID = XT1.PopulationID AND
							RDSMK.ProductLineID = XT1.ProductLineID
				LEFT OUTER JOIN #ToMetricTotals AS XT2
						ON RDSMK.ToDataRunID = XT2.DataRunID AND
							RDSMK.ToDataSetID = XT2.DataSetID AND
							RDSMK.ToMetricID = XT2.MetricID AND
							RDSMK.PopulationID = XT2.PopulationID AND
							RDSMK.ProductLineID = XT2.ProductLineID
				LEFT OUTER JOIN Report.MeansAndPercentiles AS RMPABS WITH(NOLOCK) --Percentiles at the Age Band Level
						ON RDSMK.AgeBandSegID = RMPABS.AgeBandSegID AND
							RDSMK.ToMeasureID = RMPABS.MeasureID AND
							RDSMK.ToMetricID = RMPABS.MetricID AND
							ISNULL(RMS2.PayerID, DP.PayerID) = RMPABS.PayerID AND
							RDSMK.ProductLineID = RMPABS.ProductLineID AND
							RMFK2.KeyFieldID = RMPABS.FieldID AND
							RMPABS.IdssYear = @Year
				LEFT OUTER JOIN Report.MeansAndPercentiles AS RMPMX WITH(NOLOCK) --Percentiles at the Metric Level
						ON RDSMK.ToMeasureID = RMPMX.MeasureID AND
							RDSMK.ToMetricID = RMPMX.MetricID AND
							ISNULL(RMS2.PayerID, DP.PayerID) = RMPMX.PayerID AND
							RDSMK.ProductLineID = RMPMX.ProductLineID AND
							RMFK2.KeyFieldID = RMPMX.FieldID AND
							RMPMX.AgeBandID IS NULL AND
							RMPMX.AgeBandSegID IS NULL AND
							RMPMX.IdssYear = @Year

		WHERE	--(RDSMK.DataRunID = @DataRunID) AND
				((RMFK1.MeasureID IS NOT NULL) OR (RMFK2.MeasureID IS NOT NULL)) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.FromMeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSMK.FromMetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID)) AND
				((@ResultTypeID IS NULL) OR (@ResultTypeID NOT IN (2, 3)) OR (RDSMK.IsHybrid = 1)) AND
				((@ShowNoPercentiles = 1) OR (RMPMX.Percent10 IS NOT NULL) OR (RMPABS.Percent10 IS NOT NULL))
		GROUP BY RDSMK.AgeBandSegDescr,
				RDSMK.AgeBandSegID,
				RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				-------------------
				--RDSMK.DataRunID,
				--RDSMK.FromDataRunID,
				--RDSMK.ToDataRunID,
				-------------------
				-------------------
				--RDSMK.DataSetID,
				--RDSMK.FromDataSetID,
				--RDSMK.ToDataSetID,
				-------------------
				RDSMK.Gender,
				RDSMK.MeasClassDescr,
				RDSMK.MeasClassID,
				RDSMK.MeasureAbbrev,
				RDSMK.MeasureDescr,
				-------------------
				--RDSMK.MeasureID,
				--RDSMK.FromMeasureID,
				--RDSMK.ToMeasureID,
				-------------------
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				-------------------
				--RDSMK.MetricID,
				--RDSMK.FromMetricID,
				--RDSMK.ToMetricID,
				-------------------
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID
		ORDER BY RDSMK.MeasClassDescr, RDSMK.MetricAbbrev, RDSMK.PopulationID, RDSMK.ProductLineID, RDSMK.AgeBandSegID;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetMeasureSummaryVsPercentiles] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureSummaryVsPercentiles] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureSummaryVsPercentiles] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureSummaryVsPercentiles] TO [Reports]
GO
