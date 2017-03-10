SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/27/2015
-- Description:	Retrieves the list of data sources for the specified data run.
-- =============================================
CREATE PROCEDURE [Report].[GetDataSetSources]
(
	@AllowDefault bit = 1,
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		WITH Results AS
		(
			SELECT	'(All Data Sources)' AS Descr,
					CONVERT(int, NULL) AS ID
			UNION
			SELECT	BDSS.Descr + CASE WHEN BDSS.IsSupplemental = 1 THEN ' (SUPPLEMENTAL DATA)' ELSE '' END AS Descr,
					BDSS.DataSourceID AS ID
			FROM	Batch.DataSetSources AS BDSS WITH(NOLOCK)
					INNER JOIN Result.DataSetRunKey AS RDSRK WITH(NOLOCK)
							ON RDSRK.DataSetID = BDSS.DataSetID
			WHERE	(RDSRK.DataRunID = @DataRunID) AND
					(BDSS.DataSourceID IN (SELECT DISTINCT DataSourceID FROM Result.ClaimCodeSummary WITH(NOLOCK) WHERE DataRunID = @DataRunID
											UNION SELECT DISTINCT DataSourceID FROM Result.ClaimLineSummary WITH(NOLOCK) WHERE DataRunID = @DataRunID)) 
		)
		SELECT	t.Descr,
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
GRANT VIEW DEFINITION ON  [Report].[GetDataSetSources] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetDataSetSources] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetDataSetSources] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetDataSetSources] TO [Reports]
GO
