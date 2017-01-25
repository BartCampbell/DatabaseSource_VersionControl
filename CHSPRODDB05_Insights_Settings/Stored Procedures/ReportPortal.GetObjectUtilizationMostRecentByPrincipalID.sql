SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		George Graves
-- Create date: 06/13/2016
-- Description: Returns a list of the most recent 
-- report views by principal, sorted by created date
-- and views
-- =============================================
CREATE PROCEDURE [ReportPortal].[GetObjectUtilizationMostRecentByPrincipalID]
	-- Add the parameters for the stored procedure here
	(
	@PrincipalID smallint
	)
AS
BEGIN
	SELECT  CAST(RPOU.CreatedDate AS date) AS CreatedDate,
        RPO.DisplayName,
        RPO.Descr,
        RPOU.RptObjID,
        COUNT(RPOU.RptObjUtilID) AS Viewed,
        COUNT(RPOU.Params) AS ParamCnt
FROM    ReportPortal.ObjectUtilization RPOU
        INNER JOIN ReportPortal.Objects RPO ON RPO.RptObjID = RPOU.RptObjID
WHERE
		RPOU.PrincipalID = @PrincipalID
GROUP BY RPOU.RptObjID,
        CAST(RPOU.CreatedDate AS date),
        RPO.DisplayName,
        RPO.Descr,
        CAST(RPOU.Params AS varchar(MAX))
ORDER BY CAST(RPOU.CreatedDate AS date) DESC,
        COUNT(RPOU.RptObjUtilID) ASC;
END;

GO
GRANT EXECUTE ON  [ReportPortal].[GetObjectUtilizationMostRecentByPrincipalID] TO [PortalApp]
GO
