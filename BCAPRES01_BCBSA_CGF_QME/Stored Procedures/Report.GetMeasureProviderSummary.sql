SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/28/2012
-- Description:	Retrieves the measure/metric-based summary report for providers.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureProviderSummary]
(
	@AgeBandSegID int = NULL, 
	@CustomerProviderID varchar(32) = NULL,
	@DataRunID int,
	@DSProviderID int = NULL,
	@Gender tinyint = NULL,
	@MeasClassID smallint = NULL,
	@MeasureID int = NULL,
	@MedGrpID int = NULL,
	@MetricID int = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
	@RegionName varchar(64) = NULL,
	@ReportInfoType varchar(32) = 'IsDenominator',
	@ResultTypeID tinyint = NULL,
	@SubMeasClassID smallint = NULL,
	@SubRegionName varchar(64) = NULL,
	@TopMeasClassID smallint = NULL,
	@UserName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	SET @CustomerProviderID = NULLIF(REPLACE(REPLACE(REPLACE(REPLACE(@CustomerProviderID, '*', '%'), '?', '_'), '%%%', '%'), '%%', '%'), '%');

	IF NULLIF(@CustomerProviderID, '%') IS NULL AND 
		@DSProviderID IS NULL AND
		@RegionName IS NULL AND
		@SubRegionName IS NULL AND
		@MedGrpID IS NULL
		SET @DSProviderID = -1; --Keeps the report from returning all rows if no provider or medical group filter is specified.

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
		SET @LogObjectName = 'GetMeasureProviderSummary'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DSProviderID', @DSProviderID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasClassID', @MeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MedGrpID', @MedGrpID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@RegionName', @RegionName);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ReportInfoType', @ReportInfoType);
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
		
		
		DECLARE @FilterMedicalGroups bit;
		
		CREATE TABLE #MedicalGroupProviders
		(
			DSProviderID bigint NOT NULL,
			MedGrpID int NULL
		);
		
		IF @DSProviderID IS NOT NULL OR
			@MedGrpID IS NOT NULL OR
			@RegionName IS NOT NULL OR
			@SubRegionName IS NOT NULL OR
			@CustomerProviderID IS NOT NULL
			BEGIN
				IF (@RegionName = '(No Medical Group Assigned)') OR (@SubRegionName = '(No Medical Group Assigned)') 
					SET @MedGrpID = -1;
			
				
				INSERT INTO #MedicalGroupProviders
				SELECT DISTINCT
						RDSMPK.DSProviderID,
						RDSMPK.MedGrpID
				FROM	Result.DataSetMemberProviderKey AS RDSMPK WITH(NOLOCK)
						INNER JOIN Result.DataSetProviderKey AS RDSPK WITH(NOLOCK)
								ON RDSPK.DataRunID = RDSMPK.DataRunID AND
									RDSPK.DataSetID = RDSMPK.DataSetID AND
									RDSPK.DSProviderID = RDSMPK.DSProviderID
						INNER JOIN Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
								ON RDSMPK.DataRunID = RDSMGK.DataRunID AND
									RDSMPK.DataSetID = RDSMGK.DataSetID AND
									RDSMPK.MedGrpID = RDSMGK.MedGrpID 
									
				WHERE	RDSMPK.DataRunID = @DataRunID AND
						RDSMPK.DSProviderID IS NOT NULL AND
						(
							((@CustomerProviderID IS NULL) OR (RDSPK.CustomerProviderID = @CustomerProviderID) OR (RDSPK.CustomerProviderID LIKE @CustomerProviderID)) AND
							((@DSProviderID IS NULL) OR (RDSMPK.DSProviderID = @DSProviderID)) AND
							((@MedGrpID IS NULL) OR (RDSMPK.MedGrpID = @MedGrpID)) AND
							((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName)) AND
							((@SubRegionName IS NULL) OR (RDSMGK.SubRegionName = @SubRegionName))
						) OR
						((@MedGrpID = -1) AND (RDSMPK.MedGrpID IS NULL));
				
				CREATE UNIQUE CLUSTERED INDEX IX_#MedicalGroupProviders ON #MedicalGroupProviders (DSProviderID, MedGrpID);
						
				SET @FilterMedicalGroups = 1;
			END
		ELSE
			BEGIN
				SET @FilterMedicalGroups = 0;
			END

		--THE RETURNED RESULTSET------------------------------------------
		SELECT	
				--RDSXK.AgeBandSegDescr,
				--RDSXK.AgeBandSegID,
				--RDSXK.BenefitDescr,
				--RDSXK.BenefitID,
				--ISNULL(COUNT(DISTINCT RMPS.KeyDate), 0) AS CountEvents,
				--ISNULL(COUNT(DISTINCT RMPS.DSMemberID), 0) AS CountMembers,
				ISNULL(SUM(DISTINCT RMPS.CountEvents), 0) AS CountEvents,
				ISNULL(SUM(DISTINCT RMPS.CountMembers), 0) AS CountMembers,
				ISNULL(COUNT(DISTINCT RMPS.DSProviderID), 0) AS CountProviders,
				0 AS CountMonths,
				ISNULL(SUM(DISTINCT RMPS.CountRecords), 0) AS CountRecords,
				MIN(RDSPVK.CustomerProviderID) AS CustomerProviderID,
				RDSXK.DataRunID,
				RDSXK.DataSetID,
				ISNULL(SUM(CAST(RMPS.[Days] AS int)), 0) AS [Days],
				RMPS.DSProviderID,
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
				--RMPS.Gender,
				MIN(CASE RMPS.Gender WHEN 0 THEN 'Female' WHEN 1 THEN 'Male' ELSE 'Unknown' END) AS GenderDescr,
				ISNULL(SUM(CAST(RMPS.IsDenominator AS int)), 0) AS [IsDenominator],
				ISNULL(SUM(CAST(RMPS.IsExclusion AS int)), 0) AS [IsExclusion],
				ISNULL(SUM(CAST(CASE WHEN RMPS.IsDenominator = 1 THEN CASE RMPS.IsNumerator WHEN 1 THEN 0 WHEN 0 THEN 1 END WHEN RMPS.IsExclusion = 1 THEN 0 END AS int)), 0) AS IsNegative,
				ISNULL(SUM(CAST(RMPS.IsNumerator AS int)), 0) AS [IsNumerator],
				MIN(RMFK.KeyFieldDescr) AS KeyFieldDescr,
				MIN(RMFK.KeyFieldID) AS KeyFieldID,
				MIN(RMFK.KeyFieldName) AS KeyFieldName,
				RDSXK.MeasClassDescr,
				RDSXK.MeasClassID,
				RDSXK.MeasureAbbrev,
				RDSXK.MeasureDescr,
				RDSXK.MeasureGuid,
				RDSXK.MeasureID,
				RDSXK.MetricAbbrev,
				RDSXK.MetricDescr,
				RDSXK.MetricGuid,
				RDSXK.MetricID,
				--RDSXK.MetricKeyID,
				MIN(RDSPK.Descr) AS PopulationDescr,
				RDSXK.PopulationID,
				MIN(RDSPK.PopulationNum) AS PopulationNum,
				RDSXK.ProductLineID,
				MIN(RDSPVK.DisplayID) AS ProviderDisplayID,
				MIN(RDSPVK.ProviderName) AS ProviderNameDisplay,
				MIN(RDSPVK.ProviderName) AS ProviderNameObscure,
				ISNULL(SUM(RMPS.Qty), 0) AS Qty,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMPS.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(ISNULL(RMPS.ResultTypeID, @ResultTypeID)) AS ResultTypeID,
				CAST(MIN(CAST(RMFK.ShowHeadersEachMetric AS smallint)) AS bit) AS ShowHeadersEachMetric,
				CAST(MIN(CAST(RMFK.ShowOnReport AS smallint)) AS bit) AS ShowOnReport,
				RDSXK.SubMeasClassDescr,
				RDSXK.SubMeasClassID,
				RDSXK.TopMeasClassDescr,
				RDSXK.TopMeasClassID,
				0 AS TotMQty,
				0 AS TotXQty
		FROM	Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
				INNER JOIN Result.DataSetPopulationKey AS RDSPK WITH(NOLOCK)
						ON RDSXK.DataSetID = RDSPK.DataSetID AND
							RDSXK.DataRunID = RDSPK.DataRunID AND
							RDSXK.PopulationID = RDSPK.PopulationID
				INNER JOIN #ReportMeasureFieldKey AS RMFK
						ON RDSXK.MeasureID = RMFK.MeasureID AND
							RMFK.ShowOnReport = 1
				INNER JOIN Result.MeasureProviderSummary AS RMPS WITH(NOLOCK)
						ON RDSXK.DataSetID = RMPS.DataSetID AND
							RDSXK.DataRunID = RMPS.DataRunID AND
							RDSXK.MeasureID = RMPS.MeasureID AND
							RDSXK.MetricID = RMPS.MetricID AND
							RDSXK.PopulationID = RMPS.PopulationID AND
							RDSXK.ProductLineID = RMPS.ProductLineID AND
							((RDSXK.AgeBandSegID = RMPS.AgeBandSegID) OR (RDSXK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMPS.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = 255) AND (RMPS.ResultTypeID NOT IN (2, 3))) OR 
								(RMPS.ResultTypeID = @ResultTypeID)
							)
				INNER JOIN Result.DataSetProviderKey AS RDSPVK WITH(NOLOCK)
						ON RDSXK.DataRunID = RDSPVK.DataRunID AND
							RDSXK.DataSetID = RDSPVK.DataSetID AND
							RMPS.DataRunID = RDSPVK.DataRunID AND
							RMPS.DataSetID = RDSPVK.DataSetID AND
							RMPS.DSProviderID = RDSPVK.DSProviderID
		WHERE	(RDSXK.DataRunID = @DataRunID) AND
				((RDSXK.TopMeasClassID <> 1) OR ((RDSXK.TopMeasClassID = 1) AND (RMPS.IsDenominator = 1))) AND
				((@AgeBandSegID IS NULL) OR (RMPS.AgeBandSegID = @AgeBandSegID)) AND
				((@Gender IS NULL) OR (RMPS.Gender = @Gender)) AND
				((@MeasClassID IS NULL) OR (RDSXK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSXK.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSXK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSXK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSXK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSXK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSXK.TopMeasClassID = @TopMeasClassID)) AND
				--(
				--	((@ReportInfoType IN ('CountEvents', 'Events')) AND (RMPS.DSMemberID IS NOT NULL) AND (RMPS.KeyDate IS NOT NULL)) OR
				--	((@ReportInfoType IN ('CountMembers', 'Members', 'CountMonths', 'Months')) AND (RMPS.DSMemberID IS NOT NULL)) OR
				--	((@ReportInfoType = 'CountRecords')) OR
				--	((@ReportInfoType IN ('AvgDays', 'Days', '[Days]', 'DaysPer1000MM')) AND (RMPS.[Days] > 0)) OR
				--	((@ReportInfoType IN ('IsDenominator', 'Score')) AND ((RMPS.IsDenominator = 1) OR (RMPS.ResultTypeID >= 4))) OR
				--	((@ReportInfoType = 'IsExclusion') AND (RMPS.IsExclusion = 1)) OR
				--	((@ReportInfoType = 'IsNegative') AND (RMPS.IsNumerator = 0) AND (RMPS.IsDenominator = 1)) OR
				--	((@ReportInfoType = 'IsNumerator') AND (RMPS.IsNumerator = 1) AND (RMPS.IsDenominator = 1)) OR
				--	((@ReportInfoType IN ('AvgDays', 'Qty', 'PercentTotMQty', 'PercentTotXQty', 'QtyPer1000MM', 'QtyPerMM')) AND (RMPS.Qty > 0)) 
				--) AND
				((@FilterMedicalGroups = 0) OR (RMPS.DSProviderID IN (SELECT DSProviderID FROM #MedicalGroupProviders AS tMGP WHERE tMGP.MedGrpID = RMPS.MedGrpID)))
		GROUP BY 
				--RDSXK.AgeBandSegDescr,
				--RDSXK.AgeBandSegID,
				--RDSXK.BenefitDescr,
				--RDSXK.BenefitID,
				RDSXK.DataRunID,
				RDSXK.DataSetID,
				RMPS.DSProviderID,
				--RMPS.Gender,
				RDSXK.MeasClassDescr,
				RDSXK.MeasClassID,
				RDSXK.MeasureAbbrev,
				RDSXK.MeasureDescr,
				RDSXK.MeasureGuid,
				RDSXK.MeasureID,
				RDSXK.MetricAbbrev,
				RDSXK.MetricDescr,
				RDSXK.MetricGuid,
				RDSXK.MetricID,
				--RDSXK.MetricKeyID,
				RDSXK.PopulationID,
				RDSXK.ProductLineID,
				RMPS.ResultTypeID,
				RDSXK.SubMeasClassDescr,
				RDSXK.SubMeasClassID,
				RDSXK.TopMeasClassDescr,
				RDSXK.TopMeasClassID
		ORDER BY MeasClassDescr, MetricAbbrev, PopulationID, ProductLineID, 
				/*AgeBandSegID,*/ ProviderNameDisplay, CustomerProviderID 
	
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
GRANT EXECUTE ON  [Report].[GetMeasureProviderSummary] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureProviderSummary] TO [Reports]
GO
