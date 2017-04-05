SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/24/2011
-- Description:	Retrieves the top-level measure/metric based summary report with filtering by medical group (slower than the normal Measure Summary).
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureSummaryByMedicalGroup]
(
	@DataRunID int,
	@EnrollGroupID int = NULL,
	@MeasClassID smallint = NULL,
	@MeasureID int = NULL,
	@MedGrpID int = NULL,
	@MetricID int = NULL,
	@PayerID int = NULL,
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
		SET @LogObjectName = 'GetMeasureSummaryByMedicalGroup'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		
		IF (@RegionName = '(No Medical Group Assigned)') OR (@SubRegionName = '(No Medical Group Assigned)') 
			SET @MedGrpID = -1;
		
		---------------------------------------------------------------------------
	
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DataRunID', @DataRunID);
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
		
		IF @MeasureID IS NULL AND @MetricID IS NOT NULL
			SELECT @MeasureID = MeasureID FROM Measure.Metrics WHERE MetricID = @MetricID;

		--DETERMINES THE DEFAULT RESULT TYPE FOR EACH MEASURE--------------------------
		SELECT	MeasureID,
				MAX(ResultTypeID) AS ResultTypeID
		INTO	#MeasureDefaultResultType
		FROM	Result.MeasureSummary WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID)
		GROUP BY MeasureID;
		
		CREATE UNIQUE CLUSTERED INDEX IX_#MeasureDefaultResultType ON #MeasureDefaultResultType (MeasureID);
		
		
		--COPIES THE MEASURE KEYS INTO A TEMP TABLE FOR BETTER PERFORMANCE-------------
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

		--CREATE A MEDICAL GROUP FILTERED VERSION OF MEASURE RESULTS----------------
		SELECT	Age,
				AgeBandID,
				AgeBandSegID,
				SUM(CountEvents) AS CountEvents,
				SUM(CountMembers) AS CountMembers,
				SUM(CountRecords) AS CountRecords,
				DataRunID,
				DataSetID,
				SUM([Days]) AS [Days],
				EnrollGroupID,
				Gender,
				SUM(IsDenominator) AS IsDenominator,
				SUM(IsExclusion) AS IsExclusion,
				SUM(IsIndicator) AS IsIndicator,
				SUM(IsNegative) AS IsNegative,
				SUM(IsNumerator) AS IsNumerator,
				SUM(IsNumeratorAdmin) AS IsNumeratorAdmin,
				SUM(IsNumeratorMedRcd) AS IsNumeratorMedRcd,
				MeasureID,
				MeasureXrefID,
				MetricID,
				MetricXrefID,
				PayerID,
				PopulationID,
				ProductLineID,
				SUM(Qty) AS Qty,
				ResultTypeID,
				AVG([Weight]) AS [Weight]
		INTO	#Result_MeasureSummary
		FROM	Result.MeasureProviderSummary AS RMD WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID) AND
				((@EnrollGroupID IS NULL) OR (EnrollGroupID = @EnrollGroupID)) AND
				((@MeasureID IS NULL) OR (MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (MetricID = @MetricID)) AND
				((@PayerID IS NULL) OR (PayerID = @PayerID)) AND
				((@PopulationID IS NULL) OR (PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (ProductLineID = @ProductLineID)) AND
				(
					(MedGrpID IN (
										SELECT	MedGrpID 
										FROM	Result.DataSetMedicalGroupKey AS mg WITH(NOLOCK)
										WHERE	(
													((@MedGrpID IS NULL) OR (mg.MedGrpID = @MedGrpID)) AND
													((@RegionName IS NULL) OR (mg.RegionName = @RegionName)) AND
													((@SubRegionName IS NULL) OR (mg.SubRegionName = @SubRegionName)) AND
													((mg.DataRunID = @DataRunID))
												)
									)
					) 
					 OR
					((@MedGrpID = -1) AND (MedGrpID IS NULL))
				)
		GROUP BY Age,
				AgeBandID,
				AgeBandSegID,
				DataRunID,
				DataSetID,
				EnrollGroupID,
				Gender,
				MeasureID,
				MeasureXrefID,
				MetricID,
				MetricXrefID,
				PayerID,
				PopulationID,
				ProductLineID,
				ResultTypeID;
				
		--CREATE A MEDICAL GROUP FILTERED VERSION OF MEMBER MONTHS----------------
		/*SELECT	AgeBandID, 
				AgeBandSegID,
				BenefitID, 
				SUM(CountMembers) AS CountMembers,
				SUM(CountMonths) AS CountMonths,
				DataRunID,
				DataSetID,
				MeasureID,
				MeasureXrefID,
				MetricID,
				MetricXrefID,
				PopulationID,
				ProductLineID
		INTO	#Result_MetricMonthSummary
		FROM	Result.MetricProviderMonthSummary WITH(NOLOCK)
		WHERE	(DataRunID = @DataRunID) AND
				((@EnrollGroupID IS NULL) OR (EnrollGroupID = @EnrollGroupID)) AND
				((@MeasureID IS NULL) OR (MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (MetricID = @MetricID)) AND
				((@PayerID IS NULL) OR (PayerID = @PayerID)) AND
				((@PopulationID IS NULL) OR (PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (ProductLineID = @ProductLineID)) AND
				(
					(MedGrpID IN (
										SELECT	MedGrpID 
										FROM	Result.DataSetMedicalGroupKey AS mg WITH(NOLOCK)
										WHERE	(
													((@MedGrpID IS NULL) OR (mg.MedGrpID = @MedGrpID)) AND
													((@RegionName IS NULL) OR (mg.RegionName = @RegionName)) AND
													((@SubRegionName IS NULL) OR (mg.SubRegionName = @SubRegionName)) AND
													((mg.DataRunID = @DataRunID))
												)
									)
					) 
					 OR
					((@MedGrpID = -1) AND (MedGrpID IS NULL))
				)
		GROUP BY AgeBandID, 
				AgeBandSegID,
				BenefitID,
				DataRunID,
				DataSetID,
				MeasureID,
				MeasureXrefID,
				MetricID,
				MetricXrefID,
				PopulationID,
				ProductLineID;*/

		SELECT	CONVERT(int, NULL) AS AgeBandID, 
				CONVERT(int, NULL) AS AgeBandSegID,
				CONVERT(int, NULL) AS BenefitID, 
				CONVERT(int, NULL) AS CountMembers,
				CONVERT(int, NULL) AS CountMonths,
				CONVERT(int, NULL) AS DataRunID,
				CONVERT(int, NULL) AS DataSetID,
				CONVERT(int, NULL) AS MeasureID,
				CONVERT(int, NULL) AS MeasureXrefID,
				CONVERT(int, NULL) AS MetricID,
				CONVERT(int, NULL) AS MetricXrefID,
				CONVERT(int, NULL) AS PopulationID,
				CONVERT(int, NULL) AS ProductLineID
		INTO	#Result_MetricMonthSummary
		TRUNCATE TABLE #Result_MetricMonthSummary;

		
		--CREATES THE MEASURE-LEVEL SUMMARY DATA----------------------------
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsIndicator), 0) AS [IsIndicator],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#MeasureTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN #Result_MeasureSummary AS RMS WITH(NOLOCK)
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
		WHERE	(RDSMK.DataRunID = @DataRunID) AND
				(RDSMK.IsParent = 0) AND
				(RDSMK.MetricAbbrev NOT IN ('ABXtot','ABXconcern','ABXother')) AND --Prevents multiplied counts with ABX
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				--((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MeasureID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID

		--CREATES THE MEMBER MONTH SUMMARY DATA------------------------
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RXMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RXMS.CountMonths), 0) AS CountMonths,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID
		INTO	#MemberMonthTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #Result_MetricMonthSummary AS RXMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RXMS.DataSetID AND
							RDSMK.DataRunID = RXMS.DataRunID AND
							RDSMK.MeasureID = RXMS.MeasureID AND
							RDSMK.MetricID = RXMS.MetricID AND
							RDSMK.PopulationID = RXMS.PopulationID AND
							RDSMK.ProductLineID = RXMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RXMS.AgeBandSegID) OR (RXMS.AgeBandSegID IS NULL)) 
		WHERE	(RDSMK.DataRunID = @DataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID

		--CREATES THE METRIC-LEVEL SUMMARY DATA-----------------------------
		SELECT	RDSMK.DataRunID,
				RDSMK.DataSetID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(RMS.CountMembers), 0) AS CountMembers,
				ISNULL(SUM(RMS.CountRecords), 0) AS CountRecords,
				ISNULL(SUM(RMS.[Days]), 0) AS [Days],
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsIndicator), 0) AS [IsIndicator],
				ISNULL(SUM(RMS.IsNegative), 0) AS IsNegative,
				ISNULL(SUM(RMS.IsNumerator), 0) AS [IsNumerator],
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty
		INTO	#MetricTotals
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN #Result_MeasureSummary AS RMS WITH(NOLOCK)
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
		WHERE	(RDSMK.DataRunID = @DataRunID) AND
				(RDSMK.IsParent = 0) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID))
		GROUP BY RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.MetricID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID

		--THE RETURNED RESULTSET------------------------------------------		
		SELECT	RDSMK.AgeBandSegDescr,
				RDSMK.AgeBandSegID,
				RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				ISNULL(SUM(RMS.CountEvents), 0) AS CountEvents,
				ISNULL(MIN(RXMS.CountMembers), 0) AS CountMembers,
				ISNULL(MIN(RXMS.CountMonths), 0) AS CountMonths,
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
				RDSMK.Gender,
				ISNULL(SUM(RMS.IsDenominator), 0) AS [IsDenominator],
				ISNULL(SUM(RMS.IsExclusion), 0) AS [IsExclusion],
				ISNULL(SUM(RMS.IsIndicator), 0) AS [IsIndicator],
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
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				RDSMK.MetricGuid,
				RDSMK.MetricID,
				RDSMK.MetricKeyID,
				MIN(RDSPK.Descr) AS PopulationDescr,
				RDSMK.PopulationID,
				MIN(RDSPK.PopulationNum) AS PopulationNum,
				RDSMK.ProductLineID,
				ISNULL(SUM(RMS.Qty), 0) AS Qty,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(COALESCE(RMS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID)) AS ResultTypeID,
				CAST(MIN(CAST(RMFK.ShowHeadersEachMetric AS smallint)) AS bit) AS ShowHeadersEachMetric,
				CAST(MIN(CAST(RMFK.ShowOnReport AS smallint)) AS bit) AS ShowOnReport,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID,
				ISNULL(MIN(MT.CountEvents), 0) AS TotMCountEvents,
				ISNULL(MIN(MT.CountMembers), 0) AS TotMCountMembers,
				ISNULL(MIN(MT.CountRecords), 0) AS TotMCountRecords,
				ISNULL(MIN(MT.[Days]), 0) AS TotMDays,
				ISNULL(MIN(MT.IsDenominator), 0) AS TotMIsDenominator,
				ISNULL(MIN(MT.IsExclusion), 0) AS TotMIsExclusion,
				ISNULL(MIN(MT.IsNegative), 0) AS TotMIsNegative,
				ISNULL(MIN(MT.IsNumerator), 0) AS TotMIsNumerator,
				ISNULL(MIN(MT.Qty), 0) AS TotMQty,
				ISNULL(MIN(MMT.CountMembers), 0) AS TotMMCountMembers,
				ISNULL(MIN(MMT.CountMonths), 0) AS TotMMCountMonths,
				ISNULL(MIN(XT.CountEvents), 0) AS TotXCountEvents,
				ISNULL(MIN(XT.CountMembers), 0) AS TotXCountMembers,
				ISNULL(MIN(XT.CountRecords), 0) AS TotXCountRecords,
				ISNULL(MIN(XT.[Days]), 0) AS TotXDays,
				ISNULL(MIN(XT.IsDenominator), 0) AS TotXIsDenominator,
				ISNULL(MIN(XT.IsExclusion), 0) AS TotXIsExclusion,
				ISNULL(MIN(XT.IsNegative), 0) AS TotXIsNegative,
				ISNULL(MIN(XT.IsNumerator), 0) AS TotXIsNumerator,
				ISNULL(MIN(XT.Qty), 0) AS TotXQty
		FROM	Result.DataSetMetricKey AS RDSMK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSMK.DataSetID = RDSPK.DataSetID AND
							RDSMK.DataRunID = RDSPK.DataRunID AND
							RDSMK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSMK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				LEFT OUTER JOIN #Result_MeasureSummary AS RMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RMS.DataSetID AND
							RDSMK.DataRunID = RMS.DataRunID AND
							RDSMK.MeasureID = RMS.MeasureID AND
							RDSMK.MetricID = RMS.MetricID AND
							RDSMK.PopulationID = RMS.PopulationID AND
							RDSMK.ProductLineID = RMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RMS.AgeBandSegID) OR (RDSMK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = 255) AND (RMS.ResultTypeID NOT IN (2, 3))) OR 
								(RMS.ResultTypeID = @ResultTypeID)
							)
				LEFT OUTER JOIN #Result_MetricMonthSummary AS RXMS WITH(NOLOCK)
						ON RDSMK.DataSetID = RXMS.DataSetID AND
							RDSMK.DataRunID = RXMS.DataRunID AND
							RDSMK.MeasureID = RXMS.MeasureID AND
							RDSMK.MetricID = RXMS.MetricID AND
							RDSMK.PopulationID = RXMS.PopulationID AND
							RDSMK.ProductLineID = RXMS.ProductLineID AND
							((RDSMK.AgeBandSegID = RXMS.AgeBandSegID) OR (RXMS.AgeBandSegID IS NULL)) 
				LEFT OUTER JOIN #MeasureTotals AS MT
						ON RDSMK.DataRunID = MT.DataRunID AND
							RDSMK.DataSetID = MT.DataSetID AND
							RDSMK.MeasureID = MT.MeasureID AND
							RDSMK.PopulationID = MT.PopulationID AND
							RDSMK.ProductLineID = MT.ProductLineID
				LEFT OUTER JOIN #MemberMonthTotals AS MMT
						ON RDSMK.DataRunID = MMT.DataRunID AND
							RDSMK.DataSetID = MMT.DataSetID AND
							RDSMK.MetricID = MMT.MetricID AND
							RDSMK.PopulationID = MMT.PopulationID AND
							RDSMK.ProductLineID = MMT.ProductLineID
				LEFT OUTER JOIN #MetricTotals AS XT
						ON RDSMK.DataRunID = XT.DataRunID AND
							RDSMK.DataSetID = XT.DataSetID AND
							RDSMK.MetricID = XT.MetricID AND
							RDSMK.PopulationID = XT.PopulationID AND
							RDSMK.ProductLineID = XT.ProductLineID
		WHERE	(RDSMK.DataRunID = @DataRunID) AND
				((@MeasClassID IS NULL) OR (RDSMK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSMK.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSMK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSMK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSMK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSMK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSMK.TopMeasClassID = @TopMeasClassID)) AND
				((@ResultTypeID IS NULL) OR (@ResultTypeID NOT IN (2, 3)) OR (RDSMK.IsHybrid = 1))
		GROUP BY RDSMK.AgeBandSegDescr,
				RDSMK.AgeBandSegID,
				RDSMK.BenefitDescr,
				RDSMK.BenefitID,
				RDSMK.DataRunID,
				RDSMK.DataSetID,
				RDSMK.Gender,
				RDSMK.MeasClassDescr,
				RDSMK.MeasClassID,
				RDSMK.MeasureAbbrev,
				RDSMK.MeasureDescr,
				RDSMK.MeasureGuid,
				RDSMK.MeasureID,
				RDSMK.MetricAbbrev,
				RDSMK.MetricDescr,
				RDSMK.MetricGuid,
				RDSMK.MetricID,
				RDSMK.MetricKeyID,
				RDSMK.PopulationID,
				RDSMK.ProductLineID,
				RDSMK.SubMeasClassDescr,
				RDSMK.SubMeasClassID,
				RDSMK.TopMeasClassDescr,
				RDSMK.TopMeasClassID
		ORDER BY RDSMK.MeasClassDescr, RDSMK.MetricAbbrev, RDSMK.PopulationID, RDSMK.ProductLineID, RDSMK.AgeBandSegID 
	
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
GRANT EXECUTE ON  [Report].[GetMeasureSummaryByMedicalGroup] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureSummaryByMedicalGroup] TO [Reports]
GO
