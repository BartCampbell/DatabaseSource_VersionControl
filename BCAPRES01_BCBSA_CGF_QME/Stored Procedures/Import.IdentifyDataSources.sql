SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 1/18/2014
-- Description:	Identifies the data sources associated with import files.
-- =============================================
CREATE PROCEDURE [Import].[IdentifyDataSources]
(
	@DataSetID int,
	@HedisMeasureID varchar(10) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;

		IF OBJECT_ID('tempdb..#DataSources') IS NOT NULL
			DROP TABLE #DataSources;

		SELECT DISTINCT
				COUNT(*) AS CountRecords, 
				SUM(CASE WHEN SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END) AS CountSupplemental, 
				DataSource, 
				MAX(CONVERT(tinyint, dbo.ConvertBitFromYN(SupplementalDataFlag))) AS IsSupplemental,
				'dbo' AS SourceSchema,
				'Claim' AS SourceTable
		INTO	#DataSources
		FROM	dbo.Claim WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource, SupplementalDataFlag
		UNION
		SELECT	DISTINCT 
				COUNT(*) AS CountRecords, 
				SUM(CASE WHEN SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END) AS CountSupplemental, 
				DataSource, 
				MAX(CONVERT(tinyint, dbo.ConvertBitFromYN(SupplementalDataFlag))) AS IsSupplemental,
				'dbo' AS SourceSchema,
				'PharmacyClaim' AS SourceTable
		FROM	dbo.PharmacyClaim WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource, SupplementalDataFlag
		UNION
		SELECT	DISTINCT 
				COUNT(*) AS CountRecords, 
				SUM(CASE WHEN SupplementalDataFlag = 'Y' THEN 1 ELSE 0 END) AS CountSupplemental, 
				DataSource, 
				MAX(CONVERT(tinyint, dbo.ConvertBitFromYN(SupplementalDataFlag))) AS IsSupplemental,
				'dbo' AS SourceSchema,
				'LabResult' AS SourceTable
		FROM	dbo.LabResult WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource, SupplementalDataFlag
		UNION
		SELECT	DISTINCT 
				COUNT(*) AS CountRecords, 
				0 AS CountSupplemental, 
				DataSource, 
				0 AS IsSupplemental,
				'dbo' AS SourceSchema,
				'Member' AS SourceTable
		FROM	dbo.Member WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource
		UNION
		SELECT	DISTINCT 
				COUNT(*) AS CountRecords, 
				0 AS CountSupplemental, 
				DataSource, 
				0 AS IsSupplemental,
				'dbo' AS SourceSchema,
				'Provider' AS SourceTable
		FROM	dbo.Provider WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource
		UNION
		SELECT	DISTINCT 
				COUNT(*) AS CountRecords, 
				0 AS CountSupplemental, 
				DataSource, 
				0 AS IsSupplemental,
				'dbo' AS SourceSchema,
				'Eligibility' AS SourceTable
		FROM	dbo.Eligibility WITH(NOLOCK)
		WHERE	((@HedisMeasureID IS NULL) OR (HedisMeasureID = @HedisMeasureID))
		GROUP BY DataSource;

		WITH DataSources AS
		(
			SELECT	t.CountRecords,
					t.CountSupplemental,
					BDS.DataSetID,
					t.DataSource,
					t.IsSupplemental,
					t.SourceSchema,
					t.SourceTable
			FROM	#DataSources AS t
					INNER JOIN Batch.DataSets AS BDS
							ON BDS.DataSetID = @DataSetID
		)
		INSERT INTO Batch.DataSetSources
				(CountRecords,
				CountSupplemental,
				DataSetID,
				DataSource,
				Descr,
				IsSupplemental,
				SourceSchema,
				SourceTable)
		SELECT	DS.CountRecords,
				DS.CountSupplemental,
				DS.DataSetID,
				DS.DataSource,
				CASE WHEN CHARINDEX('.', REVERSE(DS.DataSource)) > 1 THEN REVERSE(LEFT(REVERSE(DS.DataSource), CHARINDEX('.', REVERSE(DS.DataSource)) - 1)) ELSE DS.DataSource END AS Descr,
				DS.IsSupplemental,
				DS.SourceSchema,
				DS.SourceTable
		FROM	DataSources AS DS
				LEFT OUTER JOIN Batch.DataSetSources AS BDSS
						ON DS.DataSetID = BDSS.DataSetID AND
							DS.DataSource = BDSS.DataSource AND
							DS.IsSupplemental = BDSS.IsSupplemental
		WHERE	(BDSS.DataSource IS NULL)	              
		ORDER BY DS.DataSetID, 
				DS.IsSupplemental DESC, --Must be first sort item, do not change
				DS.SourceSchema, 
				DS.SourceTable, 
				DS.DataSource;

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
GRANT EXECUTE ON  [Import].[IdentifyDataSources] TO [Processor]
GO
