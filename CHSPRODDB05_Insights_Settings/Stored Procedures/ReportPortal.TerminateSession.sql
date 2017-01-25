SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike 
-- Create date: 9/4/2015
-- Description:	Populates the end date/time of the specified activity entry.
-- =============================================
CREATE PROCEDURE [ReportPortal].[TerminateSession]
(
	@ActivityGuid uniqueidentifier,
	@PrincipalID smallint
)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE	ReportPortal.SecurityPrincipalActivity
	SET		SessionEndDate = GETDATE()
	WHERE	(ActivityGuid = @ActivityGuid) AND
			(PrincipalID = @PrincipalID);

END
GO
GRANT EXECUTE ON  [ReportPortal].[TerminateSession] TO [PortalApp]
GO
