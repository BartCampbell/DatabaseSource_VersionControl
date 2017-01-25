SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/15/2011
-- Description:	Returns one or more measure sets based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Cloud].[GetMeasureSets]
(
	@IsEnabled bit = NULL,
	@MeasureSetGuid uniqueidentifier = NULL,
	@MeasureSetID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		SELECT	*
		FROM	Measure.MeasureSets AS MMS WITH(NOLOCK)
				CROSS APPLY (SELECT TOP 1 t.MeasureID FROM Measure.Measures AS t WHERE t.MeasureSetID = MMS.MeasureSetID) AS MM
		WHERE	((@IsEnabled IS NULL) OR (IsEnabled = @IsEnabled)) AND
				((@MeasureSetGuid IS NULL) OR (MeasureSetGuid = @MeasureSetGuid)) AND
				((@MeasureSetID IS NULL) OR (MeasureSetID = @MeasureSetID)) 
								
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
											@PerformRollback = 0,
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
GRANT EXECUTE ON  [Cloud].[GetMeasureSets] TO [Controller]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasureSets] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasureSets] TO [Submitter]
GO
