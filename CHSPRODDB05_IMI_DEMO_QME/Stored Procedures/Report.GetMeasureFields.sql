SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the list of report fields available to the specified measure.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureFields]
(
	@DataRunID int,
	@MetricID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		SELECT	CAST('(None)' AS varchar(64)) AS Descr,
				CAST(NULL AS tinyint) AS ID
		UNION ALL
		SELECT DISTINCT
				ISNULL(RMF.Descr, RF.Descr) AS Descr,
				RF.FieldID AS ID
		FROM	Report.Fields AS RF WITH(NOLOCK)
				INNER JOIN Report.MeasureFields AS RMF WITH(NOLOCK)
						ON RF.FieldID = RMF.FieldID
		WHERE	(
					(RMF.MeasureID IN (SELECT DISTINCT MeasureID FROM Result.DataSetMetricKey WHERE (DataRunID = @DataRunID) AND (MetricID = @MetricID))) 
					
				)
		UNION
		SELECT	RF.Descr AS Descr,
				RF.FieldID AS ID
		FROM	Report.Fields AS RF WITH(NOLOCK)
		WHERE	(RF.FieldGuid IN ('C90555D5-62C2-4096-B54E-4635DE360667', '2ABDB3D6-1954-4C4C-B525-A080DD551D53'))
		ORDER BY Descr;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetMeasureFields] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureFields] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetMeasureFields] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureFields] TO [Reports]
GO
