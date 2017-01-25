SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Graves, George
-- Create date: 06/08/2016
-- Description:	Returns all or one object utilization details based on PrincipalID
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetObjectUtilizationHistoryByPrincipalID]
(
	@PrincipalID smallint,
	@RptObjID smallint
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  RPOU.CreatedDate AS CreatedDate,
            RPO.Descr,
            RPO.DisplayName,
            RPOU.Params,
            RPOU.PrincipalID,
            RPO.ObjectName,
            RPOU.RptObjID,
            RPO.RptObjTypeID,
            RPO.RptRelPath,
			RPOU.RptObjUtilID,
            RPO.UrlSeg
    FROM    ReportPortal.ObjectUtilization RPOU
            INNER JOIN ReportPortal.Objects RPO ON RPO.RptObjID = RPOU.RptObjID AND RPO.RptObjTypeID = 2
	WHERE
			(RPOU.PrincipalID = @PrincipalID) AND
            (RPOU.RptObjID = @RptObjID)
			ORDER BY RPOU.CreatedDate DESC;

END;
GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectUtilizationHistoryByPrincipalID] TO [PortalApp]
GO
