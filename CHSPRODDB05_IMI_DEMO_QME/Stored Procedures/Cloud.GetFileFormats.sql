SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/15/2011
-- Description:	Returns one or more file formats based on the specified criteria.
-- =============================================
CREATE PROCEDURE [Cloud].[GetFileFormats]
(
	@IsEnabled bit = NULL,
	@FileFormatCtgyAbbrev varchar(16) = NULL,
	@FileFormatCtgyGuid uniqueidentifier = NULL,
	@FileFormatCtgyID tinyint = NULL,
	@FileFormatGuid uniqueidentifier = NULL,
	@FileFormatID int = NULL,
	@FileFormatTypeGuid uniqueidentifier = NULL,
	@FileFormatTypeID smallint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
				
		SELECT	CFF.*
		FROM	Cloud.FileFormats AS CFF WITH(NOLOCK)
				INNER JOIN Cloud.FileFormatCategories AS CFFC WITH(NOLOCK)
						ON CFF.FileFormatCtgyID = CFFC.FileFormatCtgyID
				INNER JOIN Cloud.FileFormatTypes AS CFFT WITH(NOLOCK)
						ON CFF.FileFormatTypeID = CFFT.FileFormatTypeID
		WHERE	((@IsEnabled IS NULL) OR (IsEnabled = @IsEnabled)) AND
				((@FileFormatCtgyAbbrev IS NULL) OR (CFFC.Abbrev = @FileFormatCtgyAbbrev)) AND
				((@FileFormatCtgyGuid IS NULL) OR (CFFC.FileFormatCtgyGuid = @FileFormatCtgyGuid)) AND
				((@FileFormatCtgyID IS NULL) OR (CFFC.FileFormatCtgyID = @FileFormatCtgyID)) AND
				((@FileFormatGuid IS NULL) OR (CFF.FileFormatGuid = @FileFormatGuid)) AND
				((@FileFormatID IS NULL) OR (CFF.FileFormatID = @FileFormatID)) AND
				((@FileFormatTypeGuid IS NULL) OR (CFFT.FileFormatTypeGuid = @FileFormatTypeGuid)) AND
				((@FileFormatTypeID IS NULL) OR (CFF.FileFormatTypeID = @FileFormatTypeID))
								
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
GRANT EXECUTE ON  [Cloud].[GetFileFormats] TO [Controller]
GO
GRANT VIEW DEFINITION ON  [Cloud].[GetFileFormats] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetFileFormats] TO [db_executer]
GO
GRANT EXECUTE ON  [Cloud].[GetFileFormats] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetFileFormats] TO [Submitter]
GO
