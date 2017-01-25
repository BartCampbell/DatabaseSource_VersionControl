SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/4/2015
-- Description:	Retrieves a principal record, based on the specified domain and principal name, or full AD user name.
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetSecurityPrincipal]
(
	@ADName nvarchar(128) = NULL,
	@DomainName nvarchar(128) = NULL,
    @PrincipalName nvarchar(128) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT TOP 1
			RSP.*
	FROM	ReportPortal. SecurityPrincipalsInherited AS RSP WITH(NOLOCK)
	WHERE	((@ADName IS NULL) OR (RSP.ADName = @ADName) OR (RSP.ADUserPrincipalName = @ADName)) AND
			((@DomainName IS NULL) OR (RSP.DomainName = @DomainName)) AND
			((@PrincipalName IS NULL) OR (RSP.PrincipalName = @PrincipalName)) AND
			((@ADName IS NOT NULL) OR ((@DomainName IS NOT NULL) AND (@PrincipalName IS NOT NULL)))
	OPTION (OPTIMIZE FOR UNKNOWN);
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetSecurityPrincipal] TO [PortalApp]
GO
