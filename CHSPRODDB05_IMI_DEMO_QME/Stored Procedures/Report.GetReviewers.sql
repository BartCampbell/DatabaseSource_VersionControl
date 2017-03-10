SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 4/12/2012
-- Description:	Retrieves the viewable reviewers based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetReviewers]
(
	@AllowAll bit = 1,
	@DataRunID int
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		WITH Reviewers AS 
		(
			SELECT	'(All Reviewers)' AS Descr, CAST(NULL AS int) AS ID
			UNION ALL
			SELECT	DisplayName AS Descr,
					ReviewerID AS ID
			FROM	Result.DataSetReviewerKey WITH(NOLOCK)
			WHERE	(DataRunID = @DataRunID)
		)
		SELECT	Descr, ID
		FROM	Reviewers
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (ID IS NOT NULL)))
		ORDER BY Descr, ID;
	
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
GRANT VIEW DEFINITION ON  [Report].[GetReviewers] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetReviewers] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetReviewers] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetReviewers] TO [Reports]
GO
