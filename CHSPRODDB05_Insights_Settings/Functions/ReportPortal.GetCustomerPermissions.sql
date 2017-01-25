SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/3/2015
-- Description:	Retrieves the permitted customers for the specified user.
-- =============================================
CREATE FUNCTION [ReportPortal].[GetCustomerPermissions]
(	
	@UserName nvarchar(128)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT 
			RptCustID 
	FROM	ReportPortal.GetObjectPermissions(@UserName, DEFAULT)
	UNION
	SELECT	RptCustID 
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK) 
			INNER JOIN ReportPortal.SecurityPrincipals AS RSP
					ON RSP.IsSysAdmin = 1 AND
						RSP.IsEnabled = 1
	WHERE	RSP.PrincipalID = ReportPortal.GetPrincipalByUserName(@UserName)
	UNION
	SELECT	RptCustID 
	FROM	ReportPortal.Customers AS RC WITH(NOLOCK) 
			INNER JOIN ReportPortal.SecurityPrincipals AS RSP
					ON RSP.IsSysAdmin = 1 AND
						RSP.IsEnabled = 1
			INNER JOIN ReportPortal.SecurityPrincipalUserGroups AS RSPUG
					ON RSPUG.PrincipalID = RSP.PrincipalID
	WHERE	RSPUG.UserPrincipalID = ReportPortal.GetPrincipalByUserName(@UserName)
)
GO
GRANT SELECT ON  [ReportPortal].[GetCustomerPermissions] TO [PortalApp]
GO
