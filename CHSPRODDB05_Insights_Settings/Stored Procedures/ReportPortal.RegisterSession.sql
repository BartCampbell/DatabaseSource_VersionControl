SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/28/2015
-- Description:	Registers the session start of the specified principal.
-- =============================================
CREATE PROCEDURE [ReportPortal].[RegisterSession]
(
	@ADInfo xml,
	@BrowserName varchar(256),
	@BrowserType varchar(256) = NULL,
	@BrowserVersion varchar(32),
	@DomainName nvarchar(128),
	@SessionID nvarchar(128),
	@SourceHost varchar(256) = NULL,
	@SourceIP varchar(32) = NULL,
	@UserAgent varchar(256) = NULL,
	@UserName nvarchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ActivityGuid uniqueidentifier;
	DECLARE @PrincipalID smallint;

    SELECT	@PrincipalID = RSP.PrincipalID
	FROM	ReportPortal.SecurityPrincipals AS RSP
	WHERE	(
				(RSP.PrincipalName = @UserName) AND
				(RSP.DomainName = @DomainName) 
			) OR
			(RSP.ADName = @UserName) OR
			(RSP.ADUserPrincipalName = @UserName);

	IF (@PrincipalID IS NOT NULL)
		BEGIN;
			BEGIN TRAN TRegisterSession;

			BEGIN TRY;
				UPDATE	ReportPortal.SecurityPrincipals
				SET		ADInfo = ISNULL(@ADInfo, ADInfo),
						LastPortalLogon = GETDATE(),
						PortalLogonCount = ISNULL(PortalLogonCount, 0) + 1
				WHERE	PrincipalID = @PrincipalID;

				SET @ActivityGuid = NEWID();

				INSERT INTO ReportPortal.SecurityPrincipalActivity
				        (ActivityGuid,
						 BrowserName,
						 BrowserType,
				         BrowserVersion,
				         PrincipalID,
				         SessionBeginDate,
				         SessionEndDate,
				         SessionID,
				         SourceHost,
				         SourceIP,
				         UserAgent)
				VALUES  (@ActivityGuid,
						@BrowserName,
						@BrowserType,
						@BrowserVersion,
						@PrincipalID,
						GETDATE(),
						NULL,
						@SessionID,
						@SourceHost,
						@SourceIP,
						@UserAgent);

				COMMIT TRAN TRegisterSession;
			END TRY
			BEGIN CATCH;
				ROLLBACK TRAN TRegisterSession;
			END CATCH;
		END;

	SELECT TOP 1
			RSPA.ActivityGuid,
			RSP.* 
	FROM	ReportPortal.SecurityPrincipalsInherited AS RSP 
			INNER JOIN ReportPortal.SecurityPrincipalActivity AS RSPA 
					ON RSPA.PrincipalID = RSP.PrincipalID 
	WHERE	(RSP.PrincipalID = @PrincipalID) AND 
			(RSPA.ActivityGuid = @ActivityGuid);
END
GO
GRANT EXECUTE ON  [ReportPortal].[RegisterSession] TO [PortalApp]
GO
