SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/6/2011
-- Description:	Retrieves the default product line for the specified datarun and population.
-- =============================================
CREATE PROCEDURE [Report].[GetProductLineDefault]
(
	@DataRunID int,
	@PopulationID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		WITH ResultProductLinesBase AS 
		(
			--SELECT DISTINCT BitProductLines FROM Result.MeasureDetail WITH(NOLOCK) WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND NOT EXISTS (SELECT TOP 1 1 FROM Result.MeasureSummary WITH(NOLOCK) WHERE DataRunID = @DataRunID)
			--UNION
			--SELECT DISTINCT BitProductLines FROM Result.MemberMonthDetail WITH(NOLOCK) WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND NOT EXISTS (SELECT TOP 1 1 FROM Result.MemberMonthSummary WITH(NOLOCK) WHERE DataRunID = @DataRunID)
			--UNION
			SELECT DISTINCT PPL.BitValue AS BitProductLines FROM Result.MeasureSummary AS RMS WITH(NOLOCK) INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK) ON PPL.ProductLineID = RMS.ProductLineID WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID
			UNION
			SELECT DISTINCT PPL.BitValue AS BitProductLines FROM Result.MemberMonthSummary AS RMMS WITH(NOLOCK) INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK) ON PPL.ProductLineID = RMMS.ProductLineID WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID
		),
		ResultProductLines AS 
		(
			SELECT DISTINCT
					PPL.ProductLineID
			FROM	ResultProductLinesBase AS t
					INNER JOIN Product.ProductLines AS PPL WITH(NOLOCK)
							ON (PPL.BitValue & t.BitProductLines > 0) OR
								(PPL.BitValue = 0 AND t.BitProductLines = 0)
		)
		SELECT 	
				MIN(RPLL.ProductLineID) AS ID
		FROM	Result.DataSetMetricKey AS RDSXK WITH(NOLOCK)
				INNER JOIN Result.ProductLines AS RPLL WITH(NOLOCK)
						ON RDSXK.ProductLineID = RPLL.ProductLineID 
		WHERE	(RDSXK.DataRunID = @DataRunID) AND
				(RDSXK.ProductLineID IN (SELECT ProductLineID FROM ResultProductLines)) AND
				(RDSXK.PopulationID = @PopulationID);
	
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
GRANT VIEW DEFINITION ON  [Report].[GetProductLineDefault] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetProductLineDefault] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetProductLineDefault] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetProductLineDefault] TO [Reports]
GO
