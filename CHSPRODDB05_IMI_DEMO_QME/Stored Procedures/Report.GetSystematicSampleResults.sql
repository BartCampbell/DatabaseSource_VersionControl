SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 2/12/2013
-- Description:	Based on a report originally created for Commonwealth Care Alliance, returns a detailed systematic sampling roster from the measure engine.
-- =============================================
CREATE PROCEDURE [Report].[GetSystematicSampleResults]
(
	@DataRunID int,
	@IncludeAuxiliary bit = 1,
	@IsAuditRoster bit = 0,
	@MeasureID int = NULL,
	@MetricID int = NULL,
	@PopulationID int = NULL,
	@ProductLineID smallint = NULL,
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
		SET @LogObjectName = 'GetSystematicSampleResults'; 
		SET @LogObjectSchema = 'Report'; 
					
		DECLARE @CountRecords int;
		
		---------------------------------------------------------------------------
		
		DECLARE @Parameters AS Report.ReportParameters;
		
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES ('@DataRunID', @DataRunID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@IncludeAuxiliary', @IncludeAuxiliary);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MeasureID', @MeasureID);
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@MetricID', @MetricID);	
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@PopulationID', @PopulationID);	
		INSERT INTO @Parameters (ParameterName, [Value]) VALUES	('@ProductLineID', @ProductLineID);	
		
		IF OBJECT_ID('tempdb..#DefaultProductLines') IS NOT NULL
			DROP TABLE #DefaultProductLines;
			
		SELECT * INTO #DefaultProductLines FROM Result.GetDefaultMeasureProductLines(@DataRunID, @ProductLineID);
		CREATE UNIQUE CLUSTERED INDEX IX_#DefaultProductLines ON #DefaultProductLines (DataRunID, PopulationID, MeasureID);

		SELECT	NMMG.Descr,
				NMMG.MeasureGroup,
				NMMG.MeasureGroupType,
			    NMMGM.Metric
		INTO	#MRR_MeasureGroupMetrics
		FROM	Ncqa.MRR_MeasureGroupMetrics AS NMMGM WITH(NOLOCK)
				INNER JOIN Ncqa.MRR_MeasureGroups AS NMMG WITH(NOLOCK)
						ON NMMGM.MeasureGroup = NMMG.MeasureGroup;

		CREATE UNIQUE CLUSTERED INDEX IX_#MRR_MeasureGroupMetrics ON #MRR_MeasureGroupMetrics (Metric, MeasureGroupType);

		SELECT	RDSMK.CustomerMemberID,
				RDSMK.DSMemberID,
				RDSMK.DisplayID,
				RDSMK.IhdsMemberID,
				CONVERT(smallint, RSS.IsAuxiliary) AS IsAuxiliary,
				CONVERT(smallint, RMD.IsDenominator) AS IsDenominator,
				CONVERT(smallint, RMD.IsExclusion) AS IsExclusion,
				CONVERT(smallint, RMD.IsIndicator) AS IsIndicator,
				CONVERT(smallint, RMD.IsNumerator) AS IsNumerator,
				CONVERT(smallint, RMD.IsNumeratorAdmin) AS IsNumeratorAdmin,
				CONVERT(smallint, RMD.IsNumeratorMedRcd) AS IsNumeratorMedRcd,
				RMD.KeyDate,
				MMXR.Abbrev AS MeasureAbbrev,
				MXT.Descr AS MeasureExclusionTypeDescr,
				MXT.ExclusionTypeID AS MeasureExclusionTypeID,
				RMD.MeasureID,
				RMD.MeasureXrefID,
				RDSMK.DOB AS MemberDOB,
				RDSMK.Gender AS MemberGender,
				MG.Abbrev AS MemberGenderAbbrev,
				RDSMK.NameFirst AS MemberNameFirst,
				RDSMK.NameLast AS MemberNameLast,
				RDSMK.SsnDisplay AS MemberSSN,
				MXXR.Abbrev AS MetricAbbrev,
				MXXR.Descr AS MetricDescr,
				RMD.MetricID,
				RMD.MetricXrefID,
				ISNULL(LE.EndDate, LE.BeginDate) AS NumeratorDate,
				RMD.ResultRowGuid,
				RMD.ResultRowID,
				RSS.SysSampleOrder
		INTO	#Results
		FROM	Batch.SystematicSamples AS BSS WITH(NOLOCK)
				INNER JOIN Result.SystematicSamples AS RSS WITH(NOLOCK)
						ON BSS.SysSampleID = RSS.SysSampleID AND
							BSS.DataRunID = @DataRunID
				INNER JOIN Result.MeasureDetail_Classic AS RMD WITH(NOLOCK)
						ON RSS.SysSampleRefID = RMD.SysSampleRefID AND
							RMD.DataRunID = @DataRunID AND
							RMD.ResultTypeID = 3
				INNER JOIN #DefaultProductLines AS GDMPL
						ON RMD.DataRunID = GDMPL.DataRunID AND
							RMD.DataSetID = GDMPL.DataSetID AND
							RMD.MeasureID = GDMPL.MeasureID AND
							RMD.MeasureXrefID = GDMPL.MeasureXrefID AND
							RMD.PopulationID = GDMPL.PopulationID AND
							RMD.ProductLineID = GDMPL.ProductLineID
				LEFT OUTER JOIN Measure.ExclusionTypes AS MXT WITH(NOLOCK)
						ON RMD.ExclusionTypeID = MXT.ExclusionTypeID
				LEFT OUTER JOIN Result.MetricXrefs AS MXXR WITH(NOLOCK)
						ON RMD.MetricXrefID = MXXR.MetricXrefID
				LEFT OUTER JOIN Result.MeasureXrefs AS MMXR WITH(NOLOCK)
						ON RMD.MeasureXrefID = MMXR.MeasureXrefID
				OUTER APPLY (
								SELECT TOP 1 
										tRMVD.*
								FROM	Result.MeasureEventDetail AS tRMVD WITH(NOLOCK)
										INNER JOIN Measure.MappingTypes AS tMMT WITH(NOLOCK)
												ON tMMT.MapTypeID = tRMVD.MapTypeID AND
													tMMT.Descr = 'Numerator'
								WHERE	tRMVD.ResultTypeID = 1 AND
										tRMVD.MetricID = RMD.MetricID AND
										tRMVD.MeasureID = RMD.MeasureID AND
										tRMVD.DSEntityID = RMD.SourceNumerator AND
										tRMVD.DSMemberID = RMD.DSMemberID AND
										tRMVD.DataRunID = @DataRunID
								ORDER BY ISNULL(tRMVD.EndDate, tRMVD.BeginDate)
							) AS LE
				INNER JOIN Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
						ON RDSMK.DataRunID = @DataRunID AND
							RMD.DSMemberID = RDSMK.DSMemberID
				INNER JOIN Member.Genders AS MG
						ON RDSMK.Gender = MG.Gender
		WHERE	((@IncludeAuxiliary = 1) OR (RSS.IsAuxiliary = 0)) AND
				((@MeasureID IS NULL) OR (RMD.MeasureID = @MeasureID)) AND
				((@MetricID IS NULL) OR (RMD.MetricID = @MetricID)) AND
				((@PopulationID IS NULL) OR (RMD.PopulationID = @PopulationID))

		SELECT	CONVERT(varchar(36), ResultRowGuid) AS [Record ID],
				CustomerMemberID AS [Customer Member ID],
				DSMemberID AS [Member Ref ID],
				DisplayID AS [IMI Member ID],
				MemberDOB AS [Member DOB],
				MemberGenderAbbrev AS [Member Gender],
				MemberNameFirst AS [Member First Name],
				MemberNameLast AS [Member Last Name],
				MemberSSN AS [Member SSN],
				MeasureAbbrev AS [Measure],
				MeasureExclusionTypeDescr AS [Measure Exclusion Type],
				MeasureExclusionTypeID AS [Measure Exclusion Type ID],
				MeasureID AS [Measure ID],
				MeasureXrefID AS [Measure Ref ID],
				MetricAbbrev AS [Metric],
				MetricDescr AS [Metric Description],
				MetricID AS [Metric ID],
				MetricXrefID AS [Metric Ref ID],
				NMMGM.MeasureGroup AS [MRR Measure Group],
				NMMGM.Descr AS [MRR Measure Group Description],
				KeyDate AS [Key Event Date],
				IsDenominator AS [Denominator],
				IsExclusion AS [Exclusion],
				IsNumerator AS [Numerator],
				IsNumeratorAdmin AS [Numerator, Admin],
				IsNumeratorMedRcd AS [Numerator, Med Rcd],
				NumeratorDate AS [Numerator Event Date, Admin],
				SysSampleOrder AS [Sample Order],
				IsAuxiliary AS [Oversample]
		FROM	#Results AS t
				LEFT OUTER JOIN #MRR_MeasureGroupMetrics AS NMMGM WITH(NOLOCK)
						ON t.MetricAbbrev = NMMGM.Metric AND
							(t.IsExclusion = 1 AND NMMGM.MeasureGroupType = 'X' OR
							t.IsExclusion = 0 AND NMMGM.MeasureGroupType = 'N')
		WHERE	((@IsAuditRoster = 0) OR (t.IsExclusion = 1) OR (t.IsNumeratorMedRcd = 1))
		ORDER BY MeasureAbbrev, MetricAbbrev, SysSampleOrder;
		
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
GRANT EXECUTE ON  [Report].[GetSystematicSampleResults] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetSystematicSampleResults] TO [Reports]
GO
