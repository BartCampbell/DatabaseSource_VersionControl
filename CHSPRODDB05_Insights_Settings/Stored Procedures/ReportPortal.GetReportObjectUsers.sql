SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [ReportPortal].[GetReportObjectUsers]
(
 @RptCustID smallint = NULL,
 @RptObjID smallint = NULL
 )
AS
BEGIN

    DECLARE @RptCustObjID smallint

    SELECT  @RptCustObjID = RptCustObjID
    FROM    [ReportPortal].CustomerObjects WITH (NOLOCK)
    WHERE   RptCustID = @RptCustID AND
            RptObjID = @RptObjID

    SELECT  sp.[PrincipalID],
            sp.[PrincipalTypeID],
            spt.[Descr] AS PrincipalType,
            sp.[DomainName],
            sp.[PrincipalName],
            spco.[IsEnabled] AS HasAccess,
			spco.[PrincipalRptCustObjID] AS PrincipalRptCustObjID,
			spco.[BitNavigationTypes] AS BitNavigationTypes,
			@RptCustObjID AS RptCustObjID
    FROM    [ReportPortal].[SecurityPrincipals] sp WITH (NOLOCK)
            JOIN [ReportPortal].[SecurityPrincipalTypes] spt WITH (NOLOCK) ON sp.PrincipalTypeID = spt.PrincipalTypeID
            LEFT JOIN [ReportPortal].SecurityPrincipalCustomerObjects spco ON spco.PrincipalID = sp.PrincipalID AND
                                                              spco.RptCustObjID = @RptCustObjID

END
GO
GRANT EXECUTE ON  [ReportPortal].[GetReportObjectUsers] TO [PortalApp]
GO
