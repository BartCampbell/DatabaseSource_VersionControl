SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/25/2015
-- Description:	Retrieves the list of customers available to the current user.
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetCustomers]
(
	@UserName varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	* 
	FROM	ReportPortal.Customers WITH(NOLOCK)
	WHERE	(RptCustID IN (SELECT RptCustID FROM ReportPortal.GetCustomerPermissions(@UserName)));
END
GO
GRANT EXECUTE ON  [ReportPortal].[GetCustomers] TO [PortalApp]
GO
