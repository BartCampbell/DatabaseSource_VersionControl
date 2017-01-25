SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/3/2015
-- Description:	Retrieves the PrincipalID for the user name sent from ASP.NET's HttpContext.User.Principal.Name.
-- =============================================
CREATE FUNCTION [ReportPortal].[GetPrincipalByUserName]
(
	@UserName nvarchar(128)
)
RETURNS smallint
AS
BEGIN
	RETURN (SELECT DISTINCT TOP 1
					RSP.PrincipalID
			FROM	ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
			WHERE	(RSP.ADName = @UserName) OR	
					((RSP.ADSamAccountName = @UserName) AND (RSP.PrincipalName = @UserName)) OR
					(@UserName LIKE '%\%' AND 
							RSP.ADDomainName LIKE '%' + LEFT(@UserName, NULLIF(CHARINDEX('\', @UserName), 0) - 1) + '%' AND 
							RSP.ADSamAccountName = RIGHT(@UserName, LEN(@UserName) - CHARINDEX('\', @UserName))) OR
					(RSP.ADUserPrincipalName = @UserName));
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetPrincipalByUserName] TO [PortalApp]
GO
