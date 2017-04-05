SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/5/2016
-- Description:	Retrieves a list of payers associated with the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetPayers]
(
	@AllowAll bit = 1,
	@DataRunID int,
	@PopulationID int,
	@ProductLineID int
)
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY;
		WITH PayersInResults AS
		(
			SELECT DISTINCT PayerID FROM Result.MeasureSummary WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND ProductLineID = @ProductLineID
			UNION
			SELECT DISTINCT PayerID FROM Result.MemberMonthSummary WHERE DataRunID = @DataRunID AND PopulationID = @PopulationID AND ProductLineID = @ProductLineID
		),
		Results AS 
		(
			SELECT	'(All Payers)' AS Descr, CAST(NULL AS smallint) AS ID
			UNION ALL
			SELECT DISTINCT
					RP.Abbrev + ' - ' + RP.Descr AS Descr,
					RP.PayerID AS ID
			FROM	Result.Payers AS RP
					INNER JOIN PayersInResults AS t
							ON t.PayerID = RP.PayerID
		)
		SELECT	Descr, ID
		FROM	Results
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (ID IS NOT NULL)))
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
GRANT EXECUTE ON  [Report].[GetPayers] TO [Reports]
GO
