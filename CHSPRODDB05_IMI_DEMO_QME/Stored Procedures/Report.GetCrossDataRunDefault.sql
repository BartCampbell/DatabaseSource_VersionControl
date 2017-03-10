SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 3/8/2012
-- Description:	Retrieves the default cross-dataset/datarun combinations for the specified owner.
-- =============================================
CREATE PROCEDURE [Report].[GetCrossDataRunDefault]
(
	@OwnerID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		WITH MeasureSets AS
		(
			SELECT DISTINCT TOP 2
					MeasureSetID
			FROM	Result.DataSetRunKey WITH(NOLOCK)
			WHERE	(OwnerID = @OwnerID) AND
					(IsShown = 1)
			ORDER BY 1 DESC
		),
		ToDataRun AS
		(
			SELECT TOP 1	
					RK.MeasureSetID, RK.DataRunID AS ToDataRunID
			FROM	Result.DataSetRunKey AS RK WITH(NOLOCK)
					INNER JOIN MeasureSets AS MS
							ON RK.MeasureSetID = MS.MeasureSetID
			WHERE	(RK.OwnerID = @OwnerID) AND
					(RK.IsShown = 1) 
			ORDER BY MeasureSetID DESC, ToDataRunID DESC 
		),
		FromDataRun AS
		(
			SELECT TOP 1	
					RK.MeasureSetID, RK.DataRunID AS FromDataRunID,
					CASE WHEN TDR.ToDataRunID IS NOT NULL THEN 1 ELSE 0 END SortAsc1,
					CASE WHEN RK.DataRunID = TDR.ToDataRunID THEN 1 ELSE 0 END AS SortAsc2
			FROM	Result.DataSetRunKey AS RK WITH(NOLOCK)
					INNER JOIN MeasureSets AS MS
							ON RK.MeasureSetID = MS.MeasureSetID
					LEFT OUTER JOIN ToDataRun AS TDR
							ON RK.MeasureSetID = TDR.MeasureSetID
			WHERE	(RK.OwnerID = @OwnerID) AND
					(RK.IsShown = 1) 
			ORDER BY SortAsc1 ASC, SortAsc2 ASC, MeasureSetID DESC, FromDataRunID DESC 
		)
		SELECT	f.FromDataRunID,
				t.ToDataRunID
		FROM	FromDataRun AS f, 
				ToDataRun AS t;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetCrossDataRunDefault] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunDefault] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunDefault] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetCrossDataRunDefault] TO [Reports]
GO
