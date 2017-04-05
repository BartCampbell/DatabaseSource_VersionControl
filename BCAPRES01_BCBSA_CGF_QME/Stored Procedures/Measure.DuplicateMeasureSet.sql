SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/13/2012
-- Description:	Duplicates a measure set or optionally a specific measure of a measure set.
-- =============================================
CREATE PROCEDURE [Measure].[DuplicateMeasureSet]
(
	@FromMeasureSetID int,
	@MeasureID int = NULL,
	@ToMeasureSetID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LogBeginTime datetime;
	DECLARE @LogDescr varchar(256);
	DECLARE @LogEndTime datetime;
	DECLARE @LogEntryXrefGuid uniqueidentifier;
	DECLARE @LogObjectName nvarchar(128);
	DECLARE @LogObjectSchema nvarchar(128);
	
	DECLARE @BatchID int;
	DECLARE @DataSetID int;
	DECLARE @MeasureSetID int;
	
	DECLARE @Result int;
	
	BEGIN TRY;
		
		DECLARE @ParameterValues AS DbUtility.CopyParmaterValues;
		INSERT INTO @ParameterValues VALUES ('MeasureSetID', @FromMeasureSetID)
		
		IF @MeasureID IS NOT NULL
			INSERT INTO @ParameterValues VALUES ('MeasureID', @MeasureID)
		
		EXEC DbUtility.ExecuteTableRowCopies @DmCopyConfigID = 1, @ExecuteSql = 1, @ParameterValues = @ParameterValues, @PrintSql = 0, @ToKeyID = @ToMeasureSetID;
				
		--Added 3/11/2014 to cover applying parent metrics to new measure sets.
		IF OBJECT_ID('tempdb..#ParentBase') IS NOT NULL
			DROP TABLE #ParentBase;

		SELECT	MM.Abbrev AS Measure, 
				MM.MeasureID,
				MM.MeasureXrefID, 
				MX.Abbrev AS Metric,
				MX.MetricID,
				MX.MetricXrefID, 
				PX.Abbrev AS Parent,
				MX.ParentID,
				PX.MetricXrefID AS ParentXrefID
		INTO	#ParentBase
		FROM	Measure.Measures AS MM
				INNER JOIN Measure.Metrics AS MX
						ON MM.MeasureID = MX.MeasureID
				INNER JOIN Measure.Metrics AS PX
						ON MX.ParentID = PX.MetricID
		WHERE	(MM.MeasureSetID = @FromMeasureSetID) AND
				((@MeasureID IS NULL) OR (MM.MeasureID = @MeasureID));

		WITH Metrics AS 
		(
			SELECT	MM.Abbrev AS Measure,
					MM.MeasureID,
					MM.MeasureSetID,
					MM.MeasureXrefID,
					MX.Abbrev AS Metric,
					MX.MetricID,
					MX.MetricXrefID
			FROM	Measure.Measures AS MM
					INNER JOIN Measure.Metrics AS MX
							ON MM.MeasureID = MX.MeasureID
			WHERE	MM.MeasureSetID = @ToMeasureSetID AND
					MM.MeasureSetID <> @FromMeasureSetID AND          
					MX.ParentID IS NULL  
		),
		PossibleNewParents AS
		(
			SELECT	PB.*,
					MX.MeasureSetID,
					MX.Metric AS NewMetric,
					MX.MetricID AS NewMetricID,
					PX.Abbrev AS NewParent,
					PX.MetricID AS NewParentID
			FROM	#ParentBase AS PB
					INNER JOIN Metrics MX
							ON PB.Measure = MX.Measure AND
								PB.MeasureID <> MX.MeasureID AND
								--PB.MeasureXrefID = MX.MeasureXrefID AND
								PB.Metric = MX.Metric AND
								PB.MetricID <> MX.MetricID --AND
								--PB.MetricXrefID = MX.MetricXrefID   
					INNER JOIN Measure.Metrics AS PX
							ON MX.MeasureID = PX.MeasureID AND
								MX.MetricID <> PX.MetricID AND
								PB.Parent = PX.Abbrev     
		)
		UPDATE	MX
		SET		ParentID = t.NewParentID
		FROM	Measure.Metrics AS MX
				INNER JOIN PossibleNewParents AS t
						ON MX.MetricID = NewMetricID
		WHERE	(MX.ParentID IS NULL);

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
GRANT EXECUTE ON  [Measure].[DuplicateMeasureSet] TO [Processor]
GO
