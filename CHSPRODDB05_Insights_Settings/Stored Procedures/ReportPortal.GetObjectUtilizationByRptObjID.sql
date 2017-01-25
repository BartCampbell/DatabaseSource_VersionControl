SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Graves, George
-- Create date: 06/08/2016
-- Description:	Returns all or one object utilization details based on RptObjID
-- =============================================
Create PROCEDURE [ReportPortal].[GetObjectUtilizationByRptObjID]
(
 @RptObjID smallint
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  RPOU.CreatedDate,
            RPO.Descr,
            RPO.DisplayName,
            RPOU.Params,
            RPOU.PrincipalID,
            RPO.ObjectName,
            RPOU.RptObjID,
            RPO.RptObjTypeID,
            RPO.RptRelPath,
            RPO.UrlSeg
    FROM    ReportPortal.ObjectUtilization RPOU
            INNER JOIN ReportPortal.Objects RPO ON RPO.RptObjID = RPOU.RptObjID;

END;
GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectUtilizationByRptObjID] TO [PortalApp]
GO
