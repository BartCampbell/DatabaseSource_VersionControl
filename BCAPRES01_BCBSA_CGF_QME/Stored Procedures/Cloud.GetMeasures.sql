SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/14/2013
-- Description:	Returns the list measures.
-- =============================================
CREATE PROCEDURE [Cloud].[GetMeasures]
(
	@Abbrev varchar(16) = NULL,
	@MeasureGuid uniqueidentifier = NULL,
	@MeasureID int = NULL,
	@MeasureSetGuid uniqueidentifier = NULL,
	@MeasureSetID int = NULL,
	@MeasureXrefGuid uniqueidentifier = NULL,
	@MeasureXrefID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	MM.Abbrev,
		        MM.Descr,
		        MM.IsEnabled,
		        MM.IsHybrid,
		        MM.MeasClassID,
		        MM.MeasureGuid,
		        MM.MeasureID,
		        MMS.MeasureSetGuid,
		        MM.MeasureSetID,
		        MMX.MeasureXrefGuid,
		        MM.MeasureXrefID,
		        MM.SysSampleRand,
		        MM.SysSampleRate,
		        MM.SysSampleSize
		FROM	Measure.Measures AS MM WITH(NOLOCK)
				INNER JOIN Measure.MeasureXrefs AS MMX WITH(NOLOCK)
						ON MM.MeasureXrefID = MMX.MeasureXrefID
				INNER JOIN Measure.MeasureSets AS MMS WITH(NOLOCK)
						ON MM.MeasureSetID = MMS.MeasureSetID
		WHERE	((@Abbrev IS NULL) OR (MM.Abbrev = @Abbrev)) AND
				((@MeasureGuid IS NULL) OR (MM.MeasureGuid = @MeasureGuid)) AND
				((@MeasureID IS NULL) OR (MM.MeasureID = @MeasureID)) AND
				((@MeasureSetGuid IS NULL) OR (MMS.MeasureSetGuid = @MeasureSetGuid)) AND
				((@MeasureSetID IS NULL) OR (MM.MeasureSetID = @MeasureSetID)) AND
				((@MeasureXrefGuid IS NULL) OR (MMX.MeasureXrefGuid = @MeasureXrefGuid)) AND
				((@MeasureXrefID IS NULL) OR (MM.MeasureXrefID = @MeasureXrefID)) AND
				(MMS.IsEnabled = 1) AND 
				(MM.IsEnabled = 1)
		ORDER BY MM.MeasureSetID, MM.Abbrev;
								
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
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [Controller]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [NController]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [NProcessor]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [NService]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetMeasures] TO [Submitter]
GO
