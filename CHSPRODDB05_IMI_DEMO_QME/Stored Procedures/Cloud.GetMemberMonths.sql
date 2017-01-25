SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/14/2013
-- Description:	Returns the list member month options.
-- =============================================
CREATE PROCEDURE [Cloud].[GetMemberMonths]
(
	@MbrMonthGuid uniqueidentifier = NULL,
	@MbrMonthID tinyint = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY;
		
		SELECT	Descr,
		        MbrMonthGuid,
		        MbrMonthID
		FROM	Measure.MemberMonths AS MMM
		WHERE	((@MbrMonthGuid IS NULL) OR (MMM.MbrMonthGuid = @MbrMonthGuid)) AND
				((@MbrMonthID IS NULL) OR (MMM.MbrMonthID = @MbrMonthID));
								
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
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [Controller]
GO
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [NController]
GO
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [NProcessor]
GO
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [NService]
GO
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [Processor]
GO
GRANT EXECUTE ON  [Cloud].[GetMemberMonths] TO [Submitter]
GO
