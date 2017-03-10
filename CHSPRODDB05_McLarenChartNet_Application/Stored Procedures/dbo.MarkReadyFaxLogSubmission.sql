SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MarkReadyFaxLogSubmission]
(
	@FaxLogSubID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FaxLogID int;

    UPDATE	dbo.FaxLogSubmissions
	SET		@FaxLogID = FaxLogID,
			IsReady = 1,
			ReadyDate = GETDATE()
	WHERE	(FaxLogSubID = @FaxLogSubID) AND
			(IsReady = 0);

	PRINT 'File Submission marked ready.';

	IF @FaxLogID IS NOT NULL
		EXEC dbo.TrySendFaxLogSubmission @FaxLogID = @FaxLogID;
		
END
GO
GRANT EXECUTE ON  [dbo].[MarkReadyFaxLogSubmission] TO [Reporting]
GO
