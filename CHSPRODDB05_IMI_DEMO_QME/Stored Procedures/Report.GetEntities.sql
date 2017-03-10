SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/29/2015
-- Description:	Retrieves the viewable entities based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Report].[GetEntities]
(
	@AllowAll bit = 1,
	@DataRunID int,
	@MeasureID int = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		WITH Entities AS 
		(
			SELECT	'(All Entities)' AS Descr, 
					CAST(NULL AS int) AS ID
			UNION ALL
			SELECT DISTINCT	
					t.EntityDescr AS Descr, 
					t.EntityID AS ID 
			FROM	Result.MeasureEventDetail AS t WITH(NOLOCK)
			WHERE	(t.DataRunID = @DataRunID) AND
					((@MeasureID IS NULL) OR (t.MeasureID = @MeasureID)) AND
					(t.EntityID > 0)
		)
		SELECT	Descr, ID
		FROM	Entities
		WHERE	((@AllowAll = 1) OR ((@AllowAll = 0) AND (ID IS NOT NULL)))
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
GRANT VIEW DEFINITION ON  [Report].[GetEntities] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetEntities] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetEntities] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetEntities] TO [Reports]
GO
