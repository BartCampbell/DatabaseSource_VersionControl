SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/27/2015
-- Description:	Retrieves the list of code types.
-- =============================================
CREATE PROCEDURE [Report].[GetCodeTypes]
(
	@AllowDefault bit = 1
)
AS
BEGIN
	SET NOCOUNT ON;
		
	BEGIN TRY;
		
		WITH Results AS
		(
			SELECT	'(All)' AS Abbrev,
					'(All Code Types)' AS Descr,
					CONVERT(tinyint, NULL) AS ID
			UNION
			SELECT	CCT.Abbrev,
					CCT.Descr,
					CCT.CodeTypeID
			FROM	Claim.CodeTypes AS CCT WITH(NOLOCK)
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
GRANT VIEW DEFINITION ON  [Report].[GetCodeTypes] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCodeTypes] TO [db_executer]
GO
GRANT EXECUTE ON  [Report].[GetCodeTypes] TO [Processor]
GO
GRANT EXECUTE ON  [Report].[GetCodeTypes] TO [Reports]
GO
