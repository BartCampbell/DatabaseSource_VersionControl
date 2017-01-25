SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/16/2016
-- Description:	Deletes the specified security principal and all related data.
-- =============================================
CREATE PROCEDURE [ReportPortal].[DeleteSecurityPrincipal]
(
	@PrincipalID smallint
)
AS
BEGIN

	SET NOCOUNT ON;

    BEGIN TRY
		IF EXISTS (SELECT TOP 1 1  FROM ReportPortal.SecurityPrincipals WHERE PrincipalID = @PrincipalID)
			BEGIN;
				BEGIN TRANSACTION TDeleteSecurityPrincipal;
		
				SELECT ActivityID INTO #SecurityPrincipalActivity FROM ReportPortal.SecurityPrincipalActivity WHERE (PrincipalID = @PrincipalID);
				DELETE FROM Log.Activity WHERE ActivityID IN (SELECT ActivityID FROM #SecurityPrincipalActivity);
				DELETE FROM ReportPortal.SecurityPrincipalActivity WHERE (PrincipalID = @PrincipalID);
				DELETE FROM ReportPortal.SecurityPrincipalCustomerObjects WHERE (PrincipalID = @PrincipalID);
				DELETE FROM ReportPortal.SecurityPrincipals WHERE (PrincipalID = @PrincipalID);

				COMMIT TRANSACTION TDeleteSecurityPrincipal;
			END;
		ELSE
			RAISERROR('The specified security principal does not exist.', 16, 1);

		RETURN 0;
	END TRY
	BEGIN CATCH
		WHILE @@TRANCOUNT > 0
			ROLLBACK;

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
	END CATCH
END
GO
GRANT EXECUTE ON  [ReportPortal].[DeleteSecurityPrincipal] TO [ReportPortal_AppUser]
GO
