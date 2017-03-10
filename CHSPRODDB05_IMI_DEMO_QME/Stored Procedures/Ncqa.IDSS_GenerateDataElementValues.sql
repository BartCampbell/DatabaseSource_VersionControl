SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/2/2012
-- Description:	Applies IDSS data element information from a previous MeasureSet to a new MeasureSet.
-- =============================================
CREATE PROCEDURE [Ncqa].[IDSS_GenerateDataElementValues]
(
	@DataRunID int,
	@HybridOnly bit = 0,
	@OrganizationID varchar(16),
	@OrganizationName varchar(64),
	@OutputResultset bit = 1,
	@OutputXml bit = 1,
	@PayerID int = NULL,
	@PopulationID int,
	@ProductLineID smallint,
	@SubmissionID varchar(16),
	@VendorID nvarchar(128)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @EndInitSeedDate datetime;
	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;

	SELECT @DataSetID = DataSetID, @EndInitSeedDate = EndInitSeedDate, @MeasureSetID = MeasureSetID FROM Batch.DataRuns WHERE (DataRunID = @DataRunID);

	DECLARE @SourceDatabase nvarchar(128);
	SET @SourceDatabase = DB_NAME();

	DECLARE @ProductLineDescr nvarchar(32);
	SELECT @ProductLineDescr = Descr FROM Product.ProductLines AS PPL WHERE ProductLineID = @ProductLineID;

	DECLARE @Ansi_Warnings bit;
	SET @Ansi_Warnings = CASE WHEN (@@OPTIONS & 8) = 8 THEN 1 ELSE 0 END;

	IF OBJECT_ID('tempdb..#DataElements') IS NOT NULL
		DROP TABLE #DataElements;

	WITH MeasureResultTypes AS
	(  
	SELECT	NIRT.MeasureID,
			MAX(NIRT.ResultTypeID) AS ResultTypeID
	FROM	Ncqa.IDSS_ResultType AS NIRT
	WHERE	(NIRT.DataRunID = @DataRunID) AND
			(NIRT.PopulationID = @PopulationID) AND
			(NIRT.ProductLineID = @ProductLineID) AND
			((@PayerID IS NULL) OR (NIRT.PayerID = @PayerID))
	GROUP BY NIRT.MeasureID
	),
	Step1 AS
	(
		SELECT	A.Abbrev AS [Aggregrate],
				MX.BenefitID,
				C.DataType,
				C.IsDistinct,
				C.SourceSchema, 
				C.SourceTable, 
				CASE WHEN IC.DATA_TYPE = 'bit' THEN 'CONVERT(int, ' + QUOTENAME(C.SourceColumn) + ')' ELSE QUOTENAME(C.SourceColumn) END AS SourceColumn, 
				QUOTENAME(@SourceDatabase) + '.' + 
				QUOTENAME(C.SourceSchema) + '.' + 
				QUOTENAME(C.SourceTable) AS SourceObject,
				DE.AggregateID,
				DE.BitProductLines,
				DE.ExclusionTypeID,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.FromAgeMonths END AS FromAgeMonths,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.FromAgeTotMonths END AS FromAgeTotMonths,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.FromAgeYears END AS FromAgeYears,
				DE.Gender,
				DE.IdssColumnID,
				DE.IdssElementAbbrev,
				DE.IdssElementDescr,
				DE.IdssElementGuid,
				DE.IdssElementID,
				DE.IdssMeasure,
				DE.IdssMeasureDescr,
				DE.IsAuxiliary,
				DE.IsBaseSample,
				DE.IsInSample,
				DE.IsUnknownAge,
				DE.MeasureAbbrev,
				DE.MeasureID,
				DE.MeasureSetID,
				DE.MetricAbbrev,
				DE.MetricID,
				DE.PayerID,
				ISNULL(CASE WHEN C.IsResultTypeDriven = 1 THEN MRT.ResultTypeID END, DE.ResultTypeID) AS ResultTypeID,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.ToAgeMonths END AS ToAgeMonths,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.ToAgeTotMonths END AS ToAgeTotMonths,
				CASE WHEN DE.IsUnknownAge = 1 THEN -1 ELSE DE.ToAgeYears END AS ToAgeYears
		FROM	Ncqa.IDSS_DataElements AS DE WITH(NOLOCK)
				LEFT OUTER JOIN Measure.Metrics AS MX
						ON DE.MetricID = MX.MetricID
				LEFT OUTER JOIN MeasureResultTypes AS MRT
						ON DE.MeasureID = MRT.MeasureID
				INNER JOIN Measure.MeasureProductLines AS MMPL
						ON DE.MeasureID = MMPL.MeasureID AND
							MMPL.ProductLineID = @ProductLineID
				INNER JOIN Product.ProductLines AS PPL
						ON DE.BitProductLines & PPL.BitValue > 0 AND
							MMPL.ProductLineID = PPL.ProductLineID                      
				INNER JOIN Ncqa.IDSS_Columns AS C WITH (NOLOCK)
						ON DE.IdssColumnID = C.IdssColumnID AND
							C.SourceSchema IS NOT NULL AND
							C.SourceTable IS NOT NULL AND
							C.SourceColumn IS NOT NULL
				LEFT OUTER JOIN INFORMATION_SCHEMA.COLUMNS AS IC
						ON IC.TABLE_CATALOG = @SourceDatabase AND
							IC.TABLE_SCHEMA = C.SourceSchema AND
							IC.TABLE_NAME = C.SourceTable AND
							IC.COLUMN_NAME = C.SourceColumn
				LEFT OUTER JOIN Ncqa.IDSS_Aggregates AS A
						ON DE.AggregateID = A.AggregateID
		WHERE	(C.IsEnabled = 1) AND
				(DE.MeasureSetID = @MeasureSetID) AND
				((@HybridOnly = 0) OR (MRT.ResultTypeID IN (2, 3)))              
	),
	Step2 AS
	(
		SELECT 
				--SELECT portion...
				CONVERT(nvarchar(max), 'SELECT ') + 
							'CONVERT(nvarchar(64), ' +
							'CONVERT(' + i.DataType + ', ' +
							COALESCE('COALESCE(' + NULLIF(RTRIM(LTRIM(i.[Aggregrate])), '') + '(', 'MAX(') + 
							CASE WHEN i.IsDistinct = 1 THEN 'DISTINCT ' ELSE '' END + 
							i.SourceColumn + 
							')' +
							CASE WHEN LEN(RTRIM(LTRIM(i.[Aggregrate]))) > 0 THEN ', 0)' ELSE '' END +
							'))' AS SqlSelect,
							
				--FROM portion...
				CONVERT(nvarchar(max), 'FROM ') + i.SourceObject AS SqlFrom,
				
				--WHERE portion...
				CONVERT(nvarchar(max), 'WHERE (1 = 1)') + CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'MeasureID', 'ColumnId') IS NOT NULL AND 
									i.MeasureID IS NOT NULL
							THEN ' AND ([MeasureID] = ' + CONVERT(nvarchar(max), i.MeasureID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'MetricID', 'ColumnId') IS NOT NULL AND
									i.MetricID IS NOT NULL
							THEN ' AND ([MetricID] = ' + CONVERT(nvarchar(max), i.MetricID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'BenefitID', 'ColumnId') IS NOT NULL AND
									i.BenefitID IS NOT NULL
							THEN ' AND ([BenefitID] = ' + CONVERT(nvarchar(max), i.BenefitID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'AgeMonths', 'ColumnId') IS NOT NULL --Check for AgeMonths first
							THEN ' AND ([AgeMonths] BETWEEN ' + ISNULL(CONVERT(nvarchar(max), i.FromAgeTotMonths), '[AgeMonths]') + ' AND ' + 
													ISNULL(CONVERT(nvarchar(max), i.ToAgeTotMonths), '[AgeMonths]') + ')'
							WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'Age', 'ColumnId') IS NOT NULL --If no AgeMonths in table, use Age
							THEN ' AND ([Age] BETWEEN ' + ISNULL(CONVERT(nvarchar(max), i.FromAgeYears), '[Age]') + ' AND ' + 
													ISNULL(CONVERT(nvarchar(max), i.ToAgeYears), '[Age]') + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'ExclusionTypeID', 'ColumnId') IS NOT NULL AND
									i.ExclusionTypeID IS NOT NULL
							THEN ' AND ([ExclusionTypeID] = ' + CONVERT(nvarchar(max), i.ExclusionTypeID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'Gender', 'ColumnId') IS NOT NULL AND
									i.Gender IS NOT NULL
							THEN ' AND ([Gender] = ' + CONVERT(nvarchar(max), i.Gender) + ')'
							ELSE '' END + 
							CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'ResultTypeID', 'ColumnId') IS NOT NULL AND
									OBJECT_ID(i.SourceObject) <> ISNULL(OBJECT_ID(QUOTENAME(@SourceDatabase) + '.[Ncqa].[IDSS_ResultType]'), -1) AND
									i.ResultTypeID IS NOT NULL
							THEN ' AND ([ResultTypeID] = ' + CONVERT(nvarchar(max), i.ResultTypeID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'DataRunID', 'ColumnId') IS NOT NULL AND
									@DataRunID IS NOT NULL
							THEN ' AND ([DataRunID] = ' + CONVERT(nvarchar(max), @DataRunID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'DataSetID', 'ColumnId') IS NOT NULL AND
									@DataSetID IS NOT NULL
							THEN ' AND ([DataSetID] = ' + CONVERT(nvarchar(max), @DataSetID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'MeasureSetID', 'ColumnId') IS NOT NULL AND
									@MeasureSetID IS NOT NULL
							THEN ' AND ([MeasureSetID] = ' + CONVERT(nvarchar(max), @MeasureSetID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'PayerID', 'ColumnId') IS NOT NULL AND
									(@PayerID IS NOT NULL OR i.PayerID IS NOT NULL)
							THEN ' AND ([PayerID] = ' + CONVERT(nvarchar(max), ISNULL(@PayerID, i.PayerID)) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'PopulationID', 'ColumnId') IS NOT NULL AND		
									@PopulationID IS NOT NULL
							THEN ' AND ([PopulationID] = ' + CONVERT(nvarchar(max), @PopulationID) + ')'
							ELSE '' END + 
						CASE WHEN COLUMNPROPERTY(OBJECT_ID(i.SourceObject), 'ProductLineID', 'ColumnId') IS NOT NULL AND
									@ProductLineID IS NOT NULL
							THEN ' AND ([ProductLineID] = ' + CONVERT(nvarchar(max), @ProductLineID) + ')'
							ELSE '' END 
							AS SqlWhere, 
			i.*
		FROM Step1 AS i
	),
	Step3 AS 
	(
		SELECT	i.IdssElementID,
				i.IdssMeasure,
				i.SqlSelect + ' ' + i.SqlFrom + ' ' + i.SqlWhere AS SqlStatement
		FROM	Step2 AS i
	)
	SELECT	IdssElementID,
			IDENTITY(int, 1, 1) AS RowID,
			SqlStatement,
			CONVERT(nvarchar(64), NULL) AS Value
	INTO	#DataElements
	FROM	Step3
	ORDER BY IdssMeasure, IdssElementID;

	CREATE UNIQUE CLUSTERED INDEX IX_#DataElements ON #DataElements (RowID);


	IF @ProductLineID <> (SELECT ProductLineID FROM Product.ProductLines WHERE Abbrev = 'S')
	BEGIN;
		IF @Ansi_Warnings = 1
			SET ANSI_WARNINGS OFF;

		--INSERT "TLM" VALUES
		WITH DataElementValues AS
		(
			SELECT	SUM(CountMembers) AS CountMembers,
					RMS.DataRunID,
					RMS.DataSetID,
					DE.IdssElementID,
					DE.MeasureSetID,
					RMS.PopulationID,
					RMS.ProductLineID,
					DE.ProductTypeID
			FROM	Result.MeasureSummary AS RMS
					INNER JOIN Member.EnrollmentPopulationProductLines AS MNPP
							ON RMS.PopulationID = MNPP.PopulationID AND
								RMS.ProductLineID = MNPP.ProductLineID
					INNER JOIN Measure.Metrics AS MX
							ON RMS.MetricID = MX.MetricID AND
								MX.Abbrev = 'TLM'
					INNER JOIN Measure.Measures AS MM
							ON RMS.MeasureID = MM.MeasureID AND
								MM.Abbrev = 'TLM'
					INNER JOIN Product.Payers AS PP
							ON RMS.PayerID = PP.PayerID
					INNER JOIN Ncqa.IDSS_DataElements_TLM AS DE
							ON MM.MeasureSetID = DE.MeasureSetID AND
								PP.ProductTypeID = DE.ProductTypeID AND
								RMS.ProductLineID = DE.ProductLineID
			WHERE	(RMS.DataRunID = @DataRunID) AND 
					--(RMS.ProductLineID = @ProductLineID) AND 
					(RMS.PopulationID = @PopulationID)
			GROUP BY RMS.DataRunID,
					RMS.DataSetID,
					DE.IdssElementID,
					DE.MeasureSetID,
					RMS.PopulationID,
					RMS.ProductLineID,
					DE.ProductTypeID
		),
		Populations AS
		(
			SELECT DISTINCT
					DataRunID,
					DataSetID,
					MeasureSetID,
					PopulationID,
					ProductLineID,
					ProductTypeID
			FROM	DataElementValues
		),
		DataElements AS
		(
			SELECT DISTINCT
					P.DataRunID,
					P.DataSetID,
					TLM.IdssElementID,
					TLM.MeasureSetID,
					P.PopulationID,
					TLM.ProductLineID,
					TLM.ProductTypeID
			FROM	Ncqa.IDSS_DataElements_TLM AS TLM
					INNER JOIN Populations AS P
							ON TLM.MeasureSetID = P.MeasureSetID
		)
		INSERT INTO #DataElements
				(IdssElementID,
				SqlStatement,
				Value)
		SELECT	DE.IdssElementID,
				NULL AS SqlStatement,
				ISNULL(DEV.CountMembers, 0) AS Value
		FROM	DataElements AS DE
				LEFT OUTER JOIN DataElementValues AS DEV
						ON DE.DataRunID = DEV.DataRunID AND
							DE.DataSetID = DEV.DataSetID AND
							DE.IdssElementID = DEV.IdssElementID AND
							DE.MeasureSetID = DEV.MeasureSetID AND
							DE.PopulationID = DEV.PopulationID AND
							DE.ProductLineID = DEV.ProductLineID AND
							DE.ProductTypeID = DEV.ProductTypeID;
							
		--INSERT "RDM" VALUES
		WITH RaceMetrics AS
		(
			SELECT	IdssElementID,
					MeasureSetID,
					RaceMetricID AS MetricID
			FROM	Ncqa.IDSS_DataElements_RDM
		),
		EthnicityMetrics AS
		(
			SELECT	IdssElementID,
					MeasureSetID,
					EthnMetricID AS MetricID
			FROM	Ncqa.IDSS_DataElements_RDM
		),
		RaceDetail AS
		(
			SELECT	RMD.DataRunID,
					RMD.DataSetID,
					RMD.DSMemberID,
					MX.IdssElementID,
					RMD.MeasureID,
					RMD.MetricID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID
			FROM	Result.MeasureDetail_Classic AS RMD
					INNER JOIN RaceMetrics AS MX
							ON RMD.MetricID = MX.MetricID
		),
		EthnicityDetail AS
		(
			SELECT	RMD.DataRunID,
					RMD.DataSetID,
					RMD.DSMemberID,
					MX.IdssElementID,
					RMD.MeasureID,
					RMD.MetricID,
					RMD.PayerID,
					RMD.PopulationID,
					RMD.ProductLineID
			FROM	Result.MeasureDetail_Classic AS RMD
					INNER JOIN EthnicityMetrics AS MX
							ON RMD.MetricID = MX.MetricID
		),
		MatchedSummary AS
		(
			SELECT	COUNT(DISTINCT ED.DSMemberID) AS CountMembers,
					RD.DataRunID,
					RD.DataSetID,
					RD.IdssElementID,
					RD.PayerID,
					RD.PopulationID,
					RD.ProductLineID
			FROM	RaceDetail AS RD
					LEFT OUTER JOIN EthnicityDetail AS ED
							ON RD.DataRunID = ED.DataRunID AND
								RD.DataSetID = ED.DataSetID AND
								RD.DSMemberID = ED.DSMemberID AND
								RD.IdssElementID = ED.IdssElementID AND
								RD.MeasureID = ED.MeasureID AND
								RD.PayerID = ED.PayerID AND
								RD.PopulationID = ED.PopulationID AND
								RD.ProductLineID = ED.ProductLineID
			GROUP BY RD.DataRunID,
					RD.DataSetID,
					RD.IdssElementID,
					RD.PayerID,
					RD.PopulationID,
					RD.ProductLineID
		)
		INSERT INTO #DataElements
				(IdssElementID,
				SqlStatement,
				Value)
		SELECT	IdssElementID,
				NULL AS SqlStatement,
				CountMembers AS Value
		FROM	MatchedSummary AS MS
		WHERE	(DataRunID = @DataRunID) AND 
				(ProductLineID = @ProductLineID) AND 
				(PopulationID = @PopulationID)
		ORDER BY MS.IdssElementID;
		
		IF @Ansi_Warnings = 1
			SET ANSI_WARNINGS ON;
	END;

	/*
	--INSERT nuadm ELEMENTS FOR EOC MEASURES REPORTED AS ADMINISTRATIVE
	WITH 
	hybrids AS
	(
		SELECT DISTINCT
				k.measure
		FROM	IDSS.ProcessKey AS k WITH(NOLOCK)
				INNER JOIN IDSS.MeasureProductLines AS pl WITH(NOLOCK)
						ON k.measure = pl.measure AND
							pl.product_line = @product_line
		WHERE	report_type = 'H'
	),
	admins AS
	(
		SELECT	H.*
		FROM	IDSS.MeasureResultType AS RTI WITH(NOLOCK)
				INNER JOIN hybrids AS H
						ON RTI.measure_init = H.measure AND
							RTI.report_type = 'A'
		WHERE	(RTI.DataRunID = @DataRunID) AND
				(RTI.DataSetID = @DataSetID) AND
				(RTI.PopulationID = @PopulationID) AND
				(RTI.ProductLineID = @ProductLineID)
	),
	admin_metrics AS
	(
		SELECT	K.measure, K.metric, K.element
		FROM	IDSS.ProcessKey AS K WITH(NOLOCK)
				INNER JOIN IDSS.ProcessColumns AS C WITH(NOLOCK)
						ON K.column_type = C.column_type
				INNER JOIN admins AS A
						ON K.measure = A.measure AND
							C.source_column = 'sum_numerator'
	),
	element_conversion AS
	(
		SELECT	K.measure, K.metric, K.element AS h_element, A.element AS a_element--, K.*
		FROM	IDSS.ProcessKey AS K WITH(NOLOCK)
				INNER JOIN IDSS.ProcessColumns AS C WITH(NOLOCK)
						ON K.column_type = C.column_type
				INNER JOIN admin_metrics AS A
						ON K.measure = A.measure AND
							K.metric = A.metric AND
							K.element <> A.element AND
							C.source_column = 'sum_numerator_admin' AND
							K.is_used_in_sample = 1
	)
	INSERT INTO #DataElements 
			(row_id, sql_statement, measure, metric,
			element, [value])
	SELECT	(E.row_id * -1) - 100000 AS row_id,
			E.sql_statement,
			E.measure,
			E.metric,
			EC.h_element AS element,
			[value]
	FROM	#DataElements AS E WITH(NOLOCK)
			INNER JOIN element_conversion AS EC 
					ON E.metric = EC.metric AND
						E.element = EC.a_element;
	*/

	DECLARE @ID int;
	DECLARE @MaxID int;
	DECLARE @MinID int;
	DECLARE @SqlStatement nvarchar(max);
	DECLARE @Value nvarchar(64);

	SELECT	@ID = MIN(RowID),
			@MaxID = MAX(RowID),
			@MinID = MIN(RowID)
	FROM	#DataElements;

	WHILE (@ID BETWEEN @MinID AND @MaxID)
	BEGIN;
		SELECT	@SqlStatement = 'SET @Value = (' + SqlStatement + ');',
				@Value = NULL
		FROM	#DataElements
		WHERE	(RowID = @ID)
		
		IF @Ansi_Warnings = 1
			SET ANSI_WARNINGS OFF;
		
		IF (@SqlStatement IS NOT NULL) AND (@SqlStatement <> '')
			BEGIN TRY
				--PRINT @SqlStatement          
				EXEC sys.sp_executesql @statement = @SqlStatement, @params = N'@Value nvarchar(64) OUTPUT', @Value = @Value OUTPUT;
			END TRY
			BEGIN CATCH
				
			END CATCH
			
		IF @Ansi_Warnings = 1
			SET ANSI_WARNINGS ON;
			
		IF @Value IS NOT NULL
			UPDATE #DataElements SET Value = @Value WHERE (RowID = @ID);
		
		SET @ID = @ID + 1;
	END;

	IF @OutputResultSet = 1
		SELECT	DE.IdssElementAbbrev,
				DE.IdssElementDescr,
				t.IdssElementID,
				DE.IdssMeasure,
				DE.IdssMeasureDescr,
				t.RowID,
				t.SqlStatement,
				t.Value
		FROM	#DataElements AS t
				INNER JOIN Ncqa.IDSS_DataElements AS DE
						ON t.IdssElementID = DE.IdssElementID
		ORDER BY t.RowID;

	IF @OutputXml = 1
		BEGIN;
			DECLARE @Idss varchar(max)
			DECLARE @PreviousMeasure varchar(128)

			SELECT	@Idss = ISNULL(@Idss, '') + 
								CASE	WHEN @PreviousMeasure IS NULL 
										THEN '<measure id="' + DE.IdssMeasure + '" measure-version-id="' + CONVERT(nvarchar(128), MM.MeasureGuid) + '"><data-elements>'
										
										WHEN @PreviousMeasure <> DE.IdssMeasure 
										THEN '</data-elements></measure><measure id="' + DE.IdssMeasure + '" measure-version-id="' + CONVERT(nvarchar(128), MM.MeasureGuid) + '"><data-elements>'
										
										ELSE '' END,
					@Idss = @Idss + '<data-element id="' + DE.IdssElementAbbrev + '"><value>' + t.Value + '</value></data-element>',
					@PreviousMeasure = IdssMeasure
			FROM	#DataElements AS t
					INNER JOIN Ncqa.IDSS_DataElements AS DE
							ON t.IdssElementID = DE.IdssElementID
					INNER JOIN Measure.Measures AS MM
							ON DE.MeasureID = MM.MeasureID
			WHERE	Value IS NOT NULL
			ORDER BY t.IdssElementID;

			SET @Idss = '<?xml version="1.0" encoding="utf-8" ?>' + 
						'<submission guid="00000000-0000-0000-0000-000000000000" xmlns="http://www.ncqa.org/ns/2006/idss/hedis" vendor-id="' + @VendorID + '">' +
						'<metadata>' +
							'<version>1</version>' +
							'<timestamp>' + dbo.ConvertDateTimeToVarchar(GETDATE()) + '</timestamp>' +
							'<sub-id>' + @SubmissionID + '</sub-id>' +
							'<org-id>' + @OrganizationID + '</org-id>' +
							'<org-name>' + @OrganizationName + '</org-name>' +
							'<product-line>' + @ProductLineDescr + '</product-line>' +
							'<reporting-product />' +
							'<special-project>' + CASE WHEN @ProductLineDescr = 'Marketplace' THEN 'QRS' ELSE 'None' END + '</special-project>' +
							'<special-area>None</special-area>' +
							'<hcfa-contract/>' +
							'<hcfa-area/>' +
							'<year-end-date>' + dbo.ConvertDateToVarchar(@EndInitSeedDate) + '</year-end-date>' +
							'<audit>true</audit>' +
							CASE WHEN @ProductLineDescr = 'Marketplace' AND 1 = 2 THEN '<marketplace-enrollee>OffMarketplaceOnly</marketplace-enrollee>' ELSE '' END+
						'</metadata>' +
						'<component type="GS"><data><measures>' + 
						@Idss + 
						'</data-elements></measure></measures></data></component></submission>'
						
			SELECT CAST(@Idss AS XML) AS [IdssOutput];
		END;

	DECLARE @CountNulls int;
	SELECT @CountNulls = COUNT(*) FROM #DataElements WHERE [Value] IS NULL;

	IF @CountNulls > 0
		BEGIN;
			DECLARE @Message nvarchar(max);
			SET @Message = 'Incomplete IDSS output file due to ' + CONVERT(nvarchar(64), @CountNulls) + ' value(s) missing.';
			
			RAISERROR(@Message, 16, 1);
		END;
	END


GO
GRANT VIEW DEFINITION ON  [Ncqa].[IDSS_GenerateDataElementValues] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[IDSS_GenerateDataElementValues] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[IDSS_GenerateDataElementValues] TO [Processor]
GO
