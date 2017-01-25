SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 9/1/2015
-- Description:	Retrieves the permitted objects for the specified user and customer combination.
-- =============================================
CREATE FUNCTION [ReportPortal].[GetObjectPermissions]
(	
	@UserName nvarchar(128),
	@RptCustID smallint = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	WITH ActivePrincpal AS
	(
		SELECT ReportPortal.GetPrincipalByUserName(@UserName) AS PrincipalID
	),
	SecurityPrincipalCustomerObjects AS
	(
		--Iterates through customer objects that are marked as IsInherited = 1 for their permissions, applying the permissions of the parent object
		SELECT	CONVERT(bit, CASE WHEN RCO.IsEnabled = 1 AND RSPCO.IsEnabled = 1 THEN 1 ELSE 0 END) AS IsEnabled,
				RSPCO.PrincipalID,
				RCO.RptCustID,
				RSPCO.PrincipalRptCustObjID,
				RSPCO.RptCustObjID AS RootRptCustObjID,
				RSPCO.RptCustObjID,
				RCO.RptObjID
		FROM	ReportPortal.SecurityPrincipalCustomerObjects AS RSPCO WITH(NOLOCK)
				INNER JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
						ON RCO.RptCustObjID = RSPCO.RptCustObjID
		UNION ALL
		SELECT	CONVERT(bit, CASE WHEN t.IsEnabled = 1 AND RCO.IsEnabled = 1 THEN 1 ELSE 0 END) AS IsEnabled,
				t.PrincipalID,
				t.RptCustID,
				t.PrincipalRptCustObjID,
				t.RootRptCustObjID,
				RCO.RptCustObjID,
				RCO.RptObjID
		FROM	SecurityPrincipalCustomerObjects AS t
				INNER JOIN ReportPortal.Navigation AS RN WITH(NOLOCK)
						ON RN.RptObjID = t.RptObjID
				INNER JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
						ON RCO.RptCustID = t.RptCustID AND
							RCO.RptObjID = RN.ChildID
		WHERE	(RCO.IsInherited = 1)
	),
	Results AS
	(
		--Assigned permissions by GROUP specifically
		SELECT	RCO.RptCustID,
				RCO.RptCustObjID,
				RCO.RptObjID
		FROM	ReportPortal.SecurityPrincipalUserGroups AS RSPUG WITH(NOLOCK)
				INNER JOIN ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
						ON RSP.PrincipalID = RSPUG.PrincipalID
				INNER JOIN SecurityPrincipalCustomerObjects AS RSPCO WITH(NOLOCK)
						ON RSPCO.PrincipalID = RSPUG.PrincipalID
				INNER JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
						ON RCO.RptCustObjID = RSPCO.RptCustObjID
				INNER JOIN ReportPortal.[Objects] AS RO WITH(NOLOCK)
						ON RO.RptObjID = RCO.RptObjID
		WHERE	(RSP.IsSysAdmin = 0) AND
				(RSPCO.IsEnabled = 1) AND
				(RCO.IsEnabled = 1) AND
				(RSPUG.UserPrincipalID IN (SELECT TOP 1 tAP.PrincipalID FROM ActivePrincpal AS tAP))
		--Assigned permissions by GROUP when SysAdmin (see everything)
		UNION
		SELECT	RCO.RptCustID,
				RCO.RptCustObjID,
				RCO.RptObjID
		FROM	ReportPortal.SecurityPrincipalUserGroups AS RSPUG WITH(NOLOCK)
				INNER JOIN ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
						ON RSP.PrincipalID = RSPUG.PrincipalID
				CROSS JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
		WHERE	(RSP.IsSysAdmin = 1) AND
				(RCO.IsEnabled = 1) AND
				(RSPUG.UserPrincipalID IN (SELECT TOP 1 tAP.PrincipalID FROM ActivePrincpal AS tAP))
		--Assigned permissions by USER specifically
		UNION
		SELECT	RCO.RptCustID,
				RCO.RptCustObjID,
				RCO.RptObjID
		FROM	ReportPortal.SecurityPrincipalUsers AS RSPU WITH(NOLOCK)
				INNER JOIN ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
						ON RSP.PrincipalID = RSPU.PrincipalID
				INNER JOIN SecurityPrincipalCustomerObjects AS RSPCO WITH(NOLOCK)
						ON RSPCO.PrincipalID = RSPU.PrincipalID
				INNER JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
						ON RCO.RptCustObjID = RSPCO.RptCustObjID
				INNER JOIN ReportPortal.[Objects] AS RO WITH(NOLOCK)
						ON RO.RptObjID = RCO.RptObjID
		WHERE	(RSP.IsSysAdmin = 0) AND
				(RSPCO.IsEnabled = 1) AND
				(RCO.IsEnabled = 1) AND
				(RSPU.PrincipalID IN (SELECT TOP 1 tAP.PrincipalID FROM ActivePrincpal AS tAP))
		--Assigned permissions by USER when SysAdmin (see everything)
		UNION
		SELECT	RCO.RptCustID,
				RCO.RptCustObjID,
				RCO.RptObjID
		FROM	ReportPortal.SecurityPrincipalUsers AS RSPU WITH(NOLOCK)
				INNER JOIN ReportPortal.SecurityPrincipals AS RSP WITH(NOLOCK)
						ON RSP.PrincipalID = RSPU.PrincipalID
				CROSS JOIN ReportPortal.CustomerObjects AS RCO WITH(NOLOCK)
		WHERE	(RSP.IsSysAdmin = 1) AND
				(RCO.IsEnabled = 1) AND
				(RSPU.PrincipalID IN (SELECT TOP 1 tAP.PrincipalID FROM ActivePrincpal AS tAP))
	)
	SELECT DISTINCT
			*
	FROM	Results
	WHERE	((@RptCustID IS NULL) OR (RptCustID = @RptCustID))
)
GO
GRANT SELECT ON  [ReportPortal].[GetObjectPermissions] TO [PortalApp]
GO
