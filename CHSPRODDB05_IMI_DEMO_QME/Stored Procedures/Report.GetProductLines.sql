SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the viewable product lines for the specified datarun and population.
-- =============================================
CREATE PROCEDURE [Report].[GetProductLines]
(
	@AllowDefault bit = 0,
	@DataRunID int,
	@PopulationID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		WITH Results AS
		(
			SELECT CONVERT(varchar(8), '(All)') AS Abbrev,
					CONVERT(varchar(32), '(All Product Lines)') AS Descr,
					NULL AS ID
			UNION		
			SELECT DISTINCT	
					RPLL.Abbrev, RPLL.Descr, RPLL.ProductLineID AS ID
			FROM	Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
					INNER JOIN Result.ProductLines AS RPLL WITH(NOLOCK)
							ON RDSXK.ProductLineID = RPLL.ProductLineID 
			WHERE	(RDSXK.DataRunID = @DataRunID) AND
					(RDSXK.PopulationID = @PopulationID)
		)
		SELECT	t.Abbrev,
                t.Descr,
                t.ID
		FROM	Results AS t
		WHERE	(@AllowDefault = 1) OR (t.ID IS NOT NULL)
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
GRANT VIEW DEFINITION ON  [Report].[GetProductLines] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetProductLines] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetProductLines] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetProductLines] TO [Reports]
GO
