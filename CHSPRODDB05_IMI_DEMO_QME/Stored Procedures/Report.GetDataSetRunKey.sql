SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the viewable dataset/datarun combinations for the specified owner.
-- =============================================
CREATE PROCEDURE [Report].[GetDataSetRunKey]
(
	@OwnerID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		SELECT	MeasureSetDescr + ', ' + DataRunDescr + '' AS Descr, DataRunID AS ID,
				*
		FROM	Result.DataSetRunKey WITH(NOLOCK)
		WHERE	(OwnerID = @OwnerID)  AND
				(IsShown = 1);
	
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
GRANT VIEW DEFINITION ON  [Report].[GetDataSetRunKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetDataSetRunKey] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetDataSetRunKey] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetDataSetRunKey] TO [Reports]
GO
