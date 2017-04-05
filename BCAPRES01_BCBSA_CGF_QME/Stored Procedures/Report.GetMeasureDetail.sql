SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the measure/metric-based detail (member/event-level) report.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureDetail]
(
	@AgeBandSegID int = NULL, 
	@DataRunID int,
	@DSProviderID int = NULL,
	@EnrollGroupID int = NULL,
	@Gender tinyint = NULL,
	@MeasClassID smallint = NULL,
	@MeasureID int = NULL,
	@MedGrpID int = NULL,
	@MetricID int = NULL,
	@PayerID smallint = NULL,
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
		SET @LogObjectName = 'GetMeasureDetail'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@DSProviderID', @DSProviderID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@EnrollGroupID', @EnrollGroupID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasClassID', @MeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MedGrpID', @MedGrpID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PayerID', @PayerID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@RegionName', @RegionName);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ReportInfoType', @ReportInfoType);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ResultTypeID', @ResultTypeID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@SubMeasClassID', @SubMeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@SubRegionName', @SubRegionName);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@TopMeasClassID', @TopMeasClassID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@UserName', @UserName);
		
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
		WHERE	RMFK.ReportType = 'Detail';
		
		CREATE UNIQUE CLUSTERED INDEX IX_#ReportMeasureFieldKey ON #ReportMeasureFieldKey (MeasureID);
		
		
		DECLARE @FilterMedicalGroups bit;
		
		CREATE TABLE #MedicalGroupMembers
		(
			DSMemberID bigint NOT NULL
		);
		
		IF @DSProviderID IS NOT NULL OR
			@MedGrpID IS NOT NULL OR
			@RegionName IS NOT NULL OR
			@SubRegionName IS NOT NULL
			BEGIN
				IF (@RegionName = '(No Medical Group Assigned)') OR (@SubRegionName = '(No Medical Group Assigned)') 
					SET @MedGrpID = -1;
			
				
				INSERT INTO #MedicalGroupMembers
				SELECT DISTINCT
						DSMemberID
				FROM	Result.DataSetMemberProviderKey AS RDSMPK WITH(NOLOCK)
						LEFT OUTER JOIN Result.DataSetMedicalGroupKey AS RDSMGK WITH(NOLOCK)
								ON RDSMPK.DataRunID = RDSMGK.DataRunID AND
									RDSMPK.DataSetID = RDSMGK.DataSetID AND
									RDSMPK.MedGrpID = RDSMGK.MedGrpID
									 
				WHERE	(RDSMPK.DataRunID = @DataRunID) AND
						(
							((@DSProviderID IS NULL) OR (RDSMPK.DSProviderID = @DSProviderID)) AND
							((@MedGrpID IS NULL) OR (RDSMPK.MedGrpID = @MedGrpID)) AND
							((@RegionName IS NULL) OR (RDSMGK.RegionName = @RegionName)) AND
							((@SubRegionName IS NULL) OR (RDSMGK.SubRegionName = @SubRegionName))
						) OR
						((@MedGrpID = -1) AND (RDSMPK.MedGrpID IS NULL));
				
				CREATE UNIQUE CLUSTERED INDEX IX_#MedicalGroupMembers ON #MedicalGroupMembers (DSMemberID);
						
				SET @FilterMedicalGroups = 1;
			END
		ELSE
			BEGIN
				SET @FilterMedicalGroups = 0;
			END

		--THE RETURNED RESULTSET------------------------------------------
		SELECT	RDSXK.AgeBandSegDescr,
				RDSXK.AgeBandSegID,
				RDSXK.BenefitDescr,
				RDSXK.BenefitID,
				ISNULL(COUNT(DISTINCT RMD.KeyDate), 0) AS CountEvents,
				ISNULL(COUNT(DISTINCT RMD.DSMemberID), 0) AS CountMembers,
				0 AS CountMonths,
				ISNULL(COUNT(DISTINCT RMD.ResultRowID), 0) AS CountRecords,
				MIN(RDSMK.CustomerMemberID) AS CustomerMemberID,
				RDSXK.DataRunID,
				RDSXK.DataSetID,
				ISNULL(SUM(CAST(RMD.[Days] AS int)), 0) AS [Days],
				RMD.DSMemberID,
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
				RMD.Gender,
				MIN(CASE RMD.Gender WHEN 0 THEN 'Female' WHEN 1 THEN 'Male' ELSE 'Unknown' END) AS GenderDescr,
				ISNULL(SUM(CAST(RMD.IsDenominator AS int)), 0) AS [IsDenominator],
				ISNULL(SUM(CAST(RMD.IsExclusion AS int)), 0) AS [IsExclusion],
				ISNULL(SUM(CAST(CASE WHEN RMD.IsDenominator = 1 THEN CASE RMD.IsNumerator WHEN 1 THEN 0 WHEN 0 THEN 1 END WHEN RMD.IsExclusion = 1 THEN 0 END AS int)), 0) AS IsNegative,
				ISNULL(SUM(CAST(RMD.IsNumerator AS int)), 0) AS [IsNumerator],
				MIN(RMFK.KeyFieldDescr) AS KeyFieldDescr,
				MIN(RMFK.KeyFieldID) AS KeyFieldID,
				MIN(RMFK.KeyFieldName) AS KeyFieldName,
				RMD.KeyDate,
				RDSXK.MeasClassDescr,
				RDSXK.MeasClassID,
				RDSXK.MeasureAbbrev,
				RDSXK.MeasureDescr,
				RDSXK.MeasureGuid AS MeasureGuid,
				RDSXK.MeasureID,
				MIN(RDSMK.DisplayID) AS MemberDisplayID,
				MIN(RDSMK.DOB) AS MemberDOB,
				MIN(RDSMK.NameDisplay) AS MemberNameDisplay,
				MIN(RDSMK.NameObscure) AS MemberNameObscure,
				MIN(RDSMK.SsnDisplay) AS MemberSsnDisplay,
				MIN(RDSMK.SsnObscure) AS MemberSsnObscure,
				RDSXK.MetricAbbrev,
				RDSXK.MetricDescr,
				RDSXK.MetricGuid AS MetricGuid,
				RDSXK.MetricID,
				RDSXK.MetricKeyID,
				MIN(RDSPK.Descr) AS PopulationDescr,
				RDSXK.PopulationID,
				MIN(RDSPK.PopulationNum) AS PopulationNum,
				RDSXK.ProductLineID,
				ISNULL(SUM(RMD.Qty), 0) AS Qty,
				Measure.GetResultTypeDescription(MIN(COALESCE(RMD.ResultTypeID, RMFK.ResultTypeID, @ResultTypeID))) AS ResultTypeDescr,
				MIN(ISNULL(RMD.ResultTypeID, @ResultTypeID)) AS ResultTypeID,
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
				INNER JOIN Result.MeasureDetail_Classic AS RMD WITH(NOLOCK)
						ON RDSXK.DataSetID = RMD.DataSetID AND
							RDSXK.DataRunID = RMD.DataRunID AND
							RDSXK.MeasureID = RMD.MeasureID AND
							RDSXK.MetricID = RMD.MetricID AND
							RDSXK.PopulationID = RMD.PopulationID AND
							RDSXK.ProductLineID = RMD.ProductLineID AND
							(RMD.EnrollGroupID = @EnrollGroupID OR @EnrollGroupID IS NULL) AND
							(RMD.PayerID = @PayerID OR @PayerID IS NULL) AND
							((RDSXK.AgeBandSegID = RMD.AgeBandSegID) OR (RDSXK.AgeBandSegID IS NULL)) AND
							(
								((@ResultTypeID IS NULL) AND (RMD.ResultTypeID = RMFK.ResultTypeID)) OR 
								((@ResultTypeID = 255) AND (RMD.ResultTypeID NOT IN (2, 3))) OR 
								(RMD.ResultTypeID = @ResultTypeID)
							)
				INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
						ON RDSXK.DataRunID = RDSMK.DataRunID AND
							RDSXK.DataSetID = RDSMK.DataSetID AND
							RMD.DataRunID = RDSMK.DataRunID AND
							RMD.DataSetID = RDSMK.DataSetID AND
							RMD.DSMemberID = RDSMK.DSMemberID
		WHERE	(RDSXK.DataRunID = @DataRunID) AND
				((@AgeBandSegID IS NULL) OR (RMD.AgeBandSegID = @AgeBandSegID)) AND
				((@Gender IS NULL) OR (RMD.Gender = @Gender)) AND
				((@MeasClassID IS NULL) OR (RDSXK.MeasClassID = @MeasClassID)) AND
				((@MeasureID IS NULL) OR (RDSXK.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RDSXK.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RDSXK.PopulationID = @PopulationID)) AND
				((@ProductLineID IS NULL) OR (RDSXK.ProductLineID = @ProductLineID)) AND
				((@SubMeasClassID IS NULL) OR (RDSXK.SubMeasClassID = @SubMeasClassID)) AND
				((@TopMeasClassID IS NULL) OR (RDSXK.TopMeasClassID = @TopMeasClassID)) AND
				(
					((@ReportInfoType IN ('CountEvents', 'Events')) AND (RMD.DSMemberID IS NOT NULL) AND (RMD.KeyDate IS NOT NULL)) OR
					((@ReportInfoType IN ('CountMembers', 'Members', 'CountMonths', 'Months')) AND (RMD.DSMemberID IS NOT NULL)) OR
					((@ReportInfoType = 'CountRecords')) OR
					((@ReportInfoType IN ('AvgDays', 'Days', '[Days]', 'DaysPer1000MM')) AND (RMD.[Days] > 0)) OR
					((@ReportInfoType IN ('IsDenominator', 'Score')) AND ((RMD.IsDenominator = 1) OR (RMD.ResultTypeID >= 4))) OR
					((@ReportInfoType = 'IsExclusion') AND (RMD.IsExclusion = 1)) OR
					((@ReportInfoType = 'IsNegative') AND (RMD.IsNumerator = 0) AND (RMD.IsDenominator = 1)) OR
					((@ReportInfoType = 'IsNumerator') AND (RMD.IsNumerator = 1) AND (RMD.IsDenominator = 1)) OR
					((@ReportInfoType IN ('AvgDays', 'Qty', 'PercentTotMQty', 'PercentTotXQty', 'QtyPer1000MM', 'QtyPerMM')) AND (RMD.Qty > 0)) 
				) AND
				((@FilterMedicalGroups = 0) OR (RMD.DSMemberID IN (SELECT DSMemberID FROM #MedicalGroupMembers)))
		GROUP BY RDSXK.AgeBandSegDescr,
				RDSXK.AgeBandSegID,
				RDSXK.BenefitDescr,
				RDSXK.BenefitID,
				RDSXK.DataRunID,
				RDSXK.DataSetID,
				RMD.DSMemberID,
				RMD.Gender,
				RMD.KeyDate,
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
				RDSXK.MetricKeyID,
				RDSXK.PopulationID,
				RDSXK.ProductLineID,
				RMD.ResultTypeID,
				RDSXK.SubMeasClassDescr,
				RDSXK.SubMeasClassID,
				RDSXK.TopMeasClassDescr,
				RDSXK.TopMeasClassID
		ORDER BY MeasClassDescr, MetricAbbrev, PopulationID, ProductLineID, 
				AgeBandSegID, MemberNameDisplay, CustomerMemberID 
	
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
GRANT EXECUTE ON  [Report].[GetMeasureDetail] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureDetail] TO [Reports]
GO
