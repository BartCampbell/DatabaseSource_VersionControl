SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 10/5/2015
-- Description:	Retrieves the list of measure set types.
-- =============================================
CREATE PROCEDURE [Report].[GetMeasureSetTypes]
(
	@AllowAll bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		WITH Results AS 
		(
			SELECT	'(All Measure Sets)' AS Descr, CAST(NULL AS int) AS ID
			UNION ALL
			SELECT	'(HEDIS Certification: Both HEDIS & CAHPS)' AS Descr, CAST(-1 AS int) AS ID
			UNION ALL
			SELECT	MMS.Abbrev + ' - ' + MMS.Descr AS Descr,
					MMS.MeasureSetTypeID AS ID
			FROM	Measure.MeasureSetTypes AS MMS WITH(NOLOCK)
		)
		SELECT	t.Descr, t.ID
		FROM	Results AS t
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (t.ID IS NOT NULL) AND (t.ID > 0)))
		ORDER BY t.Descr;
	
		RETURN 0;
	END TRY
	BEGIN CATCH;
		DECLARE @ErrApp nvarchar(128);
		DECLARE @ErrLine int;
		DECLARE @ErrLogID int;
		DECLARE @ErrMessage nvarchar(MAX);
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
GRANT EXECUTE ON  [Report].[GetMeasureSetTypes] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetMeasureSetTypes] TO [Reports]
GO
